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
RUN sed -i s:'ALLENBRADLEY=':'#ALLENBRADLEY=':g assemble_synApps.sh && \
    sed -i s:'CAMAC=':'#CAMAC=':g assemble_synApps.sh && \
    sed -i s:'DAC128V=':'#DAC128V=':g assemble_synApps.sh && \
    sed -i s:'DELAYGEN=':'#DELAYGEN=':g assemble_synApps.sh && \
    sed -i s:'DXP=':'#DXP=':g assemble_synApps.sh && \
    sed -i s:'DXPSITORO=':'#DXPSITORO=':g assemble_synApps.sh && \
    sed -i s:'IP330=':'#IP330=':g assemble_synApps.sh && \
    sed -i s:'IPUNIDIG=':'#IPUNIDIG=':g assemble_synApps.sh && \
    sed -i s:'LOVE=':'#LOVE=':g assemble_synApps.sh && \
    sed -i s:'QUADEM=':'#QUADEM=':g assemble_synApps.sh && \
    sed -i s:'SOFTGLUE=':'#SOFTGLUE=':g assemble_synApps.sh && \
    sed -i s:'SOFTGLUEZYNQ=':'#SOFTGLUEZYNQ=':g assemble_synApps.sh && \
    sed -i s:'VME=':'#VME=':g assemble_synApps.sh && \
    sed -i s:'YOKOGAWA_DAS=':'#YOKOGAWA_DAS=':g assemble_synApps.sh
# done editing

# review
RUN echo # start ------------------- assemble_synApps.sh -------------------
RUN cat assemble_synApps.sh
RUN echo # end ------------------- assemble_synApps.sh -------------------

# run the script now
RUN bash assemble_synApps.sh

ENV AREA_DETECTOR=${SUPPORT}/areaDetector-R3-7
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


# recommended edits: https://areadetector.github.io/master/install_guide.html
WORKDIR ${AREA_DETECTOR}/configure
RUN cp EXAMPLE_RELEASE.local         RELEASE.local && \
    cp EXAMPLE_RELEASE_SUPPORT.local RELEASE_SUPPORT.local && \
    cp EXAMPLE_RELEASE_LIBS.local    RELEASE_LIBS.local && \
    cp EXAMPLE_RELEASE_PRODS.local   RELEASE_PRODS.local && \
    cp EXAMPLE_CONFIG_SITE.local     CONFIG_SITE.local && \
    sed -i s:'#ADSIMDETECTOR=':'ADSIMDETECTOR=':g RELEASE.local && \
    sed -i s:'#PVADRIVER=':'PVADRIVER=':g RELEASE.local && \
    sed -i s:'SUPPORT=/corvette/home/epics/devel':'SUPPORT=/opt/synApps/support':g RELEASE_SUPPORT.local && \
    sed -i s:'asyn-4-36':'asyn-R4-36':g RELEASE_LIBS.local && \
    sed -i s:'areaDetector-3-7':'areaDetector-R3-7':g RELEASE_LIBS.local && \
    sed -i s:'EPICS_BASE=/corvette/usr/local/epics-devel/base-7.0.3':'EPICS_BASE=/opt/base-7.0.3':g RELEASE_LIBS.local && \
    sed -i s:'asyn-4-36':'asyn-R4-36':g RELEASE_PRODS.local && \
    sed -i s:'areaDetector-3-7':'areaDetector-R3-7':g RELEASE_PRODS.local && \
    sed -i s:'autosave-5-10':'autosave-R5-10':g RELEASE_PRODS.local && \
    sed -i s:'busy-1-7-2':'busy-R1-7-2':g RELEASE_PRODS.local && \
    sed -i s:'calc-3-7-3':'calc-R3-7-3':g RELEASE_PRODS.local && \
    sed -i s:'seq-2-2-5':'seq-2-2-6':g RELEASE_PRODS.local && \
    sed -i s:'sscan-2-11-3':'sscan-R2-11-3':g RELEASE_PRODS.local && \
    sed -i s:'devIocStats-3-1-16':'iocStats-3-1-16':g RELEASE_PRODS.local && \
    sed -i s:'EPICS_BASE=/corvette/usr/local/epics-devel/base-7.0.3':'EPICS_BASE=/opt/base-7.0.3':g RELEASE_PRODS.local
