#!/bin/bash

echo "# --- --- --- --- --- script ---> $(readlink -f ${0})"

source "${HOME}/.bash_aliases"

LOG_FILE="${LOG_DIR}/build-synApps.log"

export SYNAPPS=$(readlink -f "${APP_ROOT}/synApps")

cd "${APP_ROOT}" || exit
SCRIPT="assemble_synApps"
echo "# ................................ download installer: ${SCRIPT}" 2>&1 | tee -a "${LOG_FILE}"

# download the installer script
# export HASH=master
export HASH=R6-3
ORG_REPO="EPICS-synApps/assemble_synApps"
URL="https://raw.githubusercontent.com/${ORG_REPO}/${HASH}/${SCRIPT}"
wget -q --no-check-certificate "${URL}"


echo "# ................................ modify installer: ${SCRIPT}" 2>&1 | tee -a "${LOG_FILE}"
# change this line: my @submods = ("ADCore", "ADSupport", "ADSimDetector");
# to: my @submods = ("ADCore", "ADSupport", "ADSimDetector", "pvaDriver", "ADURL");
sed -i s:'\"ADSimDetector\"':'\"ADSimDetector\", \"ADURL\"':g "${APP_ROOT}/${SCRIPT}"
sed -i s:'\"ADSimDetector\"':'\"ADSimDetector\", \"pvaDriver\"':g "${APP_ROOT}/${SCRIPT}"

echo "# ................................ run installer: ${SCRIPT}" 2>&1 | tee -a "${LOG_FILE}"
# cat "${APP_ROOT}/assemble_synApps"
perl "${APP_ROOT}/${SCRIPT}" \
    --base="${EPICS_BASE}" \
    --config="${RESOURCES}"/synApps-module-config.txt \
    --dir="${SYNAPPS}" \
    | tee "${LOG_DIR}/assemble_synApps.log"

export SUPPORT=$(readlink -f "${SYNAPPS}/support")
export PATH="${PATH}:${SUPPORT}/utils"
export IOCS_DIR="$(readlink -m "${SUPPORT}"/../iocs)"
mkdir -p "${IOCS_DIR}"

echo "APP_ROOT='${APP_ROOT}'"
echo "LOG_FILE='${LOG_FILE}'"
echo "SYNAPPS='${SYNAPPS}'"
echo "SUPPORT='${SUPPORT}'"
echo "IOCS_DIR='${IOCS_DIR}'"
echo "PATH='${PATH}'"

echo "# ................................ update ~/bash_aliases" 2>&1 | tee -a "${LOG_FILE}"
cd "${SUPPORT}" || exit
export AD="${SUPPORT}/$(ls "${SUPPORT}" | grep areaDetector)"
export ADPVA="${AD}/$(ls "${AD}" | grep pvaDriver)"
export ADSIM="${AD}/$(ls "${AD}" | grep ADSimDetector)"
export ADURL="${AD}/$(ls "${AD}" | grep ADURL)"
export ASYN="${SUPPORT}/$(ls "${SUPPORT}" | grep asyn)"
export MOTOR="${SUPPORT}/$(ls "${SUPPORT}" | grep motor)"
export OPTICS="${SUPPORT}/$(ls "${SUPPORT}" | grep optics)"
export XXX="${SUPPORT}/$(ls "${SUPPORT}" | grep xxx)"
export IOCADSIM=${ADSIM}/iocs/simDetectorIOC/iocBoot/iocSimDetector
export IOCXXX=${XXX}/iocBoot/iocxxx

cat >> "${HOME}/.bash_aliases"  << EOF
#
# assemble_synApps
export AD="${AD}"
export ADPVA="${ADPVA}"
export ADSIM="${ADSIM}"
export ADURL="${ADURL}"
export ASYN="${ASYN}"
export IOCADSIM="${IOCADSIM}"
export IOCXXX="${IOCXXX}"
export MOTOR="${MOTOR}"
export OPTICS="${OPTICS}"
export SUPPORT="${SUPPORT}"
export XXX="${XXX}"
EOF
source "${HOME}/.bash_aliases"
cat "${HOME}/.bash_aliases"


echo "# ................................ build synApps" 2>&1 | tee -a "${LOG_FILE}"
CPUs=$(grep "^cpu cores" /proc/cpuinfo | uniq | awk '{print $4}')
echo "TIRPC=YES" > "${ASYN}/configure/CONFIG_SITE.local"
make \
    -j"${CPUs}" \
    -C "${SUPPORT}" \
    release rebuild \
    2>&1 \
    | tee "${LOG_DIR}"/build-synApps.log

cd "${SUPPORT}" || exit
ln -s "${SUPPORT}" /home/support


echo "# ................................ build synApps XXX" 2>&1 | tee -a "${LOG_FILE}"
echo "# --- Building XXX IOC ---" 2>&1 | tee -a "${LOG_DIR}"/build-synApps.log
make -C "${IOCXXX}"/ 2>&1 | tee -a "${LOG_DIR}"/build-synApps.log
ln -s "${IOCXXX}"/ ./iocxxx


echo "# ................................ collect screen files" 2>&1 | tee -a "${LOG_FILE}"
export SCREENS="${SUPPORT}/screens"
"${RESOURCES}/copy_screens.sh" "${SUPPORT}" "${SCREENS}/"
"${RESOURCES}/modify_adl_in_ui_files.sh"  "${SCREENS}/ui"


echo "# ................................ IOC soft links" 2>&1 | tee -a "${LOG_FILE}"
ln -s "${IOCXXX}" /home/iocxxx
ln -s "${IOCADSIM}" /home/iocadsim
