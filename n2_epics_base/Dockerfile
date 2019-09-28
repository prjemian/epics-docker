FROM  prjemian/os_only
LABEL version="1.0.0" \
      maintainer="prjemian <prjemian@gmail.com>" \
      lastupdate="2019-09-28"
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

WORKDIR ${APP_ROOT}
ADD https://epics.anl.gov/download/base/base-7.0.3.tar.gz ./

RUN tar xzf base-7.0.3.tar.gz &&\
    rm  base-7.0.3.tar.gz &&\
    ln -s base-7.0.3 base

WORKDIR ${EPICS_ROOT}
RUN make -j4 CFLAGS="-fPIC" CXXFLAGS="-fPIC" &&\
    make clean
