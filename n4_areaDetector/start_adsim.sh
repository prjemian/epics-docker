#!/bin/bash

# start an EPICS areaDetector ADSimDetector IOC in a docker container
#
# usage:  ./start_adsim.sh [PRE]
#   where PRE is the IOC prefix (without any trailing colon)
#   default:  PRE=13SIM1

PRE=${1:-13SIM1}

# -------------------------------------------
# IOC prefix
PREFIX=${PRE}:

# name of docker container
CONTAINER=ioc${PRE}

# name of docker image
IMAGE=prjemian/synapps-6.1-ad-3.7:latest

# name of IOC manager (start, stop, status, ...)
IOC_MANAGER=iocSimDetector/simDetector.sh

# container will quit unless it has something to run
# this is trivial but shows that container is running
# prints date/time every 10 seconds
KEEP_ALIVE_COMMAND="while true; do date; sleep 10; done"

# pass the IOC PREFIX to the container at boot time
ENVIRONMENT="AD_PREFIX=${PREFIX}"

# convenience definitions
RUN="docker exec ${CONTAINER}"
TMP_ROOT=/tmp/docker_ioc
HOST_IOC_ROOT=${TMP_ROOT}/${CONTAINER}
IOC_TOP=${HOST_IOC_ROOT}/iocSimDetector
OP_DIR=${TMP_ROOT}/synapps-6.1-ad-3.7
# -------------------------------------------

# stop and remove container if it exists
remove_container.sh ${CONTAINER}

echo -n "starting container ${CONTAINER} ... "
docker run -d --net=host \
    --name ${CONTAINER} \
    -e "${ENVIRONMENT}" \
    ${IMAGE} \
    bash -c "${KEEP_ALIVE_COMMAND}"

sleep 1

echo -n "starting IOC ${CONTAINER} ... "
CMD="${RUN} ${IOC_MANAGER} start"
echo ${CMD}
${CMD}
sleep 2

# copy container's files to /tmp for medm & caQtDM
echo "copy IOC ${CONTAINER} to ${HOST_IOC_ROOT}"
mkdir -p ${HOST_IOC_ROOT}
docker cp ${CONTAINER}:/opt/synApps/support/areaDetector-R3-7/ADSimDetector/iocs/simDetectorIOC/iocBoot/iocSimDetector/  ${HOST_IOC_ROOT}
mkdir -p ${OP_DIR}
docker cp ${CONTAINER}:/opt/synApps/support/screens/   ${OP_DIR}

# edit files in docker container IOC for use with GUI software
echo "changing 13SIM1: to ${PREFIX} in ${CONTAINER}"
sed -i s+13SIM1+`echo ${PRE}`+g ${IOC_TOP}/start_caQtDM_adsim
sed -i s+_IOC_SCREEN_DIR_+`echo ${IOC_TOP}`+g ${IOC_TOP}/start_caQtDM_adsim
sed -i s+_AD_SCREENS_DIR_+`echo ${OP_DIR}/screens/ui`+g ${IOC_TOP}/start_caQtDM_adsim
sed -i s+"# CAQTDM_DISPLAY_PATH"+CAQTDM_DISPLAY_PATH+g ${IOC_TOP}/start_caQtDM_adsim

# TODO: find the caQtDM plugins and copy locally
# TODO: edit QT_PLUGIN_PATH in start_caQtDM_adsim
