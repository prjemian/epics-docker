
ORG=prjemian
REPO=synapps-git-ad-git
LOGFILE=build-log.txt
# NET=host-bridge
NET=host
IOC=dkr

FULLNAME=$(ORG)/$(REPO)

build ::
	echo "# started: " `date --iso-8601="seconds"` | tee $(LOGFILE)
	docker build \
		-t $(FULLNAME)  \
		./  \
		2>&1 | tee -a $(LOGFILE)
	echo "# finished: " `date --iso-8601="seconds"` | tee -a $(LOGFILE)

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
