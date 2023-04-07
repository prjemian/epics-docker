#!/bin/bash

# template for starting MEDM
# replace these symbols (typical replacements shown)
#   SET_EXT         adl
#   SET_SCREEN      xxx.adl ...
#   SET_PREFIX      gp:  sky:  ad:  ...
#   SET_MACRO       P=$PREFIX,R=cam1:

# https://stackoverflow.com/a/246128/1046449
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SCREENS=$(readlink -m "${SCRIPT_DIR}/screens/SET_EXT")
DEFAULT_SCREEN="${DEFAULT_SCREEN:-SET_SCREEN}"
PREFIX=SET_PREFIX

# echo "DEFAULT_SCREEN=${DEFAULT_SCREEN}"
# echo "PREFIX=${PREFIX}"
# echo "SCREENS=${SCREENS}"
# echo "SCRIPT_DIR=${SCRIPT_DIR}"

if [ "" != "${EPICS_DISPLAY_PATH}" ]; then
    EPICS_DISPLAY_PATH+=:
fi
export EPICS_DISPLAY_PATH+="${SCREENS}"

#export EPICS_CA_ADDR_LIST="164.54.53.126"

# This should agree with the environment variable set by the ioc
# see 'putenv "EPICS_CA_MAX_ARRAY_BYTES=64008"' in iocBoot/ioc<target>/st.cmd
export EPICS_CA_MAX_ARRAY_BYTES=10000000

export EDITOR=nano

export APP=medm
export MACRO="SET_MACRO" 
export ADL_FILE=${1:-${DEFAULT_SCREEN}}

${APP} -x -macro ${MACRO} ${ADL_FILE} &
