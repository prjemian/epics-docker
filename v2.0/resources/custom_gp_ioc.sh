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

bash "${RESOURCES}/gp_copy_IOC.sh" 2>&1 | tee -a "${LOG_FILE}"
bash "${RESOURCES}/gp_prefix.sh" 2>&1 | tee -a "${LOG_FILE}"
bash "${RESOURCES}/gp_iocStats.sh" 2>&1 | tee -a "${LOG_FILE}"
bash "${RESOURCES}/gp_make.sh" 2>&1 | tee -a "${LOG_FILE}"
bash "${RESOURCES}/gp_motors.sh" 2>&1 | tee -a "${LOG_FILE}"
bash "${RESOURCES}/gp_optics.sh" 2>&1 | tee -a "${LOG_FILE}"
bash "${RESOURCES}/gp_std.sh" 2>&1 | tee -a "${LOG_FILE}"
bash "${RESOURCES}/gp_add_general_purpose.sh" 2>&1 | tee -a "${LOG_FILE}"
bash "${RESOURCES}/gp_alive.sh" 2>&1 | tee -a "${LOG_FILE}"
bash "${RESOURCES}/gp_build_gp_sh.sh" 2>&1 | tee -a "${LOG_FILE}"
bash "${RESOURCES}/gp_install_screens.sh" 2>&1 | tee -a "${LOG_FILE}"
