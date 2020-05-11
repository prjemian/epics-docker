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

RUN echo # start ------------------- assemble_synApps.sh -------------------
WORKDIR ${APP_ROOT}
# download the installer script
# synApps 6.1 release
# ENV HASH=cc5adba5b8848c9cb98ab96768d668ae927d8859
# latest
ENV HASH=master
ADD https://raw.githubusercontent.com/EPICS-synApps/support/${HASH}/assemble_synApps.sh ./
# edit the script first!
COPY edit_assemble_synApps.sh .
RUN bash edit_assemble_synApps.sh
# done editing
# review
RUN cat assemble_synApps.sh
# run the script now
RUN bash assemble_synApps.sh
RUN echo # end ------------------- assemble_synApps.sh -------------------

# --- configure and build synApps ---
ENV MOTOR=${SUPPORT}/motor-R7-1
ENV XXX=${SUPPORT}/xxx-R6-1
ENV PREFIX=xxx:

# # TODO: convert these lines into a bash script
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

# # TODO: convert these lines into a bash script
# # grab all GUI screens (et al) into a top-level directory
# # TODO: soft link to directory in /tmp
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

# # TODO: add components from start_xxx.sh here

# WORKDIR ${SUPPORT}
