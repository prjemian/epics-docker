# syntax=docker/dockerfile:1
#
# v3 multi-stage build: base-os -> base-epics
#
# Stages:
#   os-runtime : Debian + runtime-only deps (procServ, libs). Small.
#   os-build   : os-runtime + toolchain (compilers, headers). Build only.
#   epics-build: builds EPICS base from source in os-build.
#   base-epics : final runtime image; copies only the built products.
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
    LANG=C.UTF-8

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
        libreadline-dev \
        perl \
        wget \
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

# Build; keep full log for the devel variant / debugging.
RUN cd "${EPICS_BASE}" \
 && make -j"$(nproc)" CFLAGS=-fPIC CXXFLAGS=-fPIC all 2>&1 | tee /tmp/build-base.log \
 && make clean

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

# Stable, arch-independent bin dir on PATH (binln -> bin/<arch>).
ENV PATH=${EPICS_ROOT}/base/binln:${PATH}

# procServ + IOC launch settings (overridable at run time).
ENV PREFIX=ioc: \
    IOC_CONSOLE_PORT=2048

COPY resources/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY resources/softioc.sh /usr/local/bin/softioc.sh
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/softioc.sh

WORKDIR /home
# Default persona: EPICS base softIoc, supervised by procServ.
ENV IOC=softioc
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
