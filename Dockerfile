# syntax=docker/dockerfile:1
#
# v3 multi-stage build: base-os -> base-epics -> base-synapps
#
# Stages:
#   os-runtime   : Debian + runtime-only deps (procServ, libs). Small.
#   os-build     : os-runtime + toolchain (compilers, headers). Build only.
#   epics-build  : builds EPICS base from source in os-build.
#   base-epics   : runtime image with EPICS base only (softIoc persona).
#   synapps-build: builds synApps support tree + xxx IOC on top of base.
#   base-synapps : runtime image with EPICS base + synApps.
#
# All versions come from build ARGs, fed by versions.env via the Makefile.
# Do not hard-code versions here; edit versions.env instead.

ARG DEBIAN_TAG=12-slim

# ----------------------------------------------------------------------
# os-runtime: minimal runtime layer (no compilers). Basis of final image.
# ----------------------------------------------------------------------
FROM debian:${DEBIAN_TAG} AS os-runtime

ARG IMAGE_VERSION=dev
LABEL org.opencontainers.image.title="prjemian/synapps" \
      org.opencontainers.image.description="EPICS base (+ synApps, areaDetector) IOCs for development, simulation, testing, training" \
      org.opencontainers.image.source="https://github.com/prjemian/epics-docker" \
      org.opencontainers.image.version="${IMAGE_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive \
    APP_ROOT=/opt \
    EPICS_ROOT=/opt/epics \
    LOG_DIR=/opt/build-logs \
    LANG=C.UTF-8

# Retained build logs (valuable later diagnostics) live here in every stage.
RUN mkdir -p "${LOG_DIR}"

# Runtime-only packages. procServ supervises the IOC (replaces `screen`).
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
 && apt-get install -y --no-install-recommends \
        ca-certificates \
        libreadline8 \
        procserv \
        telnet \
 && rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------------------------
# os-build: add the toolchain needed to compile EPICS from source.
# ----------------------------------------------------------------------
FROM os-runtime AS os-build

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
 && apt-get install -y --no-install-recommends \
        build-essential \
        git \
        libreadline-dev \
        perl \
        re2c \
        wget \
        # areaDetector / synApps build dependencies:
        libgraphicsmagick++1-dev \
        libtiff-dev \
        libjpeg-dev \
        libnetcdf-dev \
        libxml2-dev \
        libx11-dev \
        libxext-dev \
        zlib1g-dev \
        libusb-1.0-0-dev \
 && rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------------------------
# epics-build: download and build EPICS base.
# ----------------------------------------------------------------------
FROM os-build AS epics-build

ARG EPICS_BASE_VERSION
ENV EPICS_BASE=${EPICS_ROOT}/base

RUN mkdir -p "${EPICS_ROOT}" \
 && cd "${EPICS_ROOT}" \
 && wget -q "https://epics.anl.gov/download/base/base-${EPICS_BASE_VERSION}.tar.gz" \
 && tar xzf "base-${EPICS_BASE_VERSION}.tar.gz" \
 && rm "base-${EPICS_BASE_VERSION}.tar.gz" \
 && ln -s "base-${EPICS_BASE_VERSION}" base

# Build; retain full log in ${LOG_DIR} for later diagnostics.
# Use bash+pipefail explicitly: podman's default OCI image format ignores the
# `SHELL` directive, so a piped `make | tee` would otherwise mask make failures.
RUN bash -o pipefail -c 'cd "${EPICS_BASE}" \
 && make -j"$(nproc)" CFLAGS=-fPIC CXXFLAGS=-fPIC all 2>&1 | tee "${LOG_DIR}/build-base.log" \
 && make clean'

# Determine host arch HERE (perl is available in the builder) and create a
# stable, arch-independent symlink `binln` -> bin/<arch>. Record the arch so
# the runtime stage need not run perl. Both travel with the copied tree.
RUN set -eu; \
    arch="$("${EPICS_BASE}/startup/EpicsHostArch")"; \
    ln -s "bin/${arch}" "${EPICS_BASE}/binln"; \
    echo "EPICS_HOST_ARCH=${arch}" > "${EPICS_BASE}/host-arch.env"

# ----------------------------------------------------------------------
# base-epics: final runtime image. Copies only the built products.
# ----------------------------------------------------------------------
FROM os-runtime AS base-epics

