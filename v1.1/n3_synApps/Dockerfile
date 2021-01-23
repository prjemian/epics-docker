FROM  prjemian/epics-base-7.0.4.1
LABEL version="1.1.0" \
      maintainer="prjemian <prjemian@gmail.com>" \
      lastupdate="2021-01-21" \
      Description="see docs at https://github.com/prjemian/epics-docker/blob/master/n3_synApps/README.md"
USER  root
WORKDIR /home
RUN pwd && ls -lAFgh


RUN echo # start ------------------- OS update -------------------
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
RUN echo # end ------------------- OS update -------------------

# ============ parent image definitions ============
# additional software packages added here
ENV APP_ROOT="/opt"
# for use with `crontab -e`
ENV EDITOR="nano"
ENV EPICS_HOST_ARCH=linux-x86_64
ENV EPICS_ROOT="${APP_ROOT}/base"
ENV PATH="${PATH}:${EPICS_ROOT}/bin/${EPICS_HOST_ARCH}"

# ============ EPICS synApps ============
ENV SYNAPPS="${APP_ROOT}/synApps"
ENV SUPPORT="${SYNAPPS}/support"
ENV PATH="${PATH}:${SUPPORT}/utils"
ENV AD=${SUPPORT}/areaDetector-master
ENV MOTOR=${SUPPORT}/motor-master
ENV XXX=${SUPPORT}/xxx-master

# a directory for EPICS data (such as written from area detector IOCs)
RUN mkdir /data

RUN echo # start ------------------- assemble_synApps.sh -------------------
WORKDIR ${APP_ROOT}
RUN pwd && ls -lAFgh
# download the installer script
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
RUN pwd && ls -lAFgh
# # fix StreamDevice
# # use _released_ version of StreamDevice (master & 2.8.14 have build errors)
# # avoids: https://github.com/paulscherrerinstitute/StreamDevice/issues/56
# ENV STREAMDEVICE_RELEASE=2.8.12
# ENV STREAMDEVICE_DIR=StreamDevice-2-8-12
# RUN wget https://github.com/paulscherrerinstitute/StreamDevice/archive/${STREAMDEVICE_RELEASE}.tar.gz -O StreamDevice-${STREAMDEVICE_RELEASE}.tar.gz
# RUN tar xzf StreamDevice-${STREAMDEVICE_RELEASE}.tar.gz
# RUN mv StreamDevice-${STREAMDEVICE_RELEASE} ${STREAMDEVICE_DIR}
# RUN /bin/rm StreamDevice-${STREAMDEVICE_RELEASE}.tar.gz
RUN echo # end ------------------- assemble_synApps.sh -------------------


RUN echo # start ------------------- build synApps -------------------
WORKDIR ${SUPPORT}
RUN pwd && ls -lAFgh
RUN make -j4 release rebuild
# RUN make -C ${XXX}/iocBoot/iocxxx/
RUN echo # end ------------------- build synApps -------------------

# WORKDIR ${SYNAPPS}
# RUN ls -lAFgh
