#!/bin/bash

echo "# running: $(readlink -f ${0})"
source "${HOME}/.bash_aliases"

echo "# ................................ copy IOC from ADSimDetector"

"${RESOURCES}/tarcopy.sh" "${IOCADSIMDETECTOR}" "${IOCADSIM}"

cd "${IOCADSIM}"
ln -s "${IOCADSIM}" /home/iocadsim

# Since this is a copy of the iocBoot directory,
# it will be edited with the proper paths and
# the Makefiles should NOT be enabled.
mv /tmp/adsim_README ./README
/bin/rm -f Makefile*

sed -i s/iocSimDetector/iocadsim/g ./envPaths


sed -i \
    s+"startup =+startup = \"$IOCADSIM\"\n# startup ="+g \
    ./cdCommands
sed -i \
    s+'putenv("IOC=iocSimDetector")'+"putenv(\"IOC=$IOCADSIM\")"+g \
    ./cdCommands
