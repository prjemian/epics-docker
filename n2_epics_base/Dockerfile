FROM  prjemian/os_only
LABEL version="1.0.1" \
      maintainer="prjemian <prjemian@gmail.com>" \
      lastupdate="2020-05-11"
USER  root
WORKDIR /home

# ============ parent image definitions ============
# additional software packages added here
ENV APP_ROOT="/opt"
# for use with `crontab -e`
ENV EDITOR="nano"

# ============ EPICS base ============
# Get the latest version of EPICS
ENV EPICS_HOST_ARCH=linux-x86_64
ENV EPICS_ROOT="${APP_ROOT}/base"
ENV PATH="${PATH}:${EPICS_ROOT}/bin/${EPICS_HOST_ARCH}"

ENV EPICS_BASE_NAME=base-7.0.3.1

WORKDIR ${APP_ROOT}
ADD https://epics.anl.gov/download/base/${EPICS_BASE_NAME}.tar.gz ./

RUN tar xzf ${EPICS_BASE_NAME}.tar.gz &&\
    rm  ${EPICS_BASE_NAME}.tar.gz &&\
    ln -s ${EPICS_BASE_NAME} base

WORKDIR ${EPICS_ROOT}
RUN make -j4 CFLAGS="-fPIC" CXXFLAGS="-fPIC" &&\
    make clean
