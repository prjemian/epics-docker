#!/bin/bash

echo "# running: $(readlink -f ${0})"
source "${HOME}/.bash_aliases"

echo "# ................................ install custom screen(s)"
cd "${IOCADSIM}/"
export SCREENS="${IOCADSIM}/screens"
${RESOURCES}/tarcopy.sh "${AD}/ADSimDetector/simDetectorApp/op/" "${SCREENS}/"
mv /tmp/{adsim_,}screens
${RESOURCES}/tarcopy.sh /tmp/screens "${SCREENS}/"
/bin/rm -rf /tmp/screens
${RESOURCES}/modify_adl_in_ui_files.sh  "${SCREENS}/ui"
${RESOURCES}/modify_adl_in_ui_files.sh  "${SCREENS}/ui/autoconvert"
