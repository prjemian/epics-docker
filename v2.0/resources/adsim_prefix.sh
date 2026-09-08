#!/bin/bash

echo "# running: $(readlink -f ${0})"
source "${HOME}/.bash_aliases"

echo "# ................................ configure custom IOC PREFIX"
# Customize everything that expects prefix "13SIM1:", default PREFIX is "adsim:".
sed -i s/'13SIM1:'/"\$(PREFIX=adsim:)"/g "${IOCADSIM}/st_base.cmd"
