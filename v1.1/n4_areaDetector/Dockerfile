                                                                                                      FROM  prjemian/synapps-6.2
LABEL version="1.1.0" \
      maintainer="prjemian <prjemian@gmail.com>" \
      lastupdate="2021-01-30" \
      Description="see docs at https://github.com/prjemian/epics-docker/blob/master/n4_areaDetector/README.md"
USER  root
WORKDIR /home

# Install libraries from offical repo needed by area detector
#    * libusb (newer faster usb support)
#    * X11 (for GraphicsMagick)
# * xvfb for remote GUI viewing
# * run IOCs in screen sessions (base-os provides)

RUN \
    apt-get update  -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y  \
       libx11-dev \
       x11-xserver-utils \
       xorg-dev \
       xvfb \
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
RUN pwd && ls -lAFgh
ENV AD_TAG=R3-10
ENV AREA_DETECTOR=${SUPPORT}/areaDetector-${AD_TAG}

# download components
ADD https://github.com/areaDetector/areaDetector/archive/${AD_TAG}.tar.gz ./areaDetector-${AD_TAG}.tar.gz
RUN \
    tar xzf areaDetector-${AD_TAG}.tar.gz && \
    /bin/rm areaDetector-${AD_TAG}.tar.gz && \
    echo "AREA_DETECTOR=\$(SUPPORT)/areaDetector-${AD_TAG}" >>  ${SUPPORT}/configure/RELEASE

# this page lists specific hashes for the AD R3-10 release
# https://github.com/areaDetector/areaDetector/tree/9739d42659d180f88e08104cad4d02cbd414a75f
ENV ADCORE_HASH=9321f2a
ENV ADSUPPORT_HASH=5c549858
ENV ADSIMDETECTOR_HASH=d24fa04
ENV AD_PVADRIVER_HASH=1f51a94
# TODO:
# ADURL
# ADViewers
# ffmpegServer
# NDDriverStdArrays
# ADPluginCentroids

WORKDIR ${AREA_DETECTOR}
RUN pwd && ls -lAFgh
ADD https://github.com/areaDetector/ADCore/archive/${ADCORE_HASH}.tar.gz ./ADCore.tar.gz
ADD https://github.com/areaDetector/ADSupport/archive/${ADSUPPORT_HASH}.tar.gz ./ADSupport.tar.gz
ADD https://github.com/areaDetector/ADSimDetector/archive/${ADSIMDETECTOR_HASH}.tar.gz ./ADSimDetector.tar.gz
ADD https://github.com/areaDetector/pvaDriver/archive/${AD_PVADRIVER_HASH}.tar.gz ./pvaDriver.tar.gz
RUN \
    rmdir ADCore && \
    rmdir ADSupport && \
    rmdir ADSimDetector && \
    rmdir pvaDriver && \
    tar xzf ADCore.tar.gz && \
    tar xzf ADSupport.tar.gz && \
    tar xzf ADSimDetector.tar.gz && \
    tar xzf pvaDriver.tar.gz && \
    /bin/rm ADCore.tar.gz && \
    /bin/rm ADSupport.tar.gz && \
    /bin/rm ADSimDetector.tar.gz && \
    /bin/rm pvaDriver.tar.gz && \
    ln -s ADCore-${ADCORE_HASH} ADCore && \
    ln -s ADSupport-${ADSUPPORT_HASH} ADSupport && \
    ln -s ADSimDetector-${ADSIMDETECTOR_HASH} ADSimDetector && \
    ln -s pvaDriver-${AD_PVADRIVER_HASH} pvaDriver

