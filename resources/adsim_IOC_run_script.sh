#!/bin/bash

echo "# running: $(readlink -f ${0})"
source "${HOME}/.bash_aliases"

echo "# ................................ prepare IOC run scripts"
cd "${IOCADSIM}"
echo "dbl > dbl-all.txt" >> st_base.cmd
"${RESOURCES}/tarcopy.sh" "${IOCGP}/softioc" "${IOCADSIM}/softioc"
cp "${RESOURCES}/adsim_run.sh" "${IOCADSIM}/softioc/run"
chmod +x "${IOCADSIM}/softioc/run"

mv "${IOCADSIM}/softioc/gp.sh" "${IOCADSIM}/softioc/adsim.sh"
sed -i s+gp+adsim+g "${IOCADSIM}/softioc/adsim.sh"
sed -i \
    s+"IOC_BINARY=adsim"+"IOC_BINARY=simDetectorApp\nIOC_BIN_DIR=${ADSIMDETECTOR}/bin"+g \
    "${IOCADSIM}/softioc/adsim.sh"
sed -i s+'cmd\.Linux'+'cmd'+g "${IOCADSIM}/softioc/adsim.sh"
