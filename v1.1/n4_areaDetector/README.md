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
  - [This Docker Image Provides ...](#this-docker-image-provides-)
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

## This Docker Image Provides ...

With this image, it is possible to simulate a 2-D area detector such as
used by a scientific instrument for X-ray measurements at the [Advanced
Photon Source](https://www.aps.anl.gov).  With the ADURL detector, it is
possible to obtain area detector images from a URL.

In addition to its parent image(s), this image provides:

* compiled version of [EPICS Area Detector](https://github.com/areaDetector)
* [ADSimDetector](https://github.com/areaDetector/ADSimDetector)
* `${IOCADSIMDETECTOR}` : IOC boot directory ready to run with prefix `13SIM1:`
* [ADURL](https://github.com/areaDetector/ADURL)
* `${IOCADURL}` : IOC boot directory ready to run with prefix `13URL1:`
* All synApps GUI screen files (for MEDM, caQtDM, CSS BOY, EDM, ...)
  copied to `/opt/screens` and application-specific subdirectories.
* Bash script `/opt/copy_screens.sh` that makes these copies.

## Environment variables

These environment variables were defined when creating this docker image
(from `grep ENV Dockerfile`):

    ENV APP_ROOT="/opt"
    ENV EDITOR="nano"
    ENV EPICS_HOST_ARCH=linux-x86_64
    ENV EPICS_ROOT="${APP_ROOT}/base"
    ENV PATH="${PATH}:${EPICS_ROOT}/bin/${EPICS_HOST_ARCH}"
    ENV SUPPORT="${APP_ROOT}/synApps/support"
    ENV PATH="${PATH}:${SUPPORT}/utils"
    ENV AD_TAG=R3-10
    ENV AREA_DETECTOR=${SUPPORT}/areaDetector-${AD_TAG}
    ENV ADCORE_HASH=master
    ENV ADSUPPORT_HASH=master
    ENV ADSIMDETECTOR_HASH=master
    ENV AD_PVADRIVER_HASH=master
    ENV ADURL_HASH=master
    ENV ADVIEWERS_HASH=master
    ENV AD_FFMPEGSERVER_HASH=master
    ENV IOCADSIMDETECTOR=${AREA_DETECTOR}/ADSimDetector/iocs/simDetectorIOC/iocBoot/iocSimDetector
    ENV IOCADURL=${AREA_DETECTOR}/ADURL/iocs/urlIOC/iocBoot/iocURLDriver


## Docker images used by this image

These are the docker images from which this image is based:

from | image | description
--- | --- | ---
`prjemian/synapps-6.2` | `prjemian/synapps-6.2-ad-3.10` | this image
`prjemian/epics-base-7.0.5` |  `prjemian/synapps-6.2` | synApps release 6.2
`prjemian/os_only-1.1` | `prjemian/epics-base-7.0.5` |  EPICS base release 7.0.5
`ubuntu` | `prjemian/os_only-1.1` | Linux OS for this EPICS installation
dockerhub | `ubuntu` | Ubuntu 20.04.2 LTS (at the time of the build)
