FROM  prjemian/os_only-1.1
LABEL version="1.1.0" \
      maintainer="prjemian <prjemian@gmail.com>" \
      lastupdate="2021-02-03"
USER  root
WORKDIR /home

# ============ parent image definitions ============
# additional software packages added here
ENV APP_ROOT="/opt"
# for use with `crontab -e`
ENV EDITOR="nano"

# ============ EPICS base ============
# Get the latest version of EPICS
ENV EPICS_BASE_NAME=base-7.0.4.1
ENV EPICS_BASE_DIR_NAME=base-R7.0.4.1

ENV EPICS_HOST_ARCH=linux-x86_64
ENV EPICS_ROOT="${APP_ROOT}/${EPICS_BASE_DIR_NAME}"
ENV PATH="${PATH}:${EPICS_ROOT}/bin/${EPICS_HOST_ARCH}"

WORKDIR /home
RUN pwd && ls -lAFgh
RUN echo # start ------------------- OS update -------------------
RUN \
    apt-get update  -y && \
    apt-get install -y  \
       python3-pip \
       && \
    pip3 install supervisor
RUN echo # end ------------------- OS update -------------------


WORKDIR ${APP_ROOT}
ADD https://epics.anl.gov/download/base/${EPICS_BASE_NAME}.tar.gz ./

RUN tar xzf ${EPICS_BASE_NAME}.tar.gz &&\
    rm  ${EPICS_BASE_NAME}.tar.gz &&\
    ln -s ${EPICS_BASE_DIR_NAME} base &&\
    ls -lAFgh

WORKDIR ${EPICS_ROOT}
RUN pwd && ls
RUN make -j4 all CFLAGS="-fPIC" CXXFLAGS="-fPIC"  2>&1 | tee build.log
RUN echo "# --- make clean ---" 2>&1 | tee -a build.log
RUN make clean  2>&1 | tee -a build.log

# build PVA and QSRV
# see https://docs.epics-controls.org/projects/pva2pva/en/latest/doxygen/
#WORKDIR ${EPICS_ROOT}/modules
#RUN make -j4

WORKDIR /tmp
RUN pwd && ls
COPY ioc_files/* /tmp/softIoc_base_demo/
CMD ["/bin/bash"]

WORKDIR ${EPICS_ROOT}
RUN pwd && ls
