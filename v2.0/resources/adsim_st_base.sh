#!/bin/bash

echo "# running: $(readlink -f ${0})"
source "${HOME}/.bash_aliases"

echo "# ................................ customize st_base.cmd"
# comment out any line with SIM2
sed -i '/SIM2/s/^/#/g' "${IOCADSIM}/st_base.cmd"
sed -i '/"EPICS_CA_MAX_ARRAY_BYTES"/s/^#//g' "${IOCADSIM}/st_base.cmd"
