ORG=prjemian
REPO=synapps
LOGFILE=build-log.txt
NET=host-bridge
TAG=2.0.1

FULLNAME=$(ORG)/$(REPO)

build ::
	echo "# started: " `date --iso-8601="seconds"` | tee $(LOGFILE)
	docker build \
		-t $(FULLNAME):$(TAG)  \
		./  \
		2>&1 | tee -a $(LOGFILE)
	echo "# finished: " `date --iso-8601="seconds"` | tee -a $(LOGFILE)

run ::
	docker run \
		-it \
		--rm \
		--net=$(NET) \
		--name=$(REPO) \
		$(FULLNAME) \
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
