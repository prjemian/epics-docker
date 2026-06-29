#!/bin/bash

echo "# running: $(readlink -f ${0})"
source "${HOME}/.bash_aliases"

echo "# ................................ install custom screen(s)"
cd "${IOCGP}/"
export SCREENS="${IOCGP}/screens"
${RESOURCES}/tarcopy.sh "${GP}/gpApp/op/" "${SCREENS}/"
mv /tmp/{gp_,}screens
${RESOURCES}/tarcopy.sh /tmp/screens "${SCREENS}/"
/bin/rm -rf /tmp/screens
${RESOURCES}/modify_adl_in_ui_files.sh  "${SCREENS}/ui"
${RESOURCES}/modify_adl_in_ui_files.sh  "${SCREENS}/ui/autoconvert"
# Now, all CUSTOM screens for this IOC are in directory IOCGP/screens

# change "xxx:" to "$(P)" in all screen files
find "${SCREENS}/" -type f -exec sed -i 's/xxx:/$(P)/g' {} \;
find "${SCREENS}/" -type f -exec sed -i 's/ioc=xxx/ioc=gp/g' {} \;
find "${SCREENS}/" -type f -exec sed -i 's/xxxA/$(P)A/g' {} \;
find "${SCREENS}/" -type f -exec sed -i 's/>xxx/>gp/g' {} \;