# # recommended edits: https://areadetector.github.io/master/install_guide.html
# WORKDIR ${AREA_DETECTOR}/configure
# RUN pwd && ls -lAFgh
# RUN cp EXAMPLE_RELEASE.local         RELEASE.local && \
#     cp EXAMPLE_RELEASE_SUPPORT.local RELEASE_SUPPORT.local && \
#     cp EXAMPLE_RELEASE_LIBS.local    RELEASE_LIBS.local && \
#     cp EXAMPLE_RELEASE_PRODS.local   RELEASE_PRODS.local && \
#     cp EXAMPLE_CONFIG_SITE.local     CONFIG_SITE.local && \
#     sed -i s:'#ADSIMDETECTOR=':'ADSIMDETECTOR=':g RELEASE.local && \
#     sed -i s:'#PVADRIVER=':'PVADRIVER=':g RELEASE.local && \
#     sed -i s:'SUPPORT=/corvette/home/epics/devel':'SUPPORT=/opt/synApps/support':g RELEASE_SUPPORT.local && \
#     sed -i s:'asyn-4-36':'asyn-R4-36':g RELEASE_LIBS.local && \
#     sed -i s:'areaDetector-3-7':'areaDetector-${AD_TAG}':g RELEASE_LIBS.local && \
#     sed -i s:'EPICS_BASE=/corvette/usr/local/epics-devel/base-7.0.3':'EPICS_BASE=/opt/base-7.0.3':g RELEASE_LIBS.local && \
#     sed -i s:'asyn-4-36':'asyn-R4-36':g RELEASE_PRODS.local && \
#     sed -i s:'areaDetector-3-7':'areaDetector-${AD_TAG}':g RELEASE_PRODS.local && \
#     sed -i s:'autosave-5-10':'autosave-R5-10':g RELEASE_PRODS.local && \
#     sed -i s:'busy-1-7-2':'busy-R1-7-2':g RELEASE_PRODS.local && \
#     sed -i s:'calc-3-7-3':'calc-R3-7-3':g RELEASE_PRODS.local && \
#     sed -i s:'seq-2-2-5':'seq-2-2-6':g RELEASE_PRODS.local && \
#     sed -i s:'sscan-2-11-3':'sscan-R2-11-3':g RELEASE_PRODS.local && \
#     sed -i s:'devIocStats-3-1-16':'iocStats-3-1-16':g RELEASE_PRODS.local && \
#     sed -i s:'EPICS_BASE=/corvette/usr/local/epics-devel/base-7.0.3':'EPICS_BASE=/opt/base-7.0.3':g RELEASE_PRODS.local
# WORKDIR ${AREA_DETECTOR}/ADCore/iocBoot
# RUN pwd && ls -lAFgh
# RUN cp EXAMPLE_commonPlugins.cmd                                commonPlugins.cmd && \
#     cp EXAMPLE_commonPlugin_settings.req                        commonPlugin_settings.req && \
#     sed -i s:'#NDPvaConfigure':'NDPvaConfigure':g               commonPlugins.cmd && \
#     sed -i s:'#dbLoadRecords("NDPva':'dbLoadRecords("NDPva':g   commonPlugins.cmd && \
#     sed -i s:'#startPVAServer':'startPVAServer':g               commonPlugins.cmd

# ENV IMAGE_IOC_BOOT_DIR=${AREA_DETECTOR}/ADSimDetector/iocs/simDetectorIOC/iocBoot/iocSimDetector

# WORKDIR ${IMAGE_IOC_BOOT_DIR}
# RUN pwd && ls -lAFgh
# COPY run_simDetectorIOC ${IMAGE_IOC_BOOT_DIR}/run
# COPY start_caQtDM_adsim ${IMAGE_IOC_BOOT_DIR}/
# RUN cp ${XXX}/iocBoot/iocxxx/softioc/in-screen.sh .

# WORKDIR ${SUPPORT}
# RUN pwd && ls -lAFgh
# ENV AD_PREFIX="13SIM1:"
# RUN \
#     ln -s ${AREA_DETECTOR}/ADSimDetector/iocs/simDetectorIOC/iocBoot/iocSimDetector ./iocSimDetector && \
#     cp iocxxx/softioc/xxx.sh ./iocSimDetector/simDetector.sh && \
#     sed -i s:'IOC_NAME=xxx':'IOC_NAME=simDetector':g   ./iocSimDetector/simDetector.sh && \
#     sed -i s:'IOC_BINARY=xxx':'IOC_BINARY=simDetectorApp':g   ./iocSimDetector/simDetector.sh && \
#     sed -i s:'IOC_STARTUP_DIR=/home/username/epics/ioc/synApps/xxx/iocBoot/iocxxx/softioc':'':g   ./iocSimDetector/simDetector.sh && \
#     sed -i s:'IOC_STARTUP_DIR=`dirname ${SNAME}`/..':'IOC_STARTUP_DIR=`dirname ${SNAME}`':g   ./iocSimDetector/simDetector.sh && \
#     sed -i s:'IOC_STARTUP_FILE="st.cmd.Linux"':'IOC_STARTUP_FILE="st.cmd"':g   ./iocSimDetector/simDetector.sh && \
#     sed -i s/'epicsEnvSet("PREFIX", "13SIM1:")'/'epicsEnvSet("PREFIX", \$\{AD_PREFIX})'/g   ./iocSimDetector/st_base.cmd && \
#     echo "\ndbl > dbl-all.txt" >> ./iocSimDetector/st_base.cmd
# # done editing

# WORKDIR ${SUPPORT}
# RUN make release

# # grab all GUI screens (et al) into a top-level directory
# WORKDIR ${SUPPORT}
# RUN pwd && ls -lAFgh
# RUN bash ./copy_screens.sh ${SUPPORT} ${SUPPORT}/screens

# # archive the unbuilt template IOC, for making new SimDetector IOCs
# WORKDIR ${AREA_DETECTOR}/ADSimDetector/iocs/simDetectorIOC/iocBoot
# RUN tar czf ${SUPPORT}/../iocSimDetector-3.7.tar.gz iocSimDetector

# # Build it all
# WORKDIR ${AREA_DETECTOR}
# RUN make -j4 all

# WORKDIR ${SUPPORT}
# CMD ["/bin/bash"]
