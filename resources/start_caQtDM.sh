#!/bin/bash

# template for starting caQtDM
# replace these symbols (typical replacements shown)
#   SET_EXT         ui
#   SET_SCREEN      xxx.ui ...
#   SET_PREFIX      gp:  sky:  ad:  ...
#   SET_MACRO       P=$PREFIX,R=cam1:

# https://stackoverflow.com/a/246128/1046449
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SCREENS=$(readlink -m "${SCRIPT_DIR}/screens/SET_EXT")
DEFAULT_SCREEN="${DEFAULT_SCREEN:-SET_SCREEN}"
PREFIX=SET_PREFIX

export EPICS_HOST_ARCH=linux-x86_64

# echo "DEFAULT_SCREEN=${DEFAULT_SCREEN}"
# echo "PREFIX=${PREFIX}"
# echo "SCREENS=${SCREENS}"
# echo "SCRIPT_DIR=${SCRIPT_DIR}"

if [ "" != "${CAQTDM_DISPLAY_PATH}" ]; then
    CAQTDM_DISPLAY_PATH+=:
fi
export CAQTDM_DISPLAY_PATH+="${SCREENS}"

export QT_PLUGIN_PATH="/usr/local/epics/extensions/lib/${EPICS_HOST_ARCH}"
export CAQTDM_OPTIMIZE_EPICS3CONNECTIONS="TRUE"

#export EPICS_CA_ADDR_LIST="164.54.53.126"

# This should agree with the environment variable set by the ioc
# see 'putenv "EPICS_CA_MAX_ARRAY_BYTES=64008"' in iocBoot/ioc<target>/st.cmd
export EPICS_CA_MAX_ARRAY_BYTES=10000000

export EDITOR=nano

export APP=caQtDM
export MACRO="SET_MACRO" 
export UI_FILE=${1:-${DEFAULT_SCREEN}}

# echo "called with: ${0} ${@}"
${APP} -macro ${MACRO} ${UI_FILE} &
