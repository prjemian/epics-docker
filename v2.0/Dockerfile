FROM  debian:stable-slim
LABEL version="2.0.0" \
      maintainer="prjemian <prjemian@gmail.com>" \
      lastupdate="2023-04-06" \
      Description="source: https://github.com/prjemian/epics-docker/"
USER  root

RUN echo "# -------------------------------- customize command shell"
CMD ["/bin/bash"]
WORKDIR /home
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


RUN echo "# -------------------------------- start OS update" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"
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
COPY ./resources/copy_screens.sh "${RESOURCES}/"
COPY ./resources/modify_adl_in_ui_files.sh "${RESOURCES}/"
COPY ./resources/tarcopy.sh "${RESOURCES}/"
RUN echo "# -------------------------------- end script tools" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"

RUN echo "# -------------------------------- start EPICS synApps" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"
COPY ./resources/epics_synapps.sh "${RESOURCES}/"
COPY ./resources/edit_assemble_synApps.sh "${RESOURCES}/"
RUN "${RESOURCES}/epics_synapps.sh" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"
RUN echo "# -------------------------------- end EPICS synApps" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"

RUN echo "# -------------------------------- start create custom GP IOC" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"
COPY ./resources/general_purpose.db "${RESOURCES}/"
COPY ./resources/gp_asyn_motor.db.patch "${RESOURCES}/"
COPY ./resources/gp_add_general_purpose.sh "${RESOURCES}/"
COPY ./resources/gp_build_gp_sh.sh "${RESOURCES}/"
COPY ./resources/gp_screens/ /tmp/gp_screens
COPY ./resources/start_caQtDM.sh "${RESOURCES}/"
COPY ./resources/start_MEDM.sh "${RESOURCES}/"
COPY ./resources/custom_gp_ioc.sh "${RESOURCES}/"
RUN "${RESOURCES}/custom_gp_ioc.sh" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"
RUN echo "# -------------------------------- end create custom GP IOC" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"

RUN echo "# -------------------------------- start create custom ADSimDetector IOC" 2>&1 | tee -a "${LOG_DIR}/dockerfile.log"
COPY ./resources/adsim_README /tmp/
COPY ./resources/adsim_autosave.sh "${RESOURCES}/"
COPY ./resources/adsim_build_adsim_sh.sh "${RESOURCES}/"
COPY ./resources/adsim_copy_IOC.sh "${RESOURCES}/"
COPY ./resources/adsim_IOC_run_script.sh "${RESOURCES}/"
COPY ./resources/adsim_install_screens.sh "${RESOURCES}/"
COPY ./resources/adsim_plugins.sh "${RESOURCES}/"
COPY ./resources/adsim_prefix.sh "${RESOURCES}/"
COPY ./resources/adsim_run.sh "${RESOURCES}/"
COPY ./resources/adsim_st_base.sh "${RESOURCES}/"
COPY ./resources/adsim_screens/ /tmp/adsim_screens
COPY ./resources/custom_adsim_ioc.sh "${RESOURCES}/"
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
