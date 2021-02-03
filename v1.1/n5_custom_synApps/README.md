# README.md

TODO:

The
[`prjemian/synApps-6.2`](https://hub.docker.com/r/prjemian/synapps-6.2/tags)
image provides EPICS [synApps release
6.2](https://www.aps.anl.gov/BCDA/synApps), EPICS software tools that
help to create a control system for beamlines.

- [README.md](#readmemd)
  - [Overview](#overview)
    - [modifications of synApps-6.2](#modifications-of-synapps-62)
  - [default application](#default-application)
  - [default working directory](#default-working-directory)
  - [example use](#example-use)
  - [Environment variables](#environment-variables)
  - [Docker images used by this image](#docker-images-used-by-this-image)

## Overview

The [EPICS synApps](https://www.aps.anl.gov/BCDA/synApps) module is
installed (already compiled) in directory: `/opt/synApps/support`.

### modifications of synApps-6.2

*

## default application

By default, the bash shell is run but no IOC is started.

    docker run -ti --rm --net=host --name synApps prjemian/custom-synapps-6.2:latest

See the [*example use*](#example-use) section for an IOC example.

## default working directory

The default working directory is `${SUPPORT}`

## example use

Start the IOC in a container:

    docker run -ti -d --rm --net=host --name iocioc -e PREFIX=ioc: \
        prjemian/custom-synapps-6.2:latest \
        iocxxx/softioc/xxx.sh run

Once the IOC has started, the full list of PVs provided
will be available in file: `iocxxx/dbl-all.txt`.

    docker exec iocioc cat iocxxx/dbl-all.txt

You can interact with *iocioc* console in the container by attaching
to the container:

    docker attach iocxxx

Detach with the keyboard combination `^P ^Q` (<control>+p <control>+q).
If you `exit` the container, it will stop.

You can access the bash shell in the *iocioc* container:

    docker exec -it iocxxx bash

From the bash shell in the container, you may use EPICS
commands such as `caget` to view the content of a PV:

    root@345225848f10:/opt/synApps/support# caget xxx:UPTIME
    xxx:UPTIME                     00:05:33

The difference between these two methods is shown in this table:

command | provides | what happens when you type `exit`
--- | ---
`docker attach iocxxx` | IOC console | IOC and container stop
`docker exec -it iocxxx bash` | container linux command line | IOC & container stay running

## Environment variables

```
ENV APP_ROOT="/opt"
ENV EDITOR="nano"
ENV EPICS_HOST_ARCH=linux-x86_64
ENV EPICS_ROOT="${APP_ROOT}/base"
ENV PATH="${PATH}:${EPICS_ROOT}/bin/${EPICS_HOST_ARCH}"
ENV SUPPORT="${APP_ROOT}/synApps/support"
ENV PATH="${PATH}:${SUPPORT}/utils"
ENV MOTOR=${SUPPORT}/motor-R7-2-2
ENV XXX=${SUPPORT}/xxx-R6-2
```


## Docker images used by this image

These are the docker images from which this image is based:

from | image | description
--- | --- | ---
`prjemian/synapps-6.2` |  `prjemian/custom-synapps-6.2` | this image
`prjemian/epics-base-7.0.4.1` |  `prjemian/synapps-6.2` | synApps release 6.2
`prjemian/os_only-1.1` | `prjemian/epics-base-7.0.4.1` |  EPICS base release 7.0.4.1
`ubuntu` | `prjemian/os_only-1.1` | Linux OS for this EPICS installation
dockerhub | `ubuntu` | Ubuntu 20.04.1 LTS (at the time of the build)
