#!/bin/bash

# echo "Hello!  PWD=$(pwd)"
# ls -larth "${RESOURCES}/"

export BASE_VERSION=7.0.5
export EPICS_BASE_NAME=base-${BASE_VERSION}
export EPICS_BASE="${APP_ROOT}/${EPICS_BASE_NAME}"

# update ~/.bash_aliases
cat >> "${HOME}/.bash_aliases"  << EOF
#
# epics_base.sh
export BASE_VERSION="${BASE_VERSION}"
export EPICS_BASE_NAME="${EPICS_BASE_NAME}"
export EPICS_BASE="${EPICS_BASE}"
EOF

source "${HOME}/.bash_aliases"

LOG_FILE="${LOG_DIR}/build-base.log"

echo "# ................................ download EPICS base" 2>&1 | tee -a "${LOG_FILE}"
cd "${APP_ROOT}/"
wget \
    -q \
    --no-check-certificate \
    https://epics.anl.gov/download/base/${EPICS_BASE_NAME}.tar.gz

echo "# ................................ unpack EPICS base" 2>&1 | tee -a "${LOG_FILE}"
tar xzf ${EPICS_BASE_NAME}.tar.gz &&\
    rm  ${EPICS_BASE_NAME}.tar.gz &&\
    ln -s ${EPICS_BASE_NAME} base &&\
    ls -lAFgh

export EPICS_HOST_ARCH="$(${EPICS_BASE}/startup/EpicsHostArch)"
export PATH="${PATH}:${EPICS_BASE}/bin/${EPICS_HOST_ARCH}"

# update ~/.bash_aliases
cat >> "${HOME}/.bash_aliases"  << EOF
export EPICS_HOST_ARCH="${EPICS_HOST_ARCH}"
export PATH="${PATH}"
EOF

echo "environment:\n$(env | sort)"

echo "# ................................ build EPICS base" 2>&1 | tee -a "${LOG_FILE}"
cd "${EPICS_BASE}"
make \
    -j4 \
    all \
    CFLAGS="-fPIC" CXXFLAGS="-fPIC"  \
    2>&1 \
    | tee -a "${LOG_FILE}"

echo "# ................................ clean EPICS base" 2>&1 | tee -a "${LOG_FILE}"
make clean  2>&1 | tee -a "${LOG_FILE}"
