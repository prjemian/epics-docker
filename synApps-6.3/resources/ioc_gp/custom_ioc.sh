#!/bin/bash

echo "# --- --- --- --- --- script ---> $(readlink -f ${0})"

source "${HOME}/.bash_aliases"
LOG_FILE="${LOG_DIR}/create_gp_ioc.log"

export GP="${IOCS_DIR}/iocgp"
export IOCGP="${GP}/iocBoot/iocgp"

cat >> "${HOME}/.bash_aliases"  << EOF
#
# create_gp_ioc.sh
export GP="${GP}"
export IOCGP="${IOCGP}"
EOF

# bash "${RESOURCES}/ioc_gp/copy_IOC.sh" 2>&1 | tee -a "${LOG_FILE}"
# bash "${RESOURCES}/ioc_gp/prefix.sh" 2>&1 | tee -a "${LOG_FILE}"
# bash "${RESOURCES}/ioc_gp/iocStats.sh" 2>&1 | tee -a "${LOG_FILE}"
# bash "${RESOURCES}/ioc_gp/make.sh" 2>&1 | tee -a "${LOG_FILE}"
# bash "${RESOURCES}/ioc_gp/motors.sh" 2>&1 | tee -a "${LOG_FILE}"
# bash "${RESOURCES}/ioc_gp/optics.sh" 2>&1 | tee -a "${LOG_FILE}"
# bash "${RESOURCES}/ioc_gp/std.sh" 2>&1 | tee -a "${LOG_FILE}"
# bash "${RESOURCES}/ioc_gp/add_general_purpose.sh" 2>&1 | tee -a "${LOG_FILE}"
# bash "${RESOURCES}/ioc_gp/alive.sh" 2>&1 | tee -a "${LOG_FILE}"
# bash "${RESOURCES}/ioc_gp/build_gp_sh.sh" 2>&1 | tee -a "${LOG_FILE}"
# bash "${RESOURCES}/ioc_gp/install_screens.sh" 2>&1 | tee -a "${LOG_FILE}"
