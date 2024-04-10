ORG=prjemian
REPO=synapps
LOGFILE=build-log-$(shell date +%Y%m%d-%H%M%S).txt
NET=host-bridge
TAG=2.1.0

FULLNAME=$(ORG)/$(REPO)

BUILD_ARGS:=./
# Uncomment next line to force entire image to rebuild.
# BUILD_ARGS:=--no-cache ${BUILD_ARGS}

# Setting DOCKER_BUILDKIT=0 to remove log size clipping at default (2MB).
# https://github.com/docker/buildx/issues/484#issuecomment-1079334026
# But this will change in a future release of the docker build command.

build ::
	echo "# started: " `date --iso-8601="seconds"` | tee $(LOGFILE)
	DOCKER_BUILDKIT=0 docker build \
		-t $(FULLNAME):$(TAG)  \
		$(BUILD_ARGS) \
		2>&1 | tee -a $(LOGFILE)
	echo "# finished: " `date --iso-8601="seconds"` | tee -a $(LOGFILE)
	echo "LOGFILE: ${LOGFILE}"

run ::
	docker run \
		-it \
		--rm \
		--net=$(NET) \
		--name=$(REPO) \
		$(FULLNAME):$(TAG) \
		/bin/bash

shell :: build run

push ::
	echo "# push started: " `date --iso-8601="seconds"` | tee -a $(LOGFILE)
	docker push $(FULLNAME):$(TAG) 2>&1 | tee -a $(LOGFILE)
	echo "# push finished: " `date --iso-8601="seconds"` | tee -a $(LOGFILE)

net ::
	docker network create \
		--driver bridge \
		$(NET)
