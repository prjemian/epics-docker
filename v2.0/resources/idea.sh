#!/bin/bash
source "${HOME}/.bash_aliases"

# $ADSIMDETECTOR/bin/linux-x86_64/simDetectorApp st.cmd

# export ADSIM="${IOCS_DIR}/iocadsim"
export IOCADSIM="${IOCS_DIR}/iocadsim"

export AREA_DETECTOR="${SUPPORT}/$(ls ${SUPPORT} | grep areaDetector)"
export ADSIMDETECTOR="${AREA_DETECTOR}/ADSimDetector/iocs/simDetectorIOC"
export IOCADSIMDETECTOR="${ADSIMDETECTOR}/iocBoot/iocSimDetector"

source "${RESOURCES}/tarcopy.sh"
tarcopy "${IOCADSIMDETECTOR}" "${IOCADSIM}"
cd "${IOCADSIM}"

# envPaths
# epicsEnvSet("IOC","iocSimDetector")
sed -i \
    s+'epicsEnvSet("IOC",'+'epicsEnvSet(\"IOC\",\"iocadsim\")\n# epicsEnvSet("IOC",'+g \
    ./envPaths

# cdCommands
# startup = "/opt/synApps/support/areaDetector-R3-11/ADSimDetector/iocs/simDetectorIOC/iocBoot/iocSimDetector"
# putenv("IOC=iocSimDetector")
sed -i \
    s+"startup =+startup = \"$IOCADSIM\"\n# startup ="+g \
    ./cdCommands
sed -i \
    s+'putenv("IOC=iocSimDetector")+putenv("IOC=iocadsim")'+g \
    ./cdCommands

# TODO: change Prefix 13SIM1 adsim
