#!/bin/bash

echo "# running: $(readlink -f ${0})"
source "${HOME}/.bash_aliases"

echo "# ................................ remove ALIVE support"
# comment out any line with ALIVE
sed -i '/ALIVE/s/^/#/g' "${IOCGP}/common.iocsh"
