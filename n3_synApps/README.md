# README.md

The [`synApps-6.1`](https://hub.docker.com/r/prjemian/synapps-6.1/tags) 
image provides EPICS
[synApps release 6.1](https://www.aps.anl.gov/BCDA/synApps),
EPICS software tools that help to create a control system for beamlines.

Tools for compiling EPICS software including compilers and
screen-oriented text editors (nano, vim, and vi) are included.
The screen program is also included for running detached console
sessions such as IOCs.

This image was build using the 
[`assemble_synApps.sh`](https://github.com/EPICS-synApps/support/blob/master/assemble_synApps.sh) 
script.  The script was edited to remove the EPICS area detector (module) and other 
modules that are not used with a linux operating system.  It is intended
to build an additional container with area detector.

The synApps image also provides a template IOC to create a runnable EPICS server
based on the [XXX module](https://github.com/epics-modules/xxx), 
the synApps template IOC module.

The synApps module is installed (already compiled) in directory: `/opt/synApps/support`.

## default application

By default, no application is run.

## default working directory

The default working directory is `${SUPPORT}`

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
        --name=synapps-6.1 \
        prjemian/synapps-6.1 \
        /bin/bash

The XXX IOC is ready to run from the bash shell:

    ./iocxxx/softioc/xxx.sh start

After starting the IOC, the full list of PVs provided 
will be available in file: `iocxxx/dbl-all.txt`.

From the bash shell in the container, you may use EPICS 
commands such as `caget` to view the content of a PV:

    root@345225848f10:/opt/synApps/support# caget xxx:datetime
    xxx:datetime                   2019-09-30 03:59:24


### use a custom IOC prefix

EPICS expects that every PV on a network has a unique name.
To ensure this, synApps IOCs are created with a PV `PREFIX`
that is not used by any other IOC on the network.  It is customary
that this is a short sequence of letters/numbers starting with a letter
and ending with a `:` (colon).  (A colon is used as a visual separator
in many of the PVs created in a synApps IOC.)

To create PVs with a different prefix, set the `PREFIX` 
variable in the container, such as::

    export PREFIX=bc1:

or specify the PREFIX variable as you start the container:

    docker run \
        -it \
        --rm \
        --net=host-bridge \
        --name=synapps-6.1 \
        -e "PREFIX=bc1:"
        prjemian/synapps-6.1 \
        /bin/bash

*This* synApps image has been modified to allow setting a custom IOC prefix.

## Environment variables

```
ENV APP_ROOT="/opt"
ENV EDITOR="nano"
ENV EPICS_HOST_ARCH=linux-x86_64
ENV EPICS_ROOT="${APP_ROOT}/base"
ENV PATH="${PATH}:${EPICS_ROOT}/bin/${EPICS_HOST_ARCH}"
ENV SUPPORT="${APP_ROOT}/synApps/support"
ENV PATH="${PATH}:${SUPPORT}/utils"
ENV HASH=cc5adba5b8848c9cb98ab96768d668ae927d8859
ENV MOTOR=${SUPPORT}/motor-R7-1
ENV XXX=${SUPPORT}/xxx-R6-1
ENV PREFIX=xxx:
```


## background

* docker source: `prjemian/epics-base-7.0.3`
* `prjemian/os_only`
* `ubuntu:latest` (Ubuntu 18.04)
