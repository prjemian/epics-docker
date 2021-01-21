# README.md

The [`prjemian/epics-base-7.0.4.1`](https://hub.docker.com/r/prjemian/epics-base-7.0.4.1/tags)
image provides 
[EPICS base release 7.0.4.1](https://epics.anl.gov/base/R7-0/4.php),
the Experimental Physics and Industrial Control System in docker images.
Tools for compiling EPICS software including compilers and
screen-oriented text editors (nano, vim, and vi) are included.
The screen program is also included for running detached console
sessions such as IOCs.

This image will serve as the starting point for images 
that provide other EPICS components.

The EPICS base is installed (and compiled) in directory: 
`/opt/base-R7.0.4.1` which is soft-linked to `/opt/base`.

## default application

By default, no application is run.

## default working directory

The default working directory is `${EPICS_ROOT}`

## example use

To start this image in a container at the bash shell, first create
a bridge network (using name `host-bridge` here) so any EPICS Process 
Variables created by an EPICS IOC will
be visible to the host operating system:

    docker network create --driver bridge host-bridge

Next, start the container and attach to its bash shell:

    docker run \
        -it \
        --rm \
        --net=host-bridge \
        --name=epics-base-7.0.4.1 \
        prjemian/epics-base-7.0.4.1 \
        /bin/bash

## Shows the EPICS base version

Print the version of EPICS base by starting a soft IOC:

    (base) user@host:~ $ docker \
        run prjemian/epics-base-7.0.4.1 \
        /opt/base/bin/linux-x86_64/softIoc \
        -m IOC=ioc \
        -d /opt/base/db/softIocExit.db

The container will start and then the IOC will start, printing lines
such as these to the terminal:

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


## Environment variables

```
ENV APP_ROOT="/opt"
ENV EDITOR="nano"
ENV EPICS_HOST_ARCH=linux-x86_64
ENV EPICS_ROOT="${APP_ROOT}/base"
ENV PATH="${PATH}:${EPICS_ROOT}/bin/${EPICS_HOST_ARCH}"
```


## background

* docker source: `prjemian/os_only-1.1`
* ubuntu:latest (Ubuntu 20.04)
