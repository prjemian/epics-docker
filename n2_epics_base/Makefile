
ORG=prjemian
REPO=epics-base-7.0.4
LOGFILE=build-log.txt
NET=host-bridge

FULLNAME=$(ORG)/$(REPO)

build ::
	echo "# build started: " `date --iso-8601="seconds"` | tee $(LOGFILE)
	docker build \
		-t $(FULLNAME)  \
		./  \
		2>&1 | tee -a $(LOGFILE)
	echo "# build finished: " `date --iso-8601="seconds"` | tee -a $(LOGFILE)

shell ::
	docker run \
		-it \
		--rm \
		--net=$(NET) \
		--name=$(REPO) \
		$(FULLNAME) \
		/bin/bash

push ::
	echo "# push started: " `date --iso-8601="seconds"` | tee -a $(LOGFILE)
	docker push $(FULLNAME) 2>&1 | tee -a $(LOGFILE)
	echo "# push finished: " `date --iso-8601="seconds"` | tee -a $(LOGFILE)

net ::
	docker network create \
		--driver bridge \
		$(NET)
