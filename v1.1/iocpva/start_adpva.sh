#!/bin/bash

# start an EPICS areaDetector pvaDriver IOC in a docker container
#
# usage:  ./start_adpva.sh [PRE]
#   where PRE is the IOC prefix (without any trailing colon)
#   default:  PRE=13PVA1

PRE=${1:-13PVA1}
IMAGE_SHORT_NAME=custom-synapps-6.2-ad-3.10

# -------------------------------------------
# IOC prefix
PREFIX=${PRE}:

# name of docker container
CONTAINER=ioc${PRE}

# name of docker image
IMAGE=prjemian/${IMAGE_SHORT_NAME}:latest

# name of IOC manager (start, stop, status, ...)
IOCPVA=${AREA_DETECTOR}/pvaDriver/iocs/pvaDriverIOC/iocBoot/iocPvaDriver

# pass the IOC PREFIX to the container at boot time
ENVIRONMENT="PREFIX=${PREFIX}"

# convenience definitions
RUN="docker exec ${CONTAINER}"
TMP_ROOT=/tmp/docker_ioc
HOST_IOC_ROOT=${TMP_ROOT}/${CONTAINER}
IOC_TOP=${HOST_IOC_ROOT}/iocpva
OP_DIR=${TMP_ROOT}/${IMAGE_SHORT_NAME}
HOST_TMP_SHARE=${HOST_IOC_ROOT}/tmp
# -------------------------------------------

# stop and remove container if it exists
remove_container.sh ${CONTAINER}

mkdir -p ${HOST_TMP_SHARE}

# -------------------------------------------
# start docker container with custom PREFIX
# do not start ADSimDetector IOC
echo -n "starting container ${CONTAINER} ... "
docker run -d -it --rm --net=host \
    --name ${CONTAINER} \
    -e "${ENVIRONMENT}" \
    -v "${HOST_TMP_SHARE}":/tmp \
    ${IMAGE} \
    bash

# -------------------------------------------
# start the IOC

sleep 1
# apply last-minute modifications
docker cp adpvaioc.sh ${CONTAINER}:/opt/adpvaioc.sh
docker cp pva_cam_image.ui ${CONTAINER}:/opt/screens/ui

# start the IOC in the container
echo -n "starting IOC ${CONTAINER} ... "
docker exec "${CONTAINER}" bash /opt/adpvaioc.sh
sleep 2

# -------------------------------------------
echo "copy IOC ${CONTAINER} files to ${HOST_IOC_ROOT}"
docker cp ${CONTAINER}:/opt/iocpva/  ${HOST_IOC_ROOT}
mkdir -p ${OP_DIR}
docker cp ${CONTAINER}:/opt/screens/   ${OP_DIR}

sed -i s+_IOC_SCREEN_DIR_+`echo ${IOC_TOP}`+g ${IOC_TOP}/start_caQtDM_${PRE}
sed -i s+_AD_SCREENS_DIR_+`echo ${OP_DIR}/screens/ui`+g ${IOC_TOP}/start_caQtDM_${PRE}
