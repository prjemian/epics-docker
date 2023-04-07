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

"${RESOURCES}/adsim_copy_IOC.sh" 2>&1 | tee -a "${LOG_FILE}"
"${RESOURCES}/adsim_IOC_run_script.sh" 2>&1 | tee -a "${LOG_FILE}"
"${RESOURCES}/adsim_prefix.sh" 2>&1 | tee -a "${LOG_FILE}"
"${RESOURCES}/adsim_build_adsim_sh.sh" 2>&1 | tee -a "${LOG_FILE}"
"${RESOURCES}/adsim_st_base.sh" 2>&1 | tee -a "${LOG_FILE}"
"${RESOURCES}/adsim_plugins.sh" 2>&1 | tee -a "${LOG_FILE}"
"${RESOURCES}/adsim_autosave.sh" 2>&1 | tee -a "${LOG_FILE}"
"${RESOURCES}/adsim_install_screens.sh" 2>&1 | tee -a "${LOG_FILE}"

