FROM  ubuntu:latest
LABEL version="2.0.0" \
      maintainer="prjemian <prjemian@gmail.com>" \
      lastupdate="2023-03-31" \
      Description="source: https://github.com/prjemian/epics-docker/"
USER  root
CMD ["/bin/bash"]
WORKDIR /home

RUN echo "# -------------------------------- start OS install"
# Build EPICS software here
ENV APP_ROOT="/opt"
ENV RESOURCES="${APP_ROOT}/resources"
ENV LOG_DIR="${APP_ROOT}/logs"
RUN mkdir ${LOG_DIR}

# sysAdmin work: Install necessary libraries from offical repo
RUN DEBIAN_FRONTEND=noninteractive apt-get update  -y \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y  \
        apt-utils \
        build-essential \
        git \
        less \
        libnet-dev \
        libpcap-dev \
        libreadline-dev \
        libusb-1.0-0-dev \
        libusb-dev \
        libx11-dev \
        libxext-dev \
        nano \
        re2c \
        screen \
        vim \
        wget \
        \
    && rm -rf /var/lib/apt/lists/*

# for use with `crontab -e`
ENV EDITOR="nano"

# only show last few subdirs before console prompt
ENV PROMPT_DIRTRIM=3
RUN echo "# -------------------------------- end OS install"

RUN echo "# -------------------------------- start EPICS base"
COPY ./resources/epics_base.sh "${RESOURCES}/"
RUN "${RESOURCES}/epics_base.sh"
RUN echo "# -------------------------------- end EPICS base"

RUN echo "# -------------------------------- start EPICS synApps"
COPY ./resources/epics_synapps.sh "${RESOURCES}/"
COPY ./resources/edit_assemble_synApps.sh "${RESOURCES}/"
RUN "${RESOURCES}/epics_synapps.sh"
RUN echo "# -------------------------------- end EPICS synApps"

# TODO: collect the screen files
# TODO: add custom support for custom (GP) IOC
# TODO: add custom support for custom ADSimDetector IOC
# TODO: add custom support for custom pvaDriver IOC
# TODO: add custom support for custom ADURL IOC
