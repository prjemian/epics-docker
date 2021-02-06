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

These environment variables were defined when creating this docker image
(from `grep ENV Dockerfile`):

    # TODO:


## Docker images used by this image

These are the docker images from which this image is based:

from | image | description
--- | --- | ---
`prjemian/synapps-6.2` | `prjemian/synapps-6.2-ad-3.10` | this image
`prjemian/epics-base-7.0.4.1` |  `prjemian/synapps-6.2` | synApps release 6.2
`prjemian/os_only-1.1` | `prjemian/epics-base-7.0.4.1` |  EPICS base release 7.0.4.1
`ubuntu` | `prjemian/os_only-1.1` | Linux OS for this EPICS installation
dockerhub | `ubuntu` | Ubuntu 20.04.1 LTS (at the time of the build)
