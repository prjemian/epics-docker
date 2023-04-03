#!/bin/bash

# custom simDetectorIOC

echo "# --- --- --- --- --- script ---> $(readlink -f ${0})"

source "${HOME}/.bash_aliases"
LOG_FILE="${LOG_DIR}/create_adsim_ioc.log"

export IOCADSIM="${IOCS_DIR}/iocadsim"

export AREA_DETECTOR="${SUPPORT}/$(ls ${SUPPORT} | grep areaDetector)"
export ADSIMDETECTOR="${AREA_DETECTOR}/ADSimDetector/iocs/simDetectorIOC"
export IOCADSIMDETECTOR="${ADSIMDETECTOR}/iocBoot/iocSimDetector"


cat >> "${HOME}/.bash_aliases"  << EOF
#
# create_adsim_ioc.sh
export IOCADSIM="${IOCADSIM}"
export AREA_DETECTOR="${AREA_DETECTOR}"
export ADSIMDETECTOR="${ADSIMDETECTOR}"
export IOCADSIMDETECTOR="${IOCADSIMDETECTOR}"
EOF

echo "# ................................ copy IOC from ADSimDetector" 2>&1 | tee -a "${LOG_FILE}"
"${RESOURCES}/tarcopy.sh" "${IOCADSIMDETECTOR}" "${IOCADSIM}"

cd "${IOCADSIM}"
ln -s "${IOCADSIM}" /home/iocadsim

# Since this is a copy of the iocBoot directory,
# it will be edited with the proper paths and
# the Makefiles should NOT be enabled.
mv /tmp/adsim_README ./README
/bin/rm -f Makefile*

sed -i \
    s+'epicsEnvSet("IOC",'+'epicsEnvSet(\"IOC\",\"iocadsim\")\n# epicsEnvSet("IOC",'+g \
    ./envPaths

sed -i \
    s+"startup =+startup = \"$IOCADSIM\"\n# startup ="+g \
    ./cdCommands
sed -i \
    s+'putenv("IOC=iocSimDetector")+putenv("IOC=iocadsim")'+g \
    ./cdCommands

# NeXus writer support is superceded by HDF writer, remove the template here.
/bin/rm NexusTemplate.xml

echo "# ................................ prepare IOC run scripts" 2>&1 | tee -a "${LOG_FILE}"
cd "${IOCADSIM}"
echo "dbl > dbl-all.txt" >> st_base.cmd
"${RESOURCES}/tarcopy.sh" "${IOCGP}/softioc" "${IOCADSIM}/softioc"
mv /tmp/adsim_run.sh "${IOCADSIM}/softioc/run"
chmod +x "${IOCADSIM}/softioc/run"

mv "${IOCADSIM}/softioc/gp.sh" "${IOCADSIM}/softioc/adsim.sh"
sed -i s+gp+adsim+g "${IOCADSIM}/softioc/adsim.sh"
sed -i \
    s+"IOC_BINARY=adsim"+"IOC_BINARY=simDetectorApp\nIOC_BIN_DIR=${ADSIMDETECTOR}/bin"+g \
    "${IOCADSIM}/softioc/adsim.sh"
sed -i s+'cmd\.Linux'+'cmd'+g "${IOCADSIM}/softioc/adsim.sh"

echo "# ................................ configure custom IOC PREFIX" 2>&1 | tee -a "${LOG_FILE}"
# Customize everything that expects prefix "13SIM1:", default PREFIX is "adsim:".
sed -i s/'epicsEnvSet("PREFIX", "13SIM1:")'/'epicsEnvSet("PREFIX", $(PREFIX=adsim:))'/g   ./st_base.cmd

echo "# ................................ starter shortcut" 2>&1 | tee -a "${LOG_FILE}"
cat >> "${HOME}/bin/adsim.sh"  << EOF
#!/bin/bash

source "${HOME}/.bash_aliases"

cd "${IOCADSIM}/softioc"
bash ./adsim.sh "\${1}"

if [ "\${1}" == "start" ]; then
    # allow time for the IOC to start (in screen, possibly)
    sleep 2
    bash ./adsim.sh status
fi
EOF
chmod +x "${HOME}/bin/adsim.sh"
# startup hints:
# docker run -e PREFIX='bub:' -it -d --rm --net=host-bridge --name iocbub prjemian/synapps bash
# docker exec iocbub /root/bin/adsim.sh start
# docker stop iocbub

echo "# ................................ customize st_base.cmd" 2>&1 | tee -a "${LOG_FILE}"
# comment out any line with SIM2
sed -i '/SIM2/s/^/#/g' "${IOCADSIM}/st_base.cmd"

echo "# ................................ plugins" 2>&1 | tee -a "${LOG_FILE}"
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
# enable the ffmpegserver  (needs support in assemble_synApps.sh)
# sed -i \
#     '/ffmpegServerConfigure/s/^#//g' \
#     "${IOCADSIM}/commonPlugins.cmd"
# sed -i \
#     '/ffmpegStreamConfigure/s/^#//g' \
#     "${IOCADSIM}/commonPlugins.cmd"
# sed -i \
#     '/ffmpegFileConfigure/s/^#//g' \
#     "${IOCADSIM}/commonPlugins.cmd"
# sed -i \
#     '/FFMPEGSERVER/s/^#//g' \
#     "${IOCADSIM}/commonPlugins.cmd"

echo "# ................................ autosave" 2>&1 | tee -a "${LOG_FILE}"
cp ${IOCADSIMDETECTOR}/auto_settings.req "${IOCADSIM}/"
# comment out any line with cam2
sed -i '/cam2/s/^/#/g' "${IOCADSIM}/auto_settings.req"


# ---------------------------------------------------------------------------
# RUN bash /opt/copy_screens.sh ${SUPPORT} /opt/screens | tee -a /opt/copy_screens.log
# COPY \
#       sim_cam_image.ui \
#       start_caQtDM_adsim \
#       /opt/iocSimDetector/
# COPY \
#       url_cam_image.ui \
#       start_caQtDM_adurl \
#       /opt/iocURLDriver/
# RUN bash /opt/modify_adl_in_ui_files.sh  /opt/screens/ui
