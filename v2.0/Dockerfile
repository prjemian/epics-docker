FROM  debian:stable-slim
LABEL version="2.0.0" \
      maintainer="prjemian <prjemian@gmail.com>" \
      lastupdate="2023-03-31" \
      Description="source: https://github.com/prjemian/epics-docker/"
USER  root

RUN echo "# -------------------------------- customize command shell"
CMD ["/bin/bash"]
WORKDIR /home
RUN \
    touch ~/.bashrc ~/.bash_aliases \
    && echo "if [ -f ~/.bash_aliases ]; then" >> ~/.bashrc \
    && echo "    . ~/.bash_aliases" >> ~/.bashrc \
    && echo "fi" >> ~/.bashrc \
    && echo "export LS_OPTIONS='--color=auto'" >> ~/.bash_aliases \
    && echo "export EDITOR=nano" >> ~/.bash_aliases \
    && echo "export PROMPT_DIRTRIM=3" >> ~/.bash_aliases \
    && echo "alias ls='ls --color=auto'" >> ~/.bash_aliases \
    && echo "alias ll='ls -lAFgh'" >> ~/.bash_aliases


RUN echo "# -------------------------------- start OS update"
# Build EPICS software here
ENV APP_ROOT="/opt"
ENV RESOURCES="${APP_ROOT}/resources"
ENV LOG_DIR="${APP_ROOT}/logs"
RUN \
    mkdir ${LOG_DIR} \
    && echo "export APP_ROOT=${APP_ROOT}" >> ~/.bash_aliases \
    && echo "export RESOURCES=${RESOURCES}" >> ~/.bash_aliases \
    && echo "export LOG_DIR=${LOG_DIR}" >> ~/.bash_aliases

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
        procps \
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

RUN echo "# -------------------------------- start GUI screens"
# These scripts will be used by the scripts which create custom IOCs
COPY ./resources/copy_screens.sh "${RESOURCES}/"
COPY ./resources/modify_adl_in_ui_files.sh "${RESOURCES}/"
RUN echo "# -------------------------------- end GUI screens"

RUN echo "# -------------------------------- start create GP IOC"
COPY ./resources/create_gp_ioc.sh "${RESOURCES}/"
COPY ./resources/general_purpose.db /tmp/
RUN "${RESOURCES}/create_gp_ioc.sh" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"
RUN echo "# -------------------------------- end create GP IOC"

# TODO: add custom support for custom (GP) IOC
# TODO: add custom support for custom ADSimDetector IOC
# TODO: add custom support for custom pvaDriver IOC
# TODO: add custom support for custom ADURL IOC
# TODO: add support to start/stop IOCs in containers
