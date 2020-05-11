FROM  prjemian/epics-base-7.0.3.1
LABEL version="1.0.1" \
      maintainer="prjemian <prjemian@gmail.com>" \
      lastupdate="2020-05-10" \
      Description="see docs at https://github.com/prjemian/epics-docker/blob/master/n3_synApps/README.md"
USER  root
WORKDIR /home

# Install libraries from offical repo needed by synApps
# * wget & git needed by assemble_synApps.sh
# * re2c needed overall
# * mca needs:
#    * libusb (newer faster usb support)
# * run IOCs in screen sessions (base-os provides)

RUN \
    apt-get update  -y && \
    apt-get install -y  \
       git \
       libusb-dev \
       libusb-1.0-0-dev \
       re2c \
       wget \
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

# ============ EPICS synApps ============
ENV SUPPORT="${APP_ROOT}/synApps/support"
ENV PATH="${PATH}:${SUPPORT}/utils"

WORKDIR ${APP_ROOT}
# synApps 6.1 release
# ENV HASH=cc5adba5b8848c9cb98ab96768d668ae927d8859
# latest
ENV HASH=master
ADD https://raw.githubusercontent.com/EPICS-synApps/support/${HASH}/assemble_synApps.sh ./

# edit the script first!
RUN sed -i s:'/APSshare/epics/base-3.15.6':'/opt/base':g assemble_synApps.sh

ENV _MODULES_=ALLENBRADLEY
ENV _MODULES_+=" CAMAC"

# do NOT build these for linux-x86_64
RUN sed -i s:'ALLENBRADLEY=':'#ALLENBRADLEY=':g         assemble_synApps.sh && \
    sed -i s:'CAMAC=':'#CAMAC=':g                       assemble_synApps.sh && \
    sed -i s:'DAC128V=':'#DAC128V=':g                   assemble_synApps.sh && \
    sed -i s:'DELAYGEN=':'#DELAYGEN=':g                 assemble_synApps.sh && \
    sed -i s:'DXP=':'#DXP=':g                           assemble_synApps.sh && \
    sed -i s:'DXPSITORO=':'#DXPSITORO=':g               assemble_synApps.sh && \
    sed -i s:'GALIL=':'#GALIL=':g                       assemble_synApps.sh && \
    sed -i s:'IP330=':'#IP330=':g                       assemble_synApps.sh && \
    sed -i s:'IPUNIDIG=':'#IPUNIDIG=':g                 assemble_synApps.sh && \
    sed -i s:'LOVE=':'#LOVE=':g                         assemble_synApps.sh && \
    sed -i s:'MEASCOMP=':'#MEASCOMP=':g                 assemble_synApps.sh && \
    sed -i s:'QUADEM=':'#QUADEM=':g                     assemble_synApps.sh && \
    sed -i s:'SOFTGLUE=':'#SOFTGLUE=':g                 assemble_synApps.sh && \
    sed -i s:'SOFTGLUEZYNQ=':'#SOFTGLUEZYNQ=':g         assemble_synApps.sh && \
    sed -i s:'VAC=':'#VAC=':g                           assemble_synApps.sh && \
    sed -i s:'VME=':'#VME=':g                           assemble_synApps.sh && \
    sed -i s:'YOKOGAWA_DAS=':'#YOKOGAWA_DAS=':g         assemble_synApps.sh
    # for i in x y z; do echo "$i"; done
# TODO: install "master" for the other modules
#  grep for line that starts with module= and replace whole line with module=master
#  example:   sed -i s:'^MOTOR=\S*$':'MOTOR=master':g 
#  implement with a for loop and list of modules
# Q: for loop in Dockerfile?
# A: YES --  https://stackoverflow.com/questions/39496017/iterate-in-run-command-in-dockerfile

# ALIVE
# AREA_DETECTOR
# ASYN
# AUTOSAVE
# BUSY
# CALC
# CAMAC
# CAPUTRECORDER
# DEVIOCSTATS
# IP
# IPAC
# LUA
# MCA
# MODBUS
# MOTOR
# OPTICS
# SNCSEQ
# SSCAN
# STD
# STREAM
# XXX

