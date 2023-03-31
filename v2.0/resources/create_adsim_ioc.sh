#!/bin/bash

# PV prefix is $PREFIX (default: xxx:)  <-- FIXME (gp, ioc, ...)
# enable:
# * 56 motors
# * scaler
# * Kohzu monochromator

echo "# --- --- --- --- --- script ---> $(readlink -f ${0})"

source "${HOME}/.bash_aliases"
LOG_FILE="${LOG_DIR}/create_adsim_ioc.log"

export ADSIM="${IOCS_DIR}/iocadsim"
export IOCADSIM="${GP}/iocBoot/iocadsim"

cat >> "${HOME}/.bash_aliases"  << EOF
#
# create_adsim_ioc.sh
export ADSIM="${ADSIM}"
export IOCADSIM="${IOCADSIM}"
EOF
