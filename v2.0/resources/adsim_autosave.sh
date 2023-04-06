#!/bin/bash

echo "# running: $(readlink -f ${0})"
source "${HOME}/.bash_aliases"

echo "# ................................ autosave"
cp ${IOCADSIMDETECTOR}/auto_settings.req "${IOCADSIM}/"
# comment out any line with cam2
sed -i '/cam2/s/^/#/g' "${IOCADSIM}/auto_settings.req"