ARG EPICS_BASE_VERSION
ENV EPICS_BASE=${EPICS_ROOT}/base

# Products only (no toolchain, no sources) -> small runtime image.
# The copied tree already contains the `binln` symlink and host-arch.env
# created in the builder, so no perl/toolchain is needed at runtime.
COPY --from=epics-build ${EPICS_ROOT}/base-${EPICS_BASE_VERSION} ${EPICS_ROOT}/base-${EPICS_BASE_VERSION}
RUN ln -s "base-${EPICS_BASE_VERSION}" "${EPICS_ROOT}/base"

# Retain build logs in the image for later diagnostics.
COPY --from=epics-build ${LOG_DIR} ${LOG_DIR}

# Stable, arch-independent bin dir on PATH (binln -> bin/<arch>).
ENV PATH=${EPICS_ROOT}/base/binln:${PATH}

# procServ + IOC launch settings (overridable at run time).
ENV PREFIX=ioc: \
    IOC_CONSOLE_PORT=2048

COPY resources/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY resources/softioc.sh /usr/local/bin/softioc.sh
COPY resources/make_home_links.sh /usr/local/bin/make_home_links.sh
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/softioc.sh \
             /usr/local/bin/make_home_links.sh

# Convenience symlinks in /home (base + softioc persona).
RUN /usr/local/bin/make_home_links.sh /home

WORKDIR /home
# Default persona: EPICS base softIoc, supervised by procServ.
ENV IOC=softioc
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# ----------------------------------------------------------------------
# synapps-build: assemble + build the synApps support tree and xxx IOC.
# Builds on os-build (toolchain) with the already-built EPICS base copied
# from epics-build.
# ----------------------------------------------------------------------
FROM os-build AS synapps-build

ARG EPICS_BASE_VERSION
ARG SYNAPPS_VERSION
# Documented per-module version overrides, space-separated "MODULE=TAG"
# (see versions.env / SYNAPPS_OVERRIDES). Exported as SYNAPPS_OVERRIDE_<MODULE>
# for synapps_prepare.sh.
ARG SYNAPPS_OVERRIDES=""
ENV EPICS_BASE=${EPICS_ROOT}/base \
    SYNAPPS=${EPICS_ROOT}/synApps
# The assembler creates ${SYNAPPS_DIR}/support -- so with SYNAPPS_DIR=${SYNAPPS}
# the support tree lands at ${SYNAPPS}/support.
ENV SUPPORT=${EPICS_ROOT}/synApps/support

# Bring in the built EPICS base.
COPY --from=epics-build ${EPICS_ROOT}/base-${EPICS_BASE_VERSION} ${EPICS_ROOT}/base-${EPICS_BASE_VERSION}
RUN ln -s "base-${EPICS_BASE_VERSION}" "${EPICS_ROOT}/base"
ENV PATH=${EPICS_ROOT}/base/binln:${PATH}

# Our prepare script: keeps the release's module tags, sets EPICS_BASE,
# and excludes the hardware modules (see resources/synapps_prepare.sh).
COPY resources/synapps_prepare.sh /usr/local/bin/synapps_prepare.sh
RUN chmod +x /usr/local/bin/synapps_prepare.sh

# Download the release's assembler, prepare it, assemble the support tree.
# The assembler does `mkdir ${SYNAPPS_DIR}; cd; get_support support`, so
# passing SYNAPPS_DIR=${SYNAPPS} yields the support tree at ${SUPPORT}.
# Download the release's assembler, prepare it, assemble the support tree.
# bash+pipefail so the piped `tee` cannot mask a failure (podman's OCI image
# format ignores the `SHELL` directive, so we set pipefail explicitly).
RUN bash -o pipefail -c 'mkdir -p "${SYNAPPS}" \
 && cd "${SYNAPPS}" \
 && wget -q "https://raw.githubusercontent.com/EPICS-synApps/support/${SYNAPPS_VERSION}/assemble_synApps.sh" \
 && for kv in ${SYNAPPS_OVERRIDES}; do export "SYNAPPS_OVERRIDE_${kv%%=*}=${kv#*=}"; done \
 && synapps_prepare.sh assemble_synApps.sh "${EPICS_BASE}" \
 && cp assemble_synApps.sh "${LOG_DIR}/assemble_synApps.prepared.sh" \
 && SYNAPPS_DIR="${SYNAPPS}" bash assemble_synApps.sh 2>&1 | tee "${LOG_DIR}/assemble_synApps.log"'