WORKDIR ${AREA_DETECTOR}/ADCore/iocBoot
RUN cp EXAMPLE_commonPlugins.cmd                                commonPlugins.cmd && \
    cp EXAMPLE_commonPlugin_settings.req                        commonPlugin_settings.req && \
    sed -i s:'#NDPvaConfigure':'NDPvaConfigure':g               commonPlugins.cmd && \
    sed -i s:'#dbLoadRecords("NDPva':'dbLoadRecords("NDPva':g   commonPlugins.cmd && \
    sed -i s:'#startPVAServer':'startPVAServer':g               commonPlugins.cmd
# WORKDIR ${AREA_DETECTOR}/ADCore/ADApp/pluginSrc
# RUN sed -i s:'  DBD += NDPluginPva.dbd':'  DBD += NDPluginPva.dbd\n  DBD += softIocPVA.dbd':g               Makefile

COPY run_simDetectorIOC ${AREA_DETECTOR}/ADSimDetector/iocs/simDetectorIOC/iocBoot/iocSimDetector/run
RUN cp \
    ${XXX}/iocBoot/iocxxx/softioc/in-screen.sh \
    ${AREA_DETECTOR}/ADSimDetector/iocs/simDetectorIOC/iocBoot/iocSimDetector.
# done editing


# archive the template IOC, for making new SimDetector IOCs
WORKDIR ${AREA_DETECTOR}/ADSimDetector/iocs/simDetectorIOC/iocBoot
RUN tar czf ${SUPPORT}/../iocSimDetector-3.7.tar.gz iocSimDetector

# archive the template IOC, for making new XXX IOCs
WORKDIR ${SUPPORT}
RUN tar czf ${SUPPORT}/../xxx-R6-1.tar.gz xxx-R6-1 && \
    ln -s ${XXX}/iocBoot/iocxxx/ ./iocxxx && \
    ln -s ${AREA_DETECTOR}/ADSimDetector/iocs/simDetectorIOC/iocBoot/iocSimDetector/ ./iocSimDetector

# Build it all
RUN make -j2 all && \
    make clean

# WORKDIR ${SUPPORT}/iocxxx/
# # build envPaths
# RUN make

# WORKDIR ${SUPPORT}/iocSimDetector/
# # build envPaths
# RUN make

# WORKDIR ${SUPPORT}

# # FIXME: boot error remains
#     # # Optional: load NDPluginPva plugin
#     # NDPvaConfigure("PVA1", 20, 0, "SIM1", 0, 13SIM1:Pva1:Image, 0, 0, 0)
#     # commonPlugins.cmd line 171: Command NDPvaConfigure not found.
#     # dbLoadRecords("NDPva.template",  "P=13SIM1:,R=Pva1:, PORT=PVA1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=SIM1")
#     # # Must start PVA server if this is enabled
#     # startPVAServer
#     # commonPlugins.cmd line 174: Command startPVAServer not found.

#     # and

#     # 13SIM1:Pva1:ADCoreVersion_RBV devAsynOctet::initCommon connectDevice failed asynManager:connectDevice port PVA1 not found
#     # 13SIM1:Pva1:DriverVersion_RBV devAsynOctet::initCommon connectDevice failed asynManager:connectDevice port PVA1 not found
#     # 13SIM1:Pva1:PortName_RBV devAsynOctet::initCommon connectDevice failed asynManager:connectDevice port PVA1 not found

# # startPVAServer comes from EPICS base
# #   <base>/dbd/softIocPVA.dbd:registrar(registerStartPVAServer)
# # Something needs to be configured (?in ADCore?) 
# #    to make sure this is added to the build
