#!/bin/bash

# copy all screen files from available synApps modules to common directory
# group by GUI

# usage:  copy_screens.sh SUPPORT OP_DIR
#
# examples:  
#
#     copy_screens.sh /usr/local/epics/synApps/support
#     copy_screens.sh /opt/synApps/support /opt/synApps/screens
#
# PARAMETERS
#
#   SUPPORT : (str) path to synApps support directory
#   OP_DIR : (str, optional) path to directory to be written
#            default: /tmp/synApps_screens
#            OP_DIR will be created if it does not exist
#
# Screen (and other) files will be copied to
# subdirectories of OP_DIR based on which gui
# (MEDM files go in $OP_DIR/adl, caQtDM in $OP_DIR/ui,
# CSS BOY in $OP_DIR/opi)
#
# All screen files for a particular program (MEDM, caQtDM, CSS BOY)
# will be copied to a single directory for that GUI.  This simplifies 
# the process of configuring the GUI to find its screen files.
#
# NOTE:
# Separate subdirectories are used, one for each GUI program,
# to allow multiple programs to use the same file extension
# (such as caQtDM and PyDM both use the .ui file extension).

SUPPORT=$1
# SUPPORT=/usr/local/epics/synApps/support

OP_DIR=${2:-/tmp/synApps_screens}
# note: we don't have any pydm files, yet
GUI_LIST="adl opi ui pydm"

function contents
{
    # find all file content of subdirectory
    subdir=$1
    files=
    if [[ -d ${subdir} ]]; then
        # only directories
        if [ "" != "`ls ${subdir}/`" ]; then
            # directory must have some content
            for file in `ls ${subdir}/*`; do
                # yoda comparisons to avoid accidental assignment
                bname=$(basename -- $file)
                if [[ -f $file && \
                      "Makefile" != "${bname}" && \
                      "README" != "${bname}" && \
                      "README.md" != "${bname}" \
                      ]]; then
                    # content must be a file that is not named Makefile or README*
                    files+=" $(dirname -- $file)/${bname}"
                fi
            done
        fi
    fi
}

for module in `find ${SUPPORT} -wholename "*/op"`; do
    if [ -d $module ]; then
        for gui in $GUI_LIST; do
            # build the list of files to copy
            filelist=
            # first: copy autoconvert subdirectory (if it exists)
            contents ${module}/${gui}/autoconvert
            filelist+=" ${files}"
            # then: allow autoconvert/.. directory to override
            contents ${module}/${gui}
            filelist+=" ${files}"
            
            # copy all files to OP_DIR
            mkdir -p ${OP_DIR}/${gui}
            for item in ${filelist}; do
                # separate by GUI manager
                cmd="cp ${item}  ${OP_DIR}/${gui}/$(basename -- $item)"
                # echo ${cmd}
                echo "$(basename -- $item)"
                ${cmd}                
            done
        done
    fi
done
