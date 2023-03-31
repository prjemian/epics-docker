#!/bin/bash

# edit the assemble_synApps.sh script
# to download and prepare for building synApps

# EPICS base
sed -i s:'^EPICS_BASE=':"EPICS_BASE=$EPICS_BASE\n#EPICS_BASE=":g assemble_synApps.sh

# do NOT use these modules
_MODULES_=""
_MODULES_+=" ALIVE"
_MODULES_+=" ALLENBRADLEY"
_MODULES_+=" CAMAC"
_MODULES_+=" DAC128V"
_MODULES_+=" DELAYGEN"
_MODULES_+=" DXP"
_MODULES_+=" DXPSITORO"
_MODULES_+=" GALIL"
_MODULES_+=" IP330"
_MODULES_+=" IPUNIDIG"
_MODULES_+=" LOVE"
_MODULES_+=" MEASCOMP"
_MODULES_+=" QUADEM"
_MODULES_+=" SOFTGLUE"
_MODULES_+=" SOFTGLUEZYNQ"
_MODULES_+=" VAC"
_MODULES_+=" VME"
_MODULES_+=" YOKOGAWA_DAS"
_MODULES_+=" XSPRESS3"

for mod in ${_MODULES_}; do
  cmd="sed -i s:'${mod}=':'#+#${mod}=':g assemble_synApps.sh"
  echo ${cmd}
  eval ${cmd}
done

# use these modules from their GitHub master branch(es)

_MODULES_=""
_MODULES_+=" AREA_DETECTOR"
_MODULES_+=" ASYN"
_MODULES_+=" AUTOSAVE"
_MODULES_+=" BUSY"
_MODULES_+=" CALC"
_MODULES_+=" CAPUTRECORDER"
_MODULES_+=" DEVIOCSTATS"
_MODULES_+=" IP"
_MODULES_+=" IPAC"
_MODULES_+=" LUA"
_MODULES_+=" MCA"
_MODULES_+=" MODBUS"
_MODULES_+=" MOTOR"
_MODULES_+=" OPTICS"
_MODULES_+=" SSCAN"
_MODULES_+=" STD"
_MODULES_+=" STREAM"
_MODULES_+=" XXX"

# for mod in ${_MODULES_}; do
#   cmd="sed -i s:'^${mod}=\S*\$':'${mod}=master':g assemble_synApps.sh"
#   echo ${cmd}
#   eval ${cmd}
# done
for mod in "CAPUTRECORDER"; do
  cmd="sed -i s:'^${mod}=\S*\$':'${mod}=${CAPUTRECORDER_HASH}':g assemble_synApps.sh"
  echo ${cmd}
  eval ${cmd}
done
# for mod in "MOTOR"; do
#   cmd="sed -i s:'^${mod}=\S*\$':'${mod}=${MOTOR_HASH}':g assemble_synApps.sh"
#   echo ${cmd}
#   eval ${cmd}
# done
for mod in "STREAM"; do
  cmd="sed -i s:'^${mod}=\S*\$':'${mod}=2.8.14':g assemble_synApps.sh"
  echo ${cmd}
  eval ${cmd}
done

# area detector ADURL
sed -i \
  s:'update ADSimDetector':'update ADSimDetector\ngit submodule update ADURL':g \
  assemble_synApps.sh
REPLACE="sed -i s^'#ADURL'^'ADURL'^g RELEASE.local"
sed -i \
  "s:building ADSimDetector:building ADSimDetector\n$REPLACE:g" \
  assemble_synApps.sh

# area detector pvaDriver
sed -i \
  s:'update ADURL':'update ADURL\ngit submodule update pvaDriver':g \
  assemble_synApps.sh
REPLACE="sed -i s^'#PVADRIVER'^'PVADRIVER'^g RELEASE.local"
sed -i \
  "s:building ADSimDetector:building ADSimDetector\n$REPLACE:g" \
  assemble_synApps.sh

# TODO:
# FFMPEGSERVER=$(AREA_DETECTOR)/ffmpegServer
# FFMPEGVIEWER=$(AREA_DETECTOR)/ffmpegViewer
