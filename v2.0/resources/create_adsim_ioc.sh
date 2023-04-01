#!/bin/bash

# TODO: replrefactorace with idea.sh

echo "# --- --- --- --- --- script ---> $(readlink -f ${0})"

source "${HOME}/.bash_aliases"
LOG_FILE="${LOG_DIR}/create_adsim_ioc.log"

export ADSIM="${IOCS_DIR}/iocadsim"
export IOCADSIM="${GP}/iocBoot/iocadsim"

export AREA_DETECTOR="${SUPPORT}/$(ls ${SUPPORT} | grep areaDetector)"
export ADSIMDETECTOR="${AREA_DETECTOR}/ADSimDetector/iocs/simDetectorIOC"


cat >> "${HOME}/.bash_aliases"  << EOF
#
# create_adsim_ioc.sh
export AREA_DETECTOR="${AREA_DETECTOR}"
export ADSIM="${ADSIM}"
export IOCADSIM="${IOCADSIM}"
EOF

echo "# ................................ copy ADSimDetector" 2>&1 | tee -a "${LOG_FILE}"

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
