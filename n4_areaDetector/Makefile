
ORG=prjemian
REPO=synapps-6.1-ad-3.7
LOGFILE=build-log.txt
# NET=host-bridge
NET=host
IOC=dkr

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
		--name=ioc$(IOC) \
		-e "PREFIX=$(IOC):" \
		$(FULLNAME) \
		/bin/bash

push ::
	docker push $(FULLNAME)

net ::
	docker network create \
		--driver bridge \
		$(NET)