# FIXME: stop the build at this point

# # done editing

# # review
# RUN echo # start ------------------- assemble_synApps.sh -------------------
# RUN cat assemble_synApps.sh
# RUN echo # end ------------------- assemble_synApps.sh -------------------

# # run the script now
# RUN bash assemble_synApps.sh

# ENV MOTOR=${SUPPORT}/motor-R7-1
# ENV XXX=${SUPPORT}/xxx-R6-1
# ENV PREFIX=xxx:

# # enable 16 motors and the scaler
# WORKDIR ${XXX}/iocBoot/iocxxx/
# RUN cp examples/motors.iocsh ./ && \
#     cp examples/std.iocsh    ./ && \
#     cp ${MOTOR}/modules/motorMotorSim/iocsh/motorSim.iocsh                 ${MOTOR}/iocsh/ && \
#     cp ${MOTOR}/modules/motorMotorSim/iocsh/EXAMPLE_motorSim.substitutions ${MOTOR}/iocsh/ && \
#     sed -i s:'#iocshLoad("$(STD)/iocsh/softScaler':'iocshLoad("$(STD)/iocsh/softScaler':g std.iocsh && \
#     sed -i s:'#iocshLoad("$(MOTOR)/iocsh/motorSim.iocsh"':'iocshLoad("$(MOTOR)/iocsh/motorSim.iocsh"':g motors.iocsh && \
#     sed -i s:'dbLoadTemplate("substitutions/motor.substitutions"':'#dbLoadTemplate("substitutions/motor.substitutions"':g motors.iocsh
# # remove when https://github.com/epics-modules/xxx/pull/27 is merged and released in new synApps version
# RUN sed -i s:'< common.iocsh':'< common.iocsh\n< std.iocsh\n< motors.iocsh':g    ${XXX}/iocBoot/iocxxx/st.cmd.Linux
# # remove when https://github.com/epics-modules/xxx/pull/25 is merged and released in new synApps version
# RUN \
#     sed -i s:'if \[\[ ${s_pid} -eq ${P_PID} ]] ; then':'if \[ ${s_pid} -eq ${P_PID} ] ; then':g     ${XXX}/iocBoot/iocxxx/softioc/xxx.sh && \
#     sed -i s:'if \[\[ ${s_pid} -eq ${GP_PID} ]] ; then':'if \[ ${s_pid} -eq ${GP_PID} ] ; then':g   ${XXX}/iocBoot/iocxxx/softioc/xxx.sh
# RUN \
#     sed -i s/'epicsEnvSet("PREFIX", "xxx:")'/'epicsEnvSet("PREFIX", $(PREFIX))'/g   ${XXX}/iocBoot/iocxxx/common.iocsh && \
#     sed -i s:'IOC=xxx':'IOC=$(PREFIX)':g                                            ${XXX}/iocBoot/iocxxx/st.cmd.Linux
# # fix for https://github.com/epics-modules/xxx/issues/30                                     ${XXX}/iocBoot/iocxxx/common.iocsh
# COPY iocAdminSoft_aliases.db ${XXX}/xxxApp/Db
# COPY iocAdminSoft_aliases.iocsh ${XXX}/iocBoot/iocxxx
# RUN sed -i s+"IOC=\$(PREFIX)\")"+"IOC=\$(PREFIX)\")\n< iocAdminSoft_aliases.iocsh"+g ${XXX}/iocBoot/iocxxx/st.cmd.Linux

# # grab all GUI screens (et al) into a top-level directory
# WORKDIR ${SUPPORT}
# COPY copy_screens.sh .
# RUN bash ./copy_screens.sh ${SUPPORT} ${SUPPORT}/screens

# # archive the template IOC, for making new XXX IOCs
# WORKDIR ${SUPPORT}
# RUN \
#     tar czf ${SUPPORT}/../xxx-R6-1.tar.gz xxx-R6-1 && \
#     ln -s ${XXX}/iocBoot/iocxxx/ ./iocxxx

# # Build it all
# RUN \
#     make -j4 all && \
#     make -C ${SUPPORT}/iocxxx/

# WORKDIR ${SUPPORT}
