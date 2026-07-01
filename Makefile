# Makefile -- build/run/test the v3 image(s).
#
# Versions come from versions.env (single source of truth). Every value
# there is passed to the Dockerfile as a --build-arg automatically.

# Container engine: docker or podman (auto-detect, override with ENGINE=).
ENGINE ?= $(shell command -v docker 2>/dev/null || command -v podman 2>/dev/null)

# Extra flags for `build`/`run`. Rootless podman needs --no-hosts to avoid
# "failed to create new hosts file: /etc/hosts: permission denied".
# Harmless-to-omit on docker; set BUILD_FLAGS=--no-hosts for rootless podman.
BUILD_FLAGS ?=
RUN_FLAGS   ?=

# Load versions.env into make variables.
include versions.env
export

ORG    ?= prjemian
REPO   ?= synapps
TARGET ?= base-synapps
TAG    ?= $(IMAGE_VERSION)
IMAGE   = $(ORG)/$(REPO):$(TAG)

# Turn every KEY=VALUE in versions.env into "--build-arg KEY=VALUE", EXCEPT
# multi-word values handled specially below (SYNAPPS_OVERRIDE_*, AD_DRIVERS).
BUILD_ARGS = $(foreach line,$(shell grep -vE '^\s*(#|$$)' versions.env | grep -vE '^SYNAPPS_OVERRIDE_|^AD_DRIVERS='),--build-arg $(line))

# Collect SYNAPPS_OVERRIDE_<MOD>=<TAG> lines into one space-separated
# SYNAPPS_OVERRIDES build-arg of "MOD=TAG" pairs.
OVERRIDE_PAIRS = $(shell grep -E '^SYNAPPS_OVERRIDE_' versions.env | sed -E 's/^SYNAPPS_OVERRIDE_//')
BUILD_ARGS += --build-arg SYNAPPS_OVERRIDES="$(OVERRIDE_PAIRS)"

# AD_DRIVERS is a space-separated list; pass as one quoted build-arg.
AD_DRIVERS_VAL = $(shell grep -E '^AD_DRIVERS=' versions.env | sed -E 's/^AD_DRIVERS=//')
BUILD_ARGS += --build-arg AD_DRIVERS="$(AD_DRIVERS_VAL)"

# BuildKit gives us cache mounts + `# syntax=` features.
export DOCKER_BUILDKIT = 1

.PHONY: help build build-devel run console shell test clean vars

help ::
	@echo "targets:"
	@echo "  build        build the runtime image ($(TARGET)) -> $(IMAGE)"
	@echo "  run          run softIoc persona (host networking)"
	@echo "  console      attach to the running IOC console (telnet)"
	@echo "  shell        interactive shell in the image"
	@echo "  test         build then smoke-test softIoc"
	@echo "  vars         show resolved versions/vars"
	@echo "  clean        remove the built image"

vars ::
	@echo "ENGINE = $(ENGINE)"
	@echo "IMAGE  = $(IMAGE)"
	@echo "TARGET = $(TARGET)"
	@echo "BUILD_ARGS = $(BUILD_ARGS)"

build ::
	$(ENGINE) build $(BUILD_FLAGS) \
		--target $(TARGET) \
		$(BUILD_ARGS) \
		-t $(IMAGE) \
		.

# Devel variant: stops at the build stage (toolchain + sources retained).
build-devel ::
	$(ENGINE) build $(BUILD_FLAGS) \
		--target epics-build \
		$(BUILD_ARGS) \
		-t $(ORG)/$(REPO):$(TAG)-devel \
		.

run ::
	$(ENGINE) run $(RUN_FLAGS) --rm -d \
		--name $(REPO) \
		--net=host \
		-e PREFIX=$${PREFIX:-ioc:} \
		$(IMAGE)

console ::
	@echo "connecting to IOC console (Ctrl-] then 'quit' to detach)"
	telnet localhost $${IOC_CONSOLE_PORT:-2048}

shell ::
	$(ENGINE) run --rm -it --entrypoint /bin/bash $(IMAGE)

test :: build
	RUN_FLAGS="$(RUN_FLAGS)" bash resources/smoke-test.sh $(ENGINE) $(IMAGE)

clean ::
	-$(ENGINE) rmi $(IMAGE)
