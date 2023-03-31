#!/bin/bash

# change ".adl" to ".ui" in all caQtDM .ui files 
# see: https://github.com/prjemian/epics-docker/issues/26

# usage:  modify_adl_in_ui_files UI_DIR
#
# examples:  
#
#     modify_adl_in_ui_files.sh /opt/synApps/screens/ui
#
# PARAMETERS
#
#   UI_DIR : (str, optional) path to directory with caQtDM .ui screen files
#            default: /opt/screens/ui
#
# Changes all references to ".adl" into ".ui"

OP_DIR=${1:-/opt/screens/ui}

cd ${OP_DIR}
for f in $(ls *.ui); do
    echo Converting $f ...
    sed -i s:'.adl':'.ui':g ./$f
done
