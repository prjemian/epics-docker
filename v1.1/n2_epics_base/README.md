# README.md

The [`prjemian/epics-base-7.0.4.1`
image](https://hub.docker.com/r/prjemian/epics-base-7.0.4.1/tags)
provides [EPICS base release
7.0.4.1](https://epics.anl.gov/base/R7-0/4.php), the Experimental
Physics and Industrial Control System in docker images. Tools for
compiling EPICS software including compilers and screen-oriented text
editors (*nano*, *vim*, and *vi*) are included. The *screen* program is
also included for running detached console sessions such as IOCs.

This image will serve as the starting point for images
that provide other EPICS components.

EPICS base is installed (and compiled) in directory:
`/opt/base-R7.0.4.1` which is soft-linked to `/opt/base`.

- [README.md](#readmemd)
  - [default application](#default-application)
  - [default working directory](#default-working-directory)
  - [example use](#example-use)
  - [Shows the EPICS base version](#shows-the-epics-base-version)
  - [Shows the OS version](#shows-the-os-version)
  - [Notes](#notes)
  - [This Docker Image Provides ...](#this-docker-image-provides-)
  - [Environment variables](#environment-variables)
    - [Demo: soft IOC demonstration](#demo-soft-ioc-demonstration)
  - [Docker images used by this image](#docker-images-used-by-this-image)

## default application

By default, the bash shell is run.  See [Demo: soft IOC
demonstration](#demo-soft-ioc-demonstration) for an example IOC.

## default working directory

The default working directory is `${EPICS_ROOT}`.  See [Environment
variables](#environment-variables) for the definitions of useful
environment variables already defined.

## example use

To start this image in a container at the bash shell, first create a
bridge network (using name `host-bridge` here) so any EPICS Process
Variables created by an EPICS IOC will be visible to the host operating
system:

    docker network create --driver bridge host-bridge

Next, start the container (the default application is a *bash* shell):

    docker run \
        -it \
        -d \
        --rm \
        --net=host-bridge \
        --name=epics-base-7.0.4.1 \
        prjemian/epics-base-7.0.4.1

Note: The *docker* command returns a long hexadecimal code that
identifies this container uniquely.  You can stop the container by using
the first few characters of this code (the first 4-7 should be specific
enough) with the `docker stop` command, such as this example session:

    (base) user@host:~ $ docker run \
    >         -it \
    >         -d \
    >         --rm \
    >         --net=host-bridge \
    >         --name=epics-base-7.0.4.1 \
    >         prjemian/epics-base-7.0.4.1
    d3a2279cccb99a818837283eb0c456e7225d3d765d2c8fb949e131b0a1901d63
    (base) user@host:~ $ docker stop d3a
    d3a

If you forget this code or need to learn it later, use the `docker ps`
command to list all running containers.  If you have many containers
running, you probably do not need these instructions.  There are many
pages on the web giving more advice how to stop & remove docker
containers. [Here is one of
them](https://linuxhandbook.com/remove-docker-containers/).


## Shows the EPICS base version

Print the version of EPICS base by starting a soft IOC:

    (base) user@host:~ $ docker \
        run prjemian/epics-base-7.0.4.1 \
        /opt/base/bin/linux-x86_64/softIoc \
            -m IOC=ioc \
            -d /opt/base/db/softIocExit.db

The container will start and then the IOC will start, printing lines
such as these to the terminal (date might be different):

    Starting iocInit
    iocRun: All initialization complete
    dbLoadDatabase("/opt/base-R7.0.4.1/bin/linux-x86_64/../../dbd/softIoc.dbd")
    softIoc_registerRecordDeviceDriver(pdbbase)
    dbLoadRecords("/opt/base/db/softIocExit.db", "IOC=ioc")
    iocInit()
    ############################################################################
    ## EPICS R7.0.4.1
    ## Rev. 2021-01-20T23:13+0000
    ############################################################################
    epics>

Then, the container will exit back to your host system.

## Shows the OS version

Print the operating system info from the container:

    (base) user@host:~ $ docker \
        run prjemian/epics-base-7.0.4.1 \
        cat /etc/lsb-release

Expect this result:

    DISTRIB_ID=Ubuntu
    DISTRIB_RELEASE=20.04
    DISTRIB_CODENAME=focal
    DISTRIB_DESCRIPTION="Ubuntu 20.04.1 LTS"

## Notes


## This Docker Image Provides ...

In addition to its parent image(s), this image provides:

[EPICS base](https://epics.anl.gov/base/index.php) compiled for
`${EPICS_HOST_ARCH}` in directory  `/opt/base/`.

## Environment variables

These environment variables were defined when creating this docker image
(from `grep ENV Dockerfile`):

    ENV APP_ROOT="/opt"
    ENV EDITOR="nano"
    ENV EPICS_BASE_NAME=base-7.0.4.1
    ENV EPICS_BASE_DIR_NAME=base-R7.0.4.1
    ENV EPICS_HOST_ARCH=linux-x86_64
    ENV EPICS_ROOT="${APP_ROOT}/${EPICS_BASE_DIR_NAME}"
    ENV PATH="${PATH}:${EPICS_ROOT}/bin/${EPICS_HOST_ARCH}"

### Demo: soft IOC demonstration

A demonstration EPICS database file (defines process variables) is
provided to test the installation using the `softIoc` application from
EPICS base.  To run the image as an IOC (with the default PV prefix
of `softIoc_demo:`):

    docker run -ti -d --rm prjemian/epics-base-7.0.4.1:latest \
        softIoc -d /tmp/softIoc_base_demo/demo.db

These are the PVs the demonstration IOC provides:

PV | description
---- | ----
`softIoc_demo:ao` | floating point variable, writeable
`softIoc_demo:bo` | single-bit variable, writeable
`softIoc_demo:longout` | integer variable, writeable
`softIoc_demo:stringout` | text variable, writeable

You can also supply a custom PV prefix (such as `demo:` as shown) by
using the `-m IOC=custom_prefix` option as shown in this example:

    docker run -ti -d --rm prjemian/epics-base-7.0.4.1:latest \
        softIoc -m IOC=demo: -d /tmp/softIoc_base_demo/demo.db

These are the PVs the demonstration IOC provides when using the custom
`demo:` PV prefix:

PV | description
---- | ----
`demo:ao` | floating point variable, writeable
`demo:bo` | single-bit variable, writeable
`demo:longout` | integer variable, writeable
`demo:stringout` | text variable, writeable

Note:  If you start to get messages about *duplicate PV name found* or
some such, then you have more than one of these IOCs (**with the same
prefix**) running on your subnet.  Check that you do not have extra
containers running from previous examples.

## Docker images used by this image

These are the docker images from which this image is based:

from | image | description
--- | --- | ---
`prjemian/os_only-1.1` | `prjemian/epics-base-7.0.4.1` |  this image
`ubuntu` | `prjemian/os_only-1.1` | Linux OS for this EPICS installation
dockerhub | `ubuntu` | Ubuntu 20.04.1 LTS (at the time of the build)
