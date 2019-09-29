FROM  prjemian/epics-base-7.0.3
LABEL version="1.0.0" \
      maintainer="prjemian <prjemian@gmail.com>" \
      lastupdate="2019-09-28"
USER  root
WORKDIR /home

# Install libraries from offical repo needed by synApps
# * wget & git needed by assemble_synApps.sh
# * re2c needed overall
# * area detector needs:
#    * libusb (newer faster usb support)
#    * X11 (for GraphicsMagick)
# * run IOCs in screen sessions (base-os provides)
# * xvfb for remote GUI viewing

RUN \
    apt-get update  -y && \
    apt-get install -y  \
       git \
       libusb-dev \
       libusb-1.0-0-dev \
       libx11-dev \
       re2c \
       wget \
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
ENV EPICS_ROOT="/${APP_ROOT}/base"
ENV PATH="${PATH}:${EPICS_ROOT}/bin/${EPICS_HOST_ARCH}"

# ============ EPICS synApps ============
ENV SUPPORT="${APP_ROOT}/synApps/support"
ENV PATH="${PATH}:${SUPPORT}/utils"

WORKDIR ${APP_ROOT}
# synApps 6.1 release
ENV HASH=cc5adba5b8848c9cb98ab96768d668ae927d8859
ADD https://raw.githubusercontent.com/EPICS-synApps/support/${HASH}/assemble_synApps.sh ./

# edit the script first!
RUN sed -i s:'/APSshare/epics/base-3.15.6':'/opt/base':g assemble_synApps.sh
# do NOT build these for linux-x86_64
RUN sed -i s:'ALLENBRADLEY=':'#ALLENBRADLEY=':g         assemble_synApps.sh && \
    sed -i s:'AREA_DETECTOR=':'#AREA_DETECTOR=':g       assemble_synApps.sh && \
    sed -i s:'CAMAC=':'#CAMAC=':g                       assemble_synApps.sh && \
    sed -i s:'DAC128V=':'#DAC128V=':g                   assemble_synApps.sh && \
    sed -i s:'DELAYGEN=':'#DELAYGEN=':g                 assemble_synApps.sh && \
    sed -i s:'DXP=':'#DXP=':g                           assemble_synApps.sh && \
    sed -i s:'DXPSITORO=':'#DXPSITORO=':g               assemble_synApps.sh && \
    sed -i s:'IP330=':'#IP330=':g                       assemble_synApps.sh && \
    sed -i s:'IPUNIDIG=':'#IPUNIDIG=':g                 assemble_synApps.sh && \
    sed -i s:'LOVE=':'#LOVE=':g                         assemble_synApps.sh && \
    sed -i s:'QUADEM=':'#QUADEM=':g                     assemble_synApps.sh && \
    sed -i s:'SOFTGLUE=':'#SOFTGLUE=':g                 assemble_synApps.sh && \
    sed -i s:'SOFTGLUEZYNQ=':'#SOFTGLUEZYNQ=':g         assemble_synApps.sh && \
    sed -i s:'VME=':'#VME=':g                           assemble_synApps.sh && \
    sed -i s:'YOKOGAWA_DAS=':'#YOKOGAWA_DAS=':g         assemble_synApps.sh
# done editing

# review
RUN echo # start ------------------- assemble_synApps.sh -------------------
RUN cat assemble_synApps.sh
RUN echo # end ------------------- assemble_synApps.sh -------------------

# run the script now
RUN bash assemble_synApps.sh

# ENV AREA_DETECTOR=${SUPPORT}/areaDetector-R3-7
ENV MOTOR=${SUPPORT}/motor-R7-1
ENV XXX=${SUPPORT}/xxx-R6-1

WORKDIR ${SUPPORT}
# RUN ls -lAFgh

WORKDIR ${XXX}/iocBoot/iocxxx/
RUN cp examples/motors.iocsh ./ && \
    cp examples/std.iocsh    ./ && \
    cp ${MOTOR}/modules/motorMotorSim/iocsh/motorSim.iocsh                 ${MOTOR}/iocsh/ && \
    cp ${MOTOR}/modules/motorMotorSim/iocsh/EXAMPLE_motorSim.substitutions ${MOTOR}/iocsh/ && \
    sed -i s:'#iocshLoad("$(STD)/iocsh/softScaler':'iocshLoad("$(STD)/iocsh/softScaler':g std.iocsh && \
    sed -i s:'#iocshLoad("$(MOTOR)/iocsh/motorSim.iocsh"':'iocshLoad("$(MOTOR)/iocsh/motorSim.iocsh"':g motors.iocsh && \
    sed -i s:'dbLoadTemplate("substitutions/motor.substitutions"':'#dbLoadTemplate("substitutions/motor.substitutions"':g motors.iocsh && \
    sed -i s:'< common.iocsh':'< common.iocsh\n< std.iocsh\n< motors.iocsh':g st.cmd.Linux

# archive the template IOC, for making new XXX IOCs
WORKDIR ${SUPPORT}
RUN tar czf ${SUPPORT}/../xxx-R6-1.tar.gz xxx-R6-1 && \
    ln -s ${XXX}/iocBoot/iocxxx/ ./iocxxx

# Build it all
RUN make -j2 all

# WORKDIR ${SUPPORT}/iocxxx/
# # build envPaths
# RUN make

WORKDIR ${SUPPORT}
