#!/bin/bash

# start a synApps XXX IOC in a docker container
#
# usage:  ./start_xxx.sh [PRE]
#   where PRE is the IOC prefix (without any trailing colon)
#   default:  PRE=xxx

PRE=${1:-xxx}

# -------------------------------------------
# IOC prefix
PREFIX=${PRE}:

# name of docker container
CONTAINER=ioc${PRE}

# name of docker image
IMAGE=prjemian/synapps-6.1

# name of IOC manager (start, stop, status, ...)
IOC_MANAGER=iocxxx/softioc/xxx.sh

# container will quit unless it has something to run
# this is trivial but shows that container is running
# prints dat/time every 10 seconds
KEEP_ALIVE_COMMAND="while true; do date; sleep 10; done"

# pass the IOC PREFIX to the container ar boot time
ENVIRONMENT="PREFIX=${PREFIX}"

# convenience definitions
RUN="docker exec ${CONTAINER}"
TMP_ROOT=/tmp/docker_ioc
HOST_IOC_ROOT=${TMP_ROOT}/${CONTAINER}
# -------------------------------------------

# stop and remove container if ti exists
remove_container.sh ${CONTAINER}

echo -n "starting container ${CONTAINER} ... "
docker run -d --net=host \
    --name ${CONTAINER} \
    -e "${ENVIRONMENT}" \
    ${IMAGE} \
    bash -c "${KEEP_ALIVE_COMMAND}"

sleep 1

# edit files in IOC for use with GUI software
echo "changing xxx: to ${PREFIX} in ${CONTAINER}"
CMD="${RUN} sed -i s:/APSshare/bin/caQtDM:caQtDM:g iocxxx/../../start_caQtDM_xxx"; ${CMD}
CMD="${RUN} sed -i s/xxx:/${PREFIX}/g iocxxx/../../xxxApp/op/adl/xxx.adl"; ${CMD}
CMD="${RUN} sed -i s/ioc=xxx/ioc=${PRE}/g iocxxx/../../xxxApp/op/adl/xxx.adl"; ${CMD}
CMD="${RUN} sed -i s/xxx:/${PREFIX}/g iocxxx/../../xxxApp/op/ui/xxx.ui"; ${CMD}
CMD="${RUN} sed -i s/ioc=xxx/ioc=${PRE}/g iocxxx/../../xxxApp/op/ui/xxx.ui"; ${CMD}

echo -n "starting IOC ${CONTAINER} ... "
CMD="${RUN} ${IOC_MANAGER} start"
echo ${CMD}
${CMD}
sleep 2

# copy container's files to /tmp for medm & caQtDM
echo "copy IOC ${CONTAINER} to ${HOST_IOC_ROOT}"
mkdir -p ${HOST_IOC_ROOT}
docker cp ${CONTAINER}:/opt/synApps/support/xxx-R6-1/  ${HOST_IOC_ROOT}
