
ORG=prjemian
REPO=epics-base-7.0.3
LOGFILE=build-log.txt
NET=host-bridge

FULLNAME=$(ORG)/$(REPO)

build ::
	docker build \
		-t $(FULLNAME)  \
		./  \
		2>&1 | tee $(LOGFILE)

shell ::
	docker run \
		-it \
		--rm \
		--net=$(NET) \
		--name=$(REPO) \
		$(FULLNAME) \
		/bin/bash

push ::
	docker push $(FULLNAME)

net ::
	docker network create \
		--driver bridge \
		$(NET)
