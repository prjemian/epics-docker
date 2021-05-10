# README.md

TODO:

The
[`prjemian/custom-synapps-6.2-ad-3.10`](https://hub.docker.com/r/prjemian/custom-synapps-6.2-ad-3.10/tags)
image provides ...

- [README.md](#readmemd)
  - [Overview](#overview)
    - [modifications of synApps-6.2-ad-2.10](#modifications-of-synapps-62-ad-210)
  - [default application](#default-application)
- [TODO](#todo)
  - [default working directory](#default-working-directory)
  - [example use](#example-use)
    - [TODO:](#todo-1)
  - [This Docker Image Provides ...](#this-docker-image-provides-)
  - [Environment variables](#environment-variables)
  - [Docker images used by this image](#docker-images-used-by-this-image)

## Overview

The [EPICS synApps](https://www.aps.anl.gov/BCDA/synApps) module is
installed (already compiled) in directory: `/opt/synApps/support`.

### modifications of synApps-6.2-ad-2.10

*

## default application

By default, the bash shell is run but no IOC is started.

    docker run -ti --rm --net=host \
        --name customAreaDetector \
        prjemian/custom-synapps-6.2-ad-3.10:latest

See the [*example use*](#example-use) section for an IOC example.

---

# TODO

## default working directory

The default working directory is `/home`

## example use

Start the `13SIM1:` IOC in a detached container:

    docker run -ti -d --rm --net=host \
        -e PREFIX=adsim: \
        --name iocadsim \
        prjemian/custom-synapps-6.2-ad-3.10:latest \
        /opt/runADSimDetector.sh

Start the `13URL1:` IOC in a detached container:

    docker run -ti -d --rm --net=host \
        -e PREFIX=adurl: \
        --name iocadurl \
        prjemian/custom-synapps-6.2-ad-3.10:latest \
        /opt/runADURL.sh

### TODO:
show how to mount `/tmp` as a shared volume

## This Docker Image Provides ...

* `${IOCADSIMDETECTOR}` : IOC boot directory ready to run with customizable PV prefix (default: prefix `13SIM1:`)
* `${IOCADURL}` : IOC boot directory ready to run with customizable PV prefix (default: `13URL1:`)

To customize the PV prefix, add the `PREFIX` environment variable when
starting the container such as in the examples above.  Both the
`IOCADSIMDETECTOR` and the `IOCADURL` IOC can be run from the same
container (since they operate in separate directories).

With this docker image, it is possible to create multiple containers,
each running an EPICS IOC.  Each container should be started with a
different `PREFIX` to avoid name contention amongst the available EPICS
PVs.  There are other ways to use this image to run multiple instances
of either IOC in the same container, but that description is beyond the
scope of this documentation.

## Environment variables

These environment variables were defined when creating this docker image
(from `grep ENV Dockerfile`):

    # --none--


## Docker images used by this image

These are the docker images from which this image is based:

from | image | description
--- | --- | ---
`prjemian/synapps-6.2` |  `prjemian/custom-synapps-6.2` | this image
`prjemian/epics-base-7.0.5` |  `prjemian/synapps-6.2` | synApps release 6.2
`prjemian/os_only-1.1` | `prjemian/epics-base-7.0.5` |  EPICS base release 7.0.5
`ubuntu` | `prjemian/os_only-1.1` | Linux OS for this EPICS installation
dockerhub | `ubuntu` | Ubuntu 20.04.1 LTS (at the time of the build)
