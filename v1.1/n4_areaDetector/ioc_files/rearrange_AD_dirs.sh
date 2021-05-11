#!/bin/bash

# file: rearrange_AD_dirs.sh
# Purpose:
#    After downloading the various AD repos,
#    re-arrange them for building.

cd ${AREA_DETECTOR}

pairs=' ADCORE_HASH/ADCore'
pairs+=' ADSUPPORT_HASH/ADSupport'
pairs+=' ADSIMDETECTOR_HASH/ADSimDetector'
pairs+=' ADURL_HASH/ADURL'
pairs+=' ADVIEWERS_HASH/ADViewers'
pairs+=' AD_FFMPEGSERVER_HASH/ffmpegServer'
pairs+=' AD_PVADRIVER_HASH/pvaDriver'

# repetitive steps best done in a loop (could be a function instead)
for s in $pairs;
do
    # echo $s
    IFS='/'
    read -ra PARTS <<< "$s"
    modulename=${PARTS[1]}
    envvar=${PARTS[0]}
    h=$(env | grep "${envvar}")
    IFS='='
    read -ra PARTS <<< "$h"
    hashname=${modulename}-${PARTS[1]}
    # echo "modulename=${modulename}"
    # echo "hashname=${hashname}"

    # remove the stub directories
    rmdir ${modulename}

    # unpack the repos to be used
    tar xzf ${modulename}.tar.gz

    # remove the archive files
    /bin/rm ${modulename}.tar.gz

    # rename to match the has codes as written
    mv $(ls | grep "${hashname}")  "${hashname}"

    # convenient names for build process
    ln -s "${hashname}" ${modulename}

    # echo "##########################################"
done
IFS=' '
