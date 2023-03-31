#!/bin/bash

source "${HOME}/.bash_aliases"

LOG_FILE="${LOG_DIR}/build-synApps.log"

export SYNAPPS="${APP_ROOT}/synApps"
export SUPPORT="${SYNAPPS}/support"
export PATH="${PATH}:${SUPPORT}/utils"

export CAPUTRECORDER_HASH=master
export MOTOR_HASH=R7-2-2
# export AD=${SUPPORT}/areaDetector-master
# export MOTOR=${SUPPORT}/motor-${MOTOR_HASH}
export XXX=${SUPPORT}/xxx-R6-2-1
export IOCXXX=${XXX}/iocBoot/iocxxx

# update ~/.bash_aliases
cat >> "${HOME}/.bash_aliases"  << EOF
#
# epics_synapps.sh
export SYNAPPS="${SYNAPPS}"
export SUPPORT="${SUPPORT}"
export PATH="${PATH}"
export CAPUTRECORDER_HASH="${CAPUTRECORDER_HASH}"
export MOTOR_HASH="${CAPUTRECORDER_HASH}"
# export AD="${AD}"
# export MOTOR="${MOTOR}"
export XXX="${XXX}"
export IOCXXX="${IOCXXX}"
EOF

source "${HOME}/.bash_aliases"

cd ${APP_ROOT}
echo "# ................................ download EPICS assemble_synApps.sh" 2>&1 | tee -a "${LOG_FILE}"
# TODO: build synApps out of source

# download the installer script
# ENV HASH=master
export HASH=R6-2-1
wget \
    -q \
    --no-check-certificate \
    "https://raw.githubusercontent.com/EPICS-synApps/support/${HASH}/assemble_synApps.sh"

echo "# ................................ edit assemble_synApps.sh installer" 2>&1 | tee -a "${LOG_FILE}"
bash \
    "${RESOURCES}/edit_assemble_synApps.sh" 2>&1 \
    | tee "${LOG_DIR}/edit_assemble_synApps.log"


echo "# ................................ run assemble_synApps.sh installer" 2>&1 | tee -a "${LOG_FILE}"
# cat "${APP_ROOT}/assemble_synApps.sh"
export SYNAPPS_DIR="${SYNAPPS}"
bash \
    "${APP_ROOT}/assemble_synApps.sh" 2>&1 \
    | tee "${LOG_DIR}/assemble_synApps.log"

echo "# ................................ build synApps" 2>&1 | tee -a "${LOG_FILE}"
cd ${SUPPORT}
export ASYN="${SUPPORT}/$(ls | grep asyn)"

# update ~/.bash_aliases
cat >> "${HOME}/.bash_aliases"  << EOF
export ASYN="${ASYN}"
EOF

source "${HOME}/.bash_aliases"
CPUs=$(grep "^cpu cores" /proc/cpuinfo | uniq | awk '{print $4}')
echo "TIRPC=YES" > "${ASYN}/configure/CONFIG_SITE.local"
make -j${CPUs} release rebuild 2>&1 | tee ${LOG_DIR}/build-synApps.log

echo "# ................................ build synApps XXX" 2>&1 | tee -a "${LOG_FILE}"
echo "# --- Building XXX IOC ---" 2>&1 | tee -a ${LOG_DIR}/build-synApps.log
make -C ${IOCXXX}/ 2>&1 | tee -a ${LOG_DIR}/build-synApps.log
ln -s ${IOCXXX}/ ./iocxxx
