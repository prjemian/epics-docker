#!/bin/bash

# file: recommended_AD_edits.sh
# Purpose: recommended edits:
#    https://areadetector.github.io/master/install_guide.html

cd ${AREA_DETECTOR}/configure
cp EXAMPLE_RELEASE.local         RELEASE.local
cp EXAMPLE_RELEASE_LIBS.local    RELEASE_LIBS.local
cp EXAMPLE_RELEASE_PRODS.local   RELEASE_PRODS.local
cp EXAMPLE_CONFIG_SITE.local     CONFIG_SITE.local

sed -i s:'SUPPORT=/corvette/home/epics/devel':'SUPPORT=/opt/synApps/support':g RELEASE_LIBS.local
sed -i s:'areaDetector-3-10':'areaDetector-${AD_TAG}':g RELEASE_LIBS.local
sed -i s:'asyn-4-41':'asyn-R4-41':g RELEASE_LIBS.local
sed -i s:'EPICS_BASE=/corvette/usr/local/epics-devel/base-7.0.4':'EPICS_BASE=/opt/base-R7.0.4.1':g RELEASE_LIBS.local

sed -i s:'areaDetector-3-10':'areaDetector-${AD_TAG}':g RELEASE_PRODS.local
sed -i s:'asyn-4-41':'asyn-R4-41':g RELEASE_PRODS.local
sed -i s:'autosave-5-10':'autosave-R5-10-2':g RELEASE_PRODS.local
sed -i s:'busy-1-7-2':'busy-R1-7-3':g RELEASE_PRODS.local
sed -i s:'calc-3-7-3':'calc-R3-7-4':g RELEASE_PRODS.local
sed -i s:'devIocStats-3-1-16':'iocStats-3-1-16':g RELEASE_PRODS.local
sed -i s:'EPICS_BASE=/corvette/usr/local/epics-devel/base-7.0.4':'EPICS_BASE=/opt/base-R7.0.4.1':g RELEASE_PRODS.local
sed -i s:'seq-2-2-5':'seq-2-2-8':g RELEASE_PRODS.local
sed -i s:'sscan-2-11-3':'sscan-R2-11-4':g RELEASE_PRODS.local
sed -i s:'SUPPORT=/corvette/home/epics/devel':'SUPPORT=/opt/synApps/support':g RELEASE_PRODS.local

# CONFIG_SITE.local -- no edits

sed -i s:'#ADSIMDETECTOR=':'ADSIMDETECTOR=':g RELEASE.local
sed -i s:'#PVADRIVER=':'PVADRIVER=':g RELEASE.local

cd ${AREA_DETECTOR}/ADCore/iocBoot
cp EXAMPLE_commonPlugins.cmd                                commonPlugins.cmd
cp EXAMPLE_commonPlugin_settings.req                        commonPlugin_settings.req
sed -i s:'#NDPvaConfigure':'NDPvaConfigure':g               commonPlugins.cmd
sed -i s:'#dbLoadRecords("NDPva':'dbLoadRecords("NDPva':g   commonPlugins.cmd
sed -i s:'#startPVAServer':'startPVAServer':g               commonPlugins.cmd
