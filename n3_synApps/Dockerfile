FROM  prjemian/epics-base-7.0.4
LABEL version="1.0.1" \
      maintainer="prjemian <prjemian@gmail.com>" \
      lastupdate="2020-05-10" \
      Description="see docs at https://github.com/prjemian/epics-docker/blob/master/n3_synApps/README.md"
USER  root
WORKDIR /home

RUN \
    apt-get update  -y && \
    apt-get install -y  \
       git \
       libnet-dev \
       libpcap-dev \
       libusb-1.0-0-dev \
       libusb-dev \
       libx11-dev \
       libxext-dev \
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
# synApps 6.1+ release
# ENV HASH=0623a478eae6c55a2378a8a07825b3a1c243b5ef
# 2020-04-08 (latest script revision at docker build time)
ENV HASH=master
ADD https://raw.githubusercontent.com/EPICS-synApps/support/${HASH}/assemble_synApps.sh ./
# edit the script first!
COPY ./ioc_scripts/edit_assemble_synApps.sh .
RUN bash edit_assemble_synApps.sh
# done editing
# review
RUN cat assemble_synApps.sh
# run the script now
RUN bash assemble_synApps.sh

WORKDIR ${SUPPORT}
# use _released_ version of StreamDevice (master & 2.8.14 have build errors)
# avoids: https://github.com/paulscherrerinstitute/StreamDevice/issues/56
RUN wget https://github.com/paulscherrerinstitute/StreamDevice/archive/2.8.12.tar.gz -O StreamDevice-2.8.12.tar.gz
RUN tar xzf StreamDevice-2.8.12.tar.gz
RUN mv StreamDevice-2.8.12 StreamDevice-2-8-12
RUN /bin/rm StreamDevice-2.8.12.tar.gz
RUN echo # end ------------------- assemble_synApps.sh -------------------

# --- configure and build synApps ---
ENV MOTOR=${SUPPORT}/motor-master
ENV XXX=${SUPPORT}/xxx-master
ENV PREFIX=xxx:

# fix for https://github.com/epics-modules/xxx/issues/30                                     ${XXX}/iocBoot/iocxxx/common.iocsh
COPY iocAdminSoft_aliases.db ${XXX}/xxxApp/Db
COPY iocAdminSoft_aliases.iocsh ${XXX}/iocBoot/iocxxx
RUN sed -i s+"IOC=\$(PREFIX)\")"+"IOC=\$(PREFIX)\")\n< iocAdminSoft_aliases.iocsh"+g ${XXX}/iocBoot/iocxxx/st.cmd.Linux

# grab all GUI screens (et al) into a top-level directory
WORKDIR ${SUPPORT}
COPY ./ioc_scripts/copy_screens.sh .
RUN \
    bash ./copy_screens.sh ${SUPPORT} ${SUPPORT}/screens && \
    ln -s ${SUPPORT}/screens /tmp/screens

# enable 16 motors and the scaler
WORKDIR ${XXX}/iocBoot/iocxxx/
COPY ./ioc_scripts/edit_ioc.sh .
RUN bash ./edit_ioc.sh

# configure area detector for PVA, qsrv, ...
ENV AD=${SUPPORT}/areaDetector-master
WORKDIR ${AD}
COPY ./ioc_scripts/edit_ad.sh .
RUN bash ./edit_ad.sh

# archive the template IOC, for making new XXX IOCs
WORKDIR ${SUPPORT}
RUN \
    tar czf ${SUPPORT}/../xxx-master.tar.gz xxx-master && \
    ln -s ${XXX}/iocBoot/iocxxx/ ./iocxxx

# Build it all
WORKDIR ${SUPPORT}
RUN \
    make -j4 release all && \
    make -C ${SUPPORT}/iocxxx/

# TODO: add components from start_xxx.sh here

WORKDIR ${SUPPORT}
