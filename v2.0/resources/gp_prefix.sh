#!/bin/bash

echo "# running: $(readlink -f ${0})"
source "${HOME}/.bash_aliases"

echo "# ................................ customize default PREFIX"
cd "${GP}"
changePrefix xxx gp  # default PREFIX is gp:
cd "${IOCGP}"
ln -s "${IOCGP}" /home/iocgp
sed -i s/'IOC_NAME=gp'/'export PREFIX=${PREFIX:-gp:\}\nIOC_NAME=\$\{PREFIX\}'/g   ./softioc/gp.sh
sed -i s/'epicsEnvSet("PREFIX", "gp:")'/'epicsEnvSet("PREFIX", $(PREFIX=gp:))'/g   ./settings.iocsh