# asyn needs TIRPC on modern glibc/Debian.
RUN echo "TIRPC=YES" > "$(ls -d ${SUPPORT}/asyn-*)/configure/CONFIG_SITE.local"

# Build the whole support tree. bash+pipefail so a make failure is not masked
# by the succeeding `tee`.
RUN bash -o pipefail -c 'cd "${SUPPORT}" \
 && make -j"$(nproc)" release 2>&1 | tee "${LOG_DIR}/build-synApps.log" \
 && make -j"$(nproc)" 2>&1 | tee -a "${LOG_DIR}/build-synApps.log"'

# Build the xxx template IOC.
RUN bash -o pipefail -c 'xxx="$(ls -d ${SUPPORT}/xxx-*)" \
 && make -C "${xxx}" 2>&1 | tee "${LOG_DIR}/build-xxx.log" \
 && ln -s "${xxx}" "${SUPPORT}/xxx"'

# ----------------------------------------------------------------------
# gp-build: build the customized "gp" IOC (copy of xxx + our overlays).
# ----------------------------------------------------------------------
FROM synapps-build AS gp-build

# gp customization tunables (single source of truth: versions.env).
ARG MOTOR_SREV=8000
ENV MOTOR_SREV=${MOTOR_SREV}

COPY resources/gp/ /usr/local/share/gp/
RUN bash -o pipefail -c '\
    MOTOR="$(ls -d ${SUPPORT}/motor-*)"; export MOTOR; \
    bash /usr/local/share/gp/gp_build.sh 2>&1 | tee "${LOG_DIR}/build-gp.log"'

# ----------------------------------------------------------------------
# base-synapps: runtime image with EPICS base + synApps.
# ----------------------------------------------------------------------
FROM base-epics AS base-synapps

ARG SYNAPPS_VERSION
ENV SYNAPPS=${EPICS_ROOT}/synApps \
    SUPPORT=${EPICS_ROOT}/synApps/support

# Runtime libraries needed by synApps / areaDetector products.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
 && apt-get install -y --no-install-recommends \
        libtirpc3 \
        libgraphicsmagick++-q16-12 \
        libtiff6 \
        libjpeg62-turbo \
        libnetcdf19 \
        libxml2 \
        libx11-6 \
        libxext6 \
        zlib1g \
        libusb-1.0-0 \
 && rm -rf /var/lib/apt/lists/*

# Copy the built support tree from gp-build (a superset of synapps-build:
# it also contains the customized iocgp). Products only; no toolchain/sources.
COPY --from=gp-build ${SUPPORT} ${SUPPORT}

# Retain all build logs (base, synApps, xxx, gp) for later diagnostics.
COPY --from=gp-build ${LOG_DIR} ${LOG_DIR}

# Personas:
#   xxx : as-supplied synApps template IOC (fixed xxx: prefix). IOC=xxx
#   gp  : customized synApps IOC (runtime PREFIX, default gp:). IOC=gp
COPY resources/xxx.sh /usr/local/bin/xxx.sh
COPY resources/gp.sh  /usr/local/bin/gp.sh
RUN chmod +x /usr/local/bin/xxx.sh /usr/local/bin/gp.sh

# Gather display files by format (one dir per format) for host-side clients.
# Screens use the $(P) macro (replaceable prefix, issue #68); a client
# launches them with -macro "P=<prefix>".
ENV SCREENS_ROOT=${EPICS_ROOT}/screens
COPY resources/collect_screens.sh /usr/local/bin/collect_screens.sh
RUN chmod +x /usr/local/bin/collect_screens.sh \
 && /usr/local/bin/collect_screens.sh "${SCREENS_ROOT}" \
        "${SUPPORT}/iocgp/xxxApp/op" "${SUPPORT}"

# Refresh convenience symlinks in /home now that synApps (support, xxx, iocxxx,
# iocgp), the persona scripts, and screens are present.
RUN /usr/local/bin/make_home_links.sh /home

# Default persona remains softioc; select xxx or gp with -e IOC=xxx|gp.
ENV IOC=softioc
