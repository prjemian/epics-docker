#!/bin/bash

echo "# running: $(readlink -f ${0})"
source "${HOME}/.bash_aliases"

echo "# ................................ plugins"
# NeXus writer support is superceded by HDF writer, remove the template here.
/bin/rm "${IOCADSIM}/NexusTemplate.xml"

# customize ${AD}/ADCore/iocBoot/commonPlugins.cmd
sed -i \
    s+'$(ADCORE)/iocBoot'+"${IOCADSIM}"+g \
    "${IOCADSIM}/st_base.cmd"
cp ${AD}/ADCore/iocBoot/commonPlugins.cmd "${IOCADSIM}/"
# uncomment any line with FileMagick
sed -i \
    '/FileMagick/s/^#//g' \
    "${IOCADSIM}/commonPlugins.cmd"
# enable the PVA server
sed -i \
    '/PVA1/s/^#//g' \
    "${IOCADSIM}/commonPlugins.cmd"
sed -i \
    '/Pva1:/s/^#//g' \
    "${IOCADSIM}/commonPlugins.cmd"
sed -i \
    '/startPVAServer/s/^#//g' \
    "${IOCADSIM}/commonPlugins.cmd"

# TODO: FFMPEGSERVER  (needs support in edit_assemble_synApps.sh)
# TODO: FFMPEGVIEWER  (needs support in edit_assemble_synApps.sh)
# sed -i '/ffmpegServerConfigure/s/^#//g'   "${IOCADSIM}/commonPlugins.cmd"
# sed -i '/ffmpegStreamConfigure/s/^#//g'   "${IOCADSIM}/commonPlugins.cmd"
# sed -i '/ffmpegFileConfigure/s/^#//g'   "${IOCADSIM}/commonPlugins.cmd"
# sed -i '/FFMPEGSERVER/s/^#//g'   "${IOCADSIM}/commonPlugins.cmd"
