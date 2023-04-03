#!/bin/bash

# custom simDetectorIOC

echo "# --- --- --- --- --- script ---> $(readlink -f ${0})"

source "${HOME}/.bash_aliases"
LOG_FILE="${LOG_DIR}/create_adsim_ioc.log"

export IOCADSIM="${IOCS_DIR}/iocadsim"

export AREA_DETECTOR="${SUPPORT}/$(ls ${SUPPORT} | grep areaDetector)"
export ADSIMDETECTOR="${AREA_DETECTOR}/ADSimDetector/iocs/simDetectorIOC"
export IOCADSIMDETECTOR="${ADSIMDETECTOR}/iocBoot/iocSimDetector"


cat >> "${HOME}/.bash_aliases"  << EOF
#
# create_adsim_ioc.sh
export IOCADSIM="${IOCADSIM}"
export AREA_DETECTOR="${AREA_DETECTOR}"
export ADSIMDETECTOR="${ADSIMDETECTOR}"
export IOCADSIMDETECTOR="${IOCADSIMDETECTOR}"
EOF

echo "# ................................ copy IOC from ADSimDetector" 2>&1 | tee -a "${LOG_FILE}"
"${RESOURCES}/tarcopy.sh" "${IOCADSIMDETECTOR}" "${IOCADSIM}"

cd "${IOCADSIM}"
ln -s "${IOCADSIM}" /home/iocadsim

# Since this is a copy of the iocBoot directory,
# it will be edited with the proper paths and
# the Makefiles should NOT be enabled.
mv /tmp/adsim_README ./README
/bin/rm -f Makefile*

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

# NeXus writer support is superceded by HDF writer, remove the template here.
/bin/rm NexusTemplate.xml

echo "# ................................ prepare IOC run scripts" 2>&1 | tee -a "${LOG_FILE}"
cd "${IOCADSIM}"
"${RESOURCES}/tarcopy.sh" "${IOCGP}/softioc" "${IOCADSIM}/softioc"
mv /tmp/adsim_run.sh "${IOCADSIM}/softioc/run"
chmod +x "${IOCADSIM}/softioc/run"

mv "${IOCADSIM}/softioc/gp.sh" "${IOCADSIM}/softioc/adsim.sh"
sed -i s+gp+adsim+g "${IOCADSIM}/softioc/adsim.sh"
sed -i s+IOC_BINARY=adsim+IOC_BINARY=simDetectorApp+g "${IOCADSIM}/softioc/adsim.sh"
# TODO:
# IOC_BIN_PATH="${IOC_BIN_DIR}/${EPICS_HOST_ARCH}/${IOC_BINARY}"
# Needs these in the environment when calling adsim.sh (new since xxx 6.2.1)
# IOC_BIN_DIR="${ADSIMDETECTOR}/bin"
# IOC_BINARY=simDetectorApp


# TODO: change Prefix 13SIM1 adsim

# ---------------------------------------------------------------------------
# RUN bash /opt/copy_screens.sh ${SUPPORT} /opt/screens | tee -a /opt/copy_screens.log
# COPY \
#       sim_cam_image.ui \
#       start_caQtDM_adsim \
#       /opt/iocSimDetector/
# COPY \
#       url_cam_image.ui \
#       start_caQtDM_adurl \
#       /opt/iocURLDriver/
# RUN bash /opt/modify_adl_in_ui_files.sh  /opt/screens/ui
