FROM  prjemian/synapps-6.2
LABEL version="1.1.0" \
      maintainer="prjemian <prjemian@gmail.com>" \
      Description="source: https://github.com/prjemian/epics-docker/"
USER  root
WORKDIR /home

# Install libraries from offical repo needed by area detector
#    * libusb (newer faster usb support)
#    * X11 (for GraphicsMagick)
# * xvfb for remote GUI viewing
# * run IOCs in screen sessions (base-os provides)

RUN \
    DEBIAN_FRONTEND=noninteractive apt-get update  -y && \
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

# TODO: EPICS 7.0.5 tightened rules and now GraphicsMagick won't build from AD3.10
# Need to use master branch now
# # this page lists specific hashes for the AD R3-10 release
# # https://github.com/areaDetector/areaDetector/tree/9739d42659d180f88e08104cad4d02cbd414a75f
# ENV ADCORE_HASH=9321f2a
# ENV ADSUPPORT_HASH=5c549858
# ENV ADSIMDETECTOR_HASH=d24fa04
# ENV AD_PVADRIVER_HASH=1f51a94
# ENV ADURL_HASH=031794e
# ENV ADVIEWERS_HASH=3fe0c51
# ENV AD_FFMPEGSERVER_HASH=063bedd
ENV ADCORE_HASH=master
ENV ADSUPPORT_HASH=master
ENV ADSIMDETECTOR_HASH=master
ENV AD_PVADRIVER_HASH=master
ENV ADURL_HASH=master
ENV ADVIEWERS_HASH=master
ENV AD_FFMPEGSERVER_HASH=master

WORKDIR ${AREA_DETECTOR}
RUN pwd && ls -lAFgh
ADD https://github.com/areaDetector/ADCore/archive/${ADCORE_HASH}.tar.gz ./ADCore.tar.gz
ADD https://github.com/areaDetector/ADSupport/archive/${ADSUPPORT_HASH}.tar.gz ./ADSupport.tar.gz
ADD https://github.com/areaDetector/ADSimDetector/archive/${ADSIMDETECTOR_HASH}.tar.gz ./ADSimDetector.tar.gz
ADD https://github.com/areaDetector/pvaDriver/archive/${AD_PVADRIVER_HASH}.tar.gz ./pvaDriver.tar.gz
ADD https://github.com/areaDetector/ADURL/archive/${ADURL_HASH}.tar.gz ./ADURL.tar.gz
ADD https://github.com/areaDetector/ADViewers/archive/${ADVIEWERS_HASH}.tar.gz ./ADViewers.tar.gz
ADD https://github.com/areaDetector/ffmpegServer/archive/${AD_FFMPEGSERVER_HASH}.tar.gz ./ffmpegServer.tar.gz
COPY ioc_files/rearrange_AD_dirs.sh /opt
RUN /opt/rearrange_AD_dirs.sh 2>&1 | tee /opt/rearrange_AD_dirs.log

# recommended edits: https://areadetector.github.io/master/install_guide.html
WORKDIR ${AREA_DETECTOR}/configure
RUN pwd && ls -lAFgh
COPY ioc_files/recommended_AD_edits.sh /opt
RUN /opt/recommended_AD_edits.sh 2>&1 | tee /opt/recommended_AD_edits.log

ENV IOCADSIMDETECTOR=${AREA_DETECTOR}/ADSimDetector/iocs/simDetectorIOC/iocBoot/iocSimDetector
RUN ln -s ${IOCADSIMDETECTOR} ${SUPPORT}/iocSimDetector
RUN ln -s ${IOCADSIMDETECTOR} /opt/iocSimDetector
COPY ioc_files/run_simDetectorIOC ${IOCADSIMDETECTOR}/run
COPY ioc_files/runADSimDetector.sh /opt/

ENV IOCADURL=${AREA_DETECTOR}/ADURL/iocs/urlIOC/iocBoot/iocURLDriver
RUN ln -s ${IOCADURL} ${SUPPORT}/iocURLDriver
RUN ln -s ${IOCADURL} /opt/iocURLDriver
COPY ioc_files/run_adUrlIOC ${IOCADURL}/run
COPY ioc_files/runADURL.sh /opt/

WORKDIR ${SUPPORT}
RUN pwd && ls -lAFgh
RUN make release
RUN bash /opt/copy_screens.sh ${SUPPORT} /opt/screens | tee -a /opt/copy_screens.log
RUN bash /opt/modify_adl_in_ui_files.sh  /opt/screens/ui

# Build it all
WORKDIR ${AREA_DETECTOR}
RUN pwd && ls -lAFgh
RUN make -j4 all 2>&1 | tee makelog.txt

WORKDIR ${SUPPORT}
RUN pwd && ls -lAFgh
CMD ["/bin/bash"]
