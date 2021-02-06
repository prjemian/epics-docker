# README.md

The
[`prjemian/synApps-2020.5`](https://hub.docker.com/r/prjemian/synapps-2020.5/tags)
image provides EPICS [synApps release 6.1+ (master branch
2020-May)](https://www.aps.anl.gov/BCDA/synApps), EPICS software tools
that help to create a control system for beamlines.

- [README.md](#readmemd)
  - [Overview](#overview)
    - [modifications of assemble_synApps.sh](#modifications-of-assemble_synappssh)
  - [default application](#default-application)
  - [default working directory](#default-working-directory)
  - [example use](#example-use)
  - [What This Docker Image Provides](#what-this-docker-image-provides)
  - [Environment variables](#environment-variables)
  - [Docker images used by this image](#docker-images-used-by-this-image)
## Overview

Tools for compiling EPICS software including compilers and text editors
(nano, vim, and vi) are included. The screen program is also included
for running detached console sessions such as IOCs.

This synApps modules in this image were gathered using the
[`assemble_synApps.sh`](https://github.com/EPICS-synApps/support/blob/master/assemble_synApps.sh)
script.  The script was edited to remove the EPICS area detector
(module) and other modules that are not used with a linux operating
system.  It is intended to build an additional container with area
detector.

The synApps image also provides a template IOC to create a runnable
EPICS server based on the [XXX
module](https://github.com/epics-modules/xxx), the synApps template IOC
module.

The synApps module is installed (already compiled) in directory: `/opt/synApps/support`.

### modifications of assemble_synApps.sh

* `motor` release *R7-2-2* must be installed to resolve an [asyn build problem](https://github.com/epics-modules/motor/issues/173)
* `StreamDevice` [must be installed](https://github.com/prjemian/epics-docker/issues/16#issuecomment-770226806) from GitHub `2.8.14` release

## default application

By default, the bash shell is run but no IOC is started.

    docker run -ti --rm --net=host --name synApps prjemian/synapps-6.2:latest

See the [*example use*](#example-use) section for an IOC example.

## default working directory

The default working directory is `${SUPPORT}`

## example use

Start the IOC in a container:

    docker run -ti -d --rm --net=host --name iocxxx \
        prjemian/synapps-6.2:latest \
        /opt/synApps/support/iocxxx/softioc/xxx.sh run

Once the IOC has started, the full list of PVs provided
will be available in file: `iocxxx/dbl-all.txt`.

    docker exec iocxxx cat iocxxx/dbl-all.txt

You can interact with the iocxxx console in the container by attaching
to the container and running the bash shell:

    docker attach iocxxx

Detach with the keyboard combination `^P ^Q` (<control>+p <control>+q).
If you `exit` the container, it will stop.

You can access the bash shell in the container:

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

## What This Docker Image Provides

In addition to its parent images, this image provides:

* Compiled *synApps* modules in `/opt/synApps/support`
* All synApps GUI screen files (for MEDM, caQtDM, CSS BOY, EDM, ...)
  copied to `/opt/screens` and application-specific subdirectories.
* Bash script `/opt/copy_screens.sh` that makes these copies.
* `${IOCXXX}` : *xxx* IOC boot directory ready to run

## Environment variables

These environment variables were defined when creating this docker image
(from `grep ENV Dockerfile`):

    # TODO:


## Docker images used by this image

These are the docker images from which this image is based:

from | image | description
--- | --- | ---
`prjemian/epics-base-7.0.4.1` |  `prjemian/synapps-6.2` | this image
`prjemian/os_only-1.1` | `prjemian/epics-base-7.0.4.1` |  EPICS base release 7.0.4.1
`ubuntu` | `prjemian/os_only-1.1` | Linux OS for this EPICS installation
dockerhub | `ubuntu` | Ubuntu 20.04.1 LTS (at the time of the build)
