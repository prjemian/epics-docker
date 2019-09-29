FROM  prjemian/synapps-6.1
LABEL version="1.0.0" \
      maintainer="prjemian <prjemian@gmail.com>" \
      lastupdate="2019-09-29"
USER  root
WORKDIR /home

# Install libraries from offical repo needed by area detector
#    * libusb (newer faster usb support)
#    * X11 (for GraphicsMagick)
# * run IOCs in screen sessions (base-os provides)

RUN \
    apt-get update  -y && \
    apt-get install -y  \
       libx11-dev \
       x11-xserver-utils \
       xorg-dev \
       && \
    rm -rf /var/lib/apt/lists/*

# ============ parent image definitions ============
# additional software packages added here
ENV APP_ROOT="/opt"
# for use with `crontab -e`
ENV EDITOR="nano"
ENV EPICS_HOST_ARCH=linux-x86_64
ENV EPICS_ROOT="${APP_ROOT}/base"
ENV PATH="${PATH}:${EPICS_ROOT}/bin/${EPICS_HOST_ARCH}"
ENV SUPPORT="${APP_ROOT}/synApps/support"
ENV PATH="${PATH}:${SUPPORT}/utils"

# ============ EPICS area detector ============

WORKDIR ${SUPPORT}
ENV AREA_DETECTOR=${SUPPORT}/areaDetector-R3-7

# # TODO: download AD sources: AD, ADCore, ADSupport, ADSimDetector, ADURL, ...?
# # ADD ______url_______.zip .
# # TODO: update ${SUPPORT}/configure/RELEASE with new AD
# # RUN make release

# # # recommended edits: https://areadetector.github.io/master/install_guide.html
# # WORKDIR ${AREA_DETECTOR}/configure
# # RUN cp EXAMPLE_RELEASE.local         RELEASE.local && \
# #     cp EXAMPLE_RELEASE_SUPPORT.local RELEASE_SUPPORT.local && \
# #     cp EXAMPLE_RELEASE_LIBS.local    RELEASE_LIBS.local && \
# #     cp EXAMPLE_RELEASE_PRODS.local   RELEASE_PRODS.local && \
# #     cp EXAMPLE_CONFIG_SITE.local     CONFIG_SITE.local && \
# #     sed -i s:'BUILD_IOCS = NO':'BUILD_IOCS = YES':g CONFIG_SITE.local.${EPICS_HOST_ARCH} && \
# #     sed -i s:'WITH_PVA = NO':'WITH_PVA = YES':g CONFIG_SITE.local.${EPICS_HOST_ARCH} && \
# #     sed -i s:'WITH_QSRV = NO':'WITH_QSRV = YES':g CONFIG_SITE.local.${EPICS_HOST_ARCH} && \
# #     sed -i s:'#ADSIMDETECTOR=':'ADSIMDETECTOR=':g RELEASE.local && \
# #     sed -i s:'#PVADRIVER=':'PVADRIVER=':g RELEASE.local && \
# #     sed -i s:'SUPPORT=/corvette/home/epics/devel':'SUPPORT=/opt/synApps/support':g RELEASE_SUPPORT.local && \
# #     sed -i s:'asyn-4-36':'asyn-R4-36':g RELEASE_LIBS.local && \
# #     sed -i s:'areaDetector-3-7':'areaDetector-R3-7':g RELEASE_LIBS.local && \
# #     sed -i s:'EPICS_BASE=/corvette/usr/local/epics-devel/base-7.0.3':'EPICS_BASE=/opt/base-7.0.3':g RELEASE_LIBS.local && \
# #     sed -i s:'asyn-4-36':'asyn-R4-36':g RELEASE_PRODS.local && \
# #     sed -i s:'areaDetector-3-7':'areaDetector-R3-7':g RELEASE_PRODS.local && \
# #     sed -i s:'autosave-5-10':'autosave-R5-10':g RELEASE_PRODS.local && \
# #     sed -i s:'busy-1-7-2':'busy-R1-7-2':g RELEASE_PRODS.local && \
# #     sed -i s:'calc-3-7-3':'calc-R3-7-3':g RELEASE_PRODS.local && \
# #     sed -i s:'seq-2-2-5':'seq-2-2-6':g RELEASE_PRODS.local && \
# #     sed -i s:'sscan-2-11-3':'sscan-R2-11-3':g RELEASE_PRODS.local && \
# #     sed -i s:'devIocStats-3-1-16':'iocStats-3-1-16':g RELEASE_PRODS.local && \
# #     sed -i s:'EPICS_BASE=/corvette/usr/local/epics-devel/base-7.0.3':'EPICS_BASE=/opt/base-7.0.3':g RELEASE_PRODS.local
# # WORKDIR ${AREA_DETECTOR}/ADCore/iocBoot
# # RUN cp EXAMPLE_commonPlugins.cmd                                commonPlugins.cmd && \
# #     cp EXAMPLE_commonPlugin_settings.req                        commonPlugin_settings.req && \
# #     sed -i s:'#NDPvaConfigure':'NDPvaConfigure':g               commonPlugins.cmd && \
# #     sed -i s:'#dbLoadRecords("NDPva':'dbLoadRecords("NDPva':g   commonPlugins.cmd && \
# #     sed -i s:'#startPVAServer':'startPVAServer':g               commonPlugins.cmd
# # # WORKDIR ${AREA_DETECTOR}/ADCore/ADApp/pluginSrc
# # # RUN sed -i s:'  DBD += NDPluginPva.dbd':'  DBD += NDPluginPva.dbd\n  DBD += softIocPVA.dbd':g               Makefile

# # WORKDIR ${AREA_DETECTOR}/ADSimDetector/iocs/simDetectorIOC/iocBoot/iocSimDetector
# # COPY run_simDetectorIOC ${AREA_DETECTOR}/ADSimDetector/iocs/simDetectorIOC/iocBoot/iocSimDetector/run
# # RUN cp ${XXX}/iocBoot/iocxxx/softioc/in-screen.sh .
# # # done editing

# # # archive the template IOC, for making new SimDetector IOCs
# # WORKDIR ${AREA_DETECTOR}/ADSimDetector/iocs/simDetectorIOC/iocBoot
# # RUN tar czf ${SUPPORT}/../iocSimDetector-3.7.tar.gz iocSimDetector

# # Build it all
# WORKDIR ${AREA_DETECTOR}
# RUN make -j2 all

# # WORKDIR ${SUPPORT}/iocSimDetector/
# # # build envPaths
# # RUN make

# WORKDIR ${SUPPORT}
