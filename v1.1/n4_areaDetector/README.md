# README.md

The [`prjemian/synapps-6.2-ad-3.10`](https://hub.docker.com/r/prjemian/synapps-6.2-ad-3.10/tags)
image provides EPICS [areaDetector release 3.10](https://github.com/areaDetector) in addition to
[synApps release 6.2](https://www.aps.anl.gov/BCDA/synApps),
EPICS software tools that help to create a control system for beamlines.

Specifically, this image includes:

* [ADSimDetector](https://github.com/areaDetector/ADSimDetector) - simulate an area detector
* [ADURL](https://github.com/areaDetector/ADURL) - image from a URL
* [ADViewers](https://github.com/areaDetector/ADViewers) - support for various viewers
* [ffmpegServer](https://github.com/areaDetector/ffmpegServer) - compress stream of images
* [pvaDriver](https://github.com/areaDetector/pvaDriver) - import NTNDArray via pvAccess into AD


- [README.md](#readmemd)
  - [default application](#default-application)
  - [default working directory](#default-working-directory)
  - [example use](#example-use)
  - [Environment variables](#environment-variables)
  - [Docker images used by this image](#docker-images-used-by-this-image)

## default application

By default, the bash shell is run but no IOC is started.

    docker run -ti --rm --net=host --name areaDetector \
        prjemian/synapps-6.2-ad-3.10:latest

## default working directory

The default working directory is `${SUPPORT}`

## example use

Start the `13SIM1:` IOC in a detached container:

    docker run -ti -d --rm --net=host --name ADSimDetector \
        prjemian/synapps-6.2-ad-3.10:latest \
        /opt/runADSimDetector.sh

Start the `13URL1:` IOC in a detached container:

    docker run -ti -d --rm --net=host --name ADURL \
        prjemian/synapps-6.2-ad-3.10:latest \
        /opt/runADURL.sh

## Environment variables

Environment variables defined in this image (from `grep ENV Dockerfile`)
```
ENV APP_ROOT="/opt"
ENV EDITOR="nano"
ENV EPICS_HOST_ARCH=linux-x86_64
ENV EPICS_ROOT="${APP_ROOT}/base"
ENV PATH="${PATH}:${EPICS_ROOT}/bin/${EPICS_HOST_ARCH}"
ENV SUPPORT="${APP_ROOT}/synApps/support"
ENV PATH="${PATH}:${SUPPORT}/utils"
ENV AD_TAG=R3-10
ENV AREA_DETECTOR=${SUPPORT}/areaDetector-${AD_TAG}
ENV ADCORE_HASH=9321f2a
ENV ADSUPPORT_HASH=5c549858
ENV ADSIMDETECTOR_HASH=d24fa04
ENV AD_PVADRIVER_HASH=1f51a94
ENV ADURL_HASH=031794e
ENV ADVIEWERS_HASH=3fe0c51
ENV AD_FFMPEGSERVER_HASH=063bedd
ENV IOCADSIMDETECTOR=${AREA_DETECTOR}/ADSimDetector/iocs/simDetectorIOC/iocBoot/iocSimDetector
ENV IOCADURL=${AREA_DETECTOR}/ADURL/iocs/urlIOC/iocBoot/iocURLDriver
```


## Docker images used by this image

These are the docker images from which this image is based:

from | image | description
--- | --- | ---
`prjemian/synapps-6.2` | `prjemian/synapps-6.2-ad-3.10` | this image
`prjemian/epics-base-7.0.4.1` |  `prjemian/synapps-6.2` | synApps release 6.2
`prjemian/os_only-1.1` | `prjemian/epics-base-7.0.4.1` |  EPICS base release 7.0.4.1
`ubuntu` | `prjemian/os_only-1.1` | Linux OS for this EPICS installation
dockerhub | `ubuntu` | Ubuntu 20.04.1 LTS (at the time of the build)
