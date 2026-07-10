# Makefile -- build/run/test the v3 image(s).
#
# Versions come from versions.env (single source of truth). Every value
# there is passed to the Dockerfile as a --build-arg automatically.

# Container engine: docker or podman (auto-detect, override with ENGINE=).
ENGINE ?= $(shell command -v docker 2>/dev/null || command -v podman 2>/dev/null)

# Detect podman -- including the podman-docker wrapper, where `docker` is
# actually podman (its --version prints "podman ...").
IS_PODMAN := $(shell $(ENGINE) --version 2>/dev/null | grep -qi podman && echo yes)

# Extra flags for `build`/`run`. Rootless podman needs --no-hosts to avoid
# "failed to create new hosts file: /etc/hosts: permission denied". Harmless
# on docker. Auto-enabled for podman; override by setting BUILD_FLAGS/RUN_FLAGS.
ifeq ($(IS_PODMAN),yes)
BUILD_FLAGS ?= --no-hosts
RUN_FLAGS   ?= --no-hosts
else
BUILD_FLAGS ?=
RUN_FLAGS   ?=
endif

# Load versions.env into make variables.
include versions.env
export

ORG    ?= prjemian
REPO   ?= synapps
TARGET ?= synapps-runtime
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

.PHONY: help build build-devel run stop console shell test clean vars

help ::
	@echo "targets:"
	@echo "  build        build the runtime image ($(TARGET)) -> $(IMAGE)"
	@echo "  run          run a persona: make run IOC=<persona> PREFIX=<prefix:>"
	@echo "               container is named ioc<prefix> (e.g. PREFIX=demo: -> iocdemo)"
	@echo "  stop         stop the container for PREFIX (make stop PREFIX=demo:)"
	@echo "  console      attach to the running IOC console (telnet)"
	@echo "  shell        interactive shell in the image"
	@echo "  test         build then smoke-test all personas"
	@echo "  vars         show resolved versions/vars"
	@echo "  clean        remove the built image"

vars ::
	@echo "ENGINE = $(ENGINE)  (podman: $(if $(IS_PODMAN),yes,no))"
	@echo "IMAGE  = $(IMAGE)"
	@echo "TARGET = $(TARGET)"
	@echo "IOC / PREFIX = $(IOC) / $(PREFIX)"
	@echo "CONTAINER    = $(CONTAINER)"
	@echo "BUILD_FLAGS = $(BUILD_FLAGS)"
	@echo "RUN_FLAGS   = $(RUN_FLAGS)"
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

# Persona + prefix (override on the command line):
#   make run IOC=gp PREFIX=gp:
IOC    ?= softioc
PREFIX ?= ioc:
# Container name = ioc<prefix-without-trailing-colon>, e.g. PREFIX=demo: -> iocdemo.
# Unique + recognizable, matching the compose services and the iocgp/iocad style.
CONTAINER = ioc$(patsubst %:,%,$(PREFIX))

# No console-port bookkeeping: procServ listens on a UNIX socket inside the
# container, reached by name via `make console PREFIX=...`. So any number of
# IOCs run concurrently under --net=host -- pick only IOC and PREFIX.
run ::
	$(ENGINE) run $(RUN_FLAGS) --rm -d \
		--name $(CONTAINER) \
		--net=host \
		-e IOC=$(IOC) \
		-e PREFIX=$(PREFIX) \
		$(IMAGE)
	@echo "started container '$(CONTAINER)' (IOC=$(IOC), PREFIX=$(PREFIX))"

stop ::
	-$(ENGINE) stop $(CONTAINER)

console ::
	@echo "attaching to '$(CONTAINER)' console (Ctrl-] then 'quit' to detach)"
	$(ENGINE) exec -it $(CONTAINER) console

shell ::
	$(ENGINE) run --rm -it --entrypoint /bin/bash $(IMAGE)

test :: build
	RUN_FLAGS="$(RUN_FLAGS)" bash resources/smoke-test.sh $(ENGINE) $(IMAGE)

clean ::
	-$(ENGINE) rmi $(IMAGE)
