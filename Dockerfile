FROM  debian:stable-slim
LABEL version="2.0.2" \
      maintainer="prjemian <prjemian@gmail.com>" \
      lastupdate="2023-04-07" \
      Description="source: https://github.com/prjemian/epics-docker/"
USER  root

RUN echo "# -------------------------------- customize command shell"
CMD ["/bin/bash"]
WORKDIR /home
ENV IMAGE_VERSION="2.0.2"
ENV PREFIX="ioc:"
ENV APP_ROOT="/opt"
ENV RESOURCES="${APP_ROOT}/resources"
ENV LOG_DIR="${APP_ROOT}/logs"
RUN \
    touch ~/.bashrc ~/.bash_aliases \
    && echo "if [ -f ~/.bash_aliases ]; then" >> ~/.bashrc \
    && echo "    . ~/.bash_aliases" >> ~/.bashrc \
    && echo "fi" >> ~/.bashrc \
    && echo "# file: ~/.bash_aliases" >> ~/.bash_aliases \
    && echo "export LS_OPTIONS='--color=auto'" >> ~/.bash_aliases \
    && echo "export EDITOR=nano" >> ~/.bash_aliases \
    && echo "export PATH=${PATH}:${HOME}/bin" >> ~/.bash_aliases \
    && echo "export PROMPT_DIRTRIM=3" >> ~/.bash_aliases \
    && echo "alias ls='ls --color=auto'" >> ~/.bash_aliases \
    && echo "alias ll='ls -lAFgh'" >> ~/.bash_aliases \
    && mkdir ~/bin "${LOG_DIR}"


RUN echo "# -------------------------------- update OS" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"
# Build EPICS software here
RUN \
    echo "export APP_ROOT=${APP_ROOT}" >> ~/.bash_aliases \
    && echo "export RESOURCES=${RESOURCES}" >> ~/.bash_aliases \
    && echo "export LOG_DIR=${LOG_DIR}" >> ~/.bash_aliases

# sysAdmin work: Install necessary libraries from offical repo
RUN echo "# update OS" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"
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
        2>&1 | tee -a "${LOG_DIR}/dockerfile.log"
RUN rm -rf /var/lib/apt/lists/*

# for use with `crontab -e`
ENV EDITOR="nano"

# only show last few subdirs before console prompt
ENV PROMPT_DIRTRIM=3
RUN echo "# -------------------------------- end OS install" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"

RUN echo "# -------------------------------- start EPICS base" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"
COPY ./resources/epics_base.sh "${RESOURCES}/"
RUN "${RESOURCES}/epics_base.sh" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"
RUN echo "# -------------------------------- end EPICS base" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"

RUN echo "# -------------------------------- start script tools" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"
# These scripts will be used by the scripts which create custom IOCs
COPY \
    ./resources/copy_screens.sh \
    ./resources/modify_adl_in_ui_files.sh \
    ./resources/tarcopy.sh \
    ${RESOURCES}/
RUN echo "# -------------------------------- end script tools" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"

RUN echo "# -------------------------------- start EPICS synApps" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"
COPY \
    ./resources/epics_synapps.sh \
    ./resources/edit_assemble_synApps.sh \
    ${RESOURCES}/
RUN "${RESOURCES}/epics_synapps.sh" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"
RUN echo "# -------------------------------- end EPICS synApps" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"

RUN echo "# -------------------------------- start create custom GP IOC" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"
# TODO: gather all into ./resources/gp/ folder and refactor
COPY ./resources/gp_screens/ /tmp/gp_screens
COPY \
    ./resources/general_purpose.db \
    ./resources/gp_asyn_motor.db.patch \
    ./resources/gp_add_general_purpose.sh \
    ./resources/gp_alive.sh \
    ./resources/gp_build_gp_sh.sh \
    ./resources/gp_copy_IOC.sh \
    ./resources/gp_iocStats.sh \
    ./resources/gp_install_screens.sh \
    ./resources/gp_make.sh \
    ./resources/gp_motors.sh \
    ./resources/gp_optics.sh \
    ./resources/gp_prefix.sh \
    ./resources/gp_std.sh \
    ./resources/start_caQtDM.sh \
    ./resources/start_MEDM.sh \
    ./resources/custom_gp_ioc.sh \
    ${RESOURCES}/
RUN "${RESOURCES}/custom_gp_ioc.sh" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"
RUN echo "# -------------------------------- end create custom GP IOC" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"

RUN echo "# -------------------------------- start create custom ADSimDetector IOC" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"
# TODO: gather all into ./resources/adsim/ folder and refactor
COPY ./resources/adsim_README /tmp/
COPY ./resources/adsim_screens/ /tmp/adsim_screens
COPY \
    ./resources/adsim_autosave.sh \
    ./resources/adsim_build_adsim_sh.sh \
    ./resources/adsim_copy_IOC.sh \
    ./resources/adsim_IOC_run_script.sh \
    ./resources/adsim_install_screens.sh \
    ./resources/adsim_plugins.sh \
    ./resources/adsim_prefix.sh \
    ./resources/adsim_run.sh \
    ./resources/adsim_st_base.sh \
    ./resources/custom_adsim_ioc.sh \
    ${RESOURCES}/
RUN "${RESOURCES}/custom_adsim_ioc.sh" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"
RUN echo "# -------------------------------- end create custom ADSimDetector IOC" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"

# RUN echo "# -------------------------------- start create custom pvaDriver IOC" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"
# # COPY ./resources/custom_adpva_ioc.sh "${RESOURCES}/"
# # RUN "${RESOURCES}/custom_adpva_ioc.sh" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"
# RUN echo "# -------------------------------- end create custom pvaDriver IOC" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"

# RUN echo "# -------------------------------- start create custom ADURL IOC" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"
# # COPY ./resources/custom_adurl_ioc.sh "${RESOURCES}/"
# # RUN "${RESOURCES}/custom_adurl_ioc.sh" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"
# RUN echo "# -------------------------------- end create custom ADURL IOC" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"

# TODO: add support to start/stop IOCs in containers
