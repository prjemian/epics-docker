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
COPY ioc_files/rearrange_AD_dirs.sh /opt
RUN /opt/rearrange_AD_dirs.sh 2>&1 | tee /opt/rearrange_AD_dirs.log

# recommended edits: https://areadetector.github.io/master/install_guide.html
WORKDIR ${AREA_DETECTOR}/configure
RUN pwd && ls -lAFgh
COPY ioc_files/recommended_AD_edits.sh /opt
RUN /opt/recommended_AD_edits.sh 2>&1 | tee /opt/recommended_AD_edits.log

ENV ADSIMDETECTOR_IOC_BOOT_DIR=${AREA_DETECTOR}/ADSimDetector/iocs/simDetectorIOC/iocBoot/iocSimDetector

WORKDIR ${ADSIMDETECTOR_IOC_BOOT_DIR}
RUN pwd && ls -lAFgh
COPY run_simDetectorIOC ${ADSIMDETECTOR_IOC_BOOT_DIR}/run
COPY start_caQtDM_adsim ${ADSIMDETECTOR_IOC_BOOT_DIR}/
RUN cp ${XXX}/iocBoot/iocxxx/softioc/in-screen.sh .

# TODO: for the custom IOC
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

WORKDIR ${SUPPORT}
RUN make release

# TODO: for the custom IOC
# # grab all GUI screens (et al) into a top-level directory
# WORKDIR ${SUPPORT}
# RUN pwd && ls -lAFgh
# RUN bash ./copy_screens.sh ${SUPPORT} ${SUPPORT}/screens

# TODO: for the custom IOC
# # archive the unbuilt template IOC, for making new SimDetector IOCs
# WORKDIR ${AREA_DETECTOR}/ADSimDetector/iocs/simDetectorIOC/iocBoot
# RUN tar czf ${SUPPORT}/../iocSimDetector-3.7.tar.gz iocSimDetector

# Build it all
WORKDIR ${AREA_DETECTOR}
RUN make -j4 all 2>&1 | tee makelog.txt

WORKDIR ${SUPPORT}
CMD ["/bin/bash"]
