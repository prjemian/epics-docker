# README.md

The [`prjemian/synApps-6.2`](https://hub.docker.com/r/prjemian/synapps-6.2/tags)
image provides EPICS
[synApps release 6.2](https://www.aps.anl.gov/BCDA/synApps),
EPICS software tools that help to create a control system for beamlines.

Tools for compiling EPICS software including compilers and
screen-oriented text editors (nano, vim, and vi) are included.
The screen program is also included for running detached console
sessions such as IOCs.

This synApps modules in this image were gathered using the
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

## one-time setup

Bash shell scripts (for linux-x86_64 host architecture) to help you start
and stop the images (and load screen files for use by your GUI programs).
You need both these scripts.

     cd ~/bin
     wget https://raw.githubusercontent.com/prjemian/epics-docker/master/n3_synApps/start_xxx.sh
     wget https://raw.githubusercontent.com/prjemian/epics-docker/master/n3_synApps/remove_container.sh

The `start_xxx.sh` script runs the docker image in a container.  The default IOC prefix
is `xxx:` as defined in the synApps [XXX](https://github.com/epics-modules/xxx) module.
If you supply an IOC prefix to be used instead of the default,
do not add the trailing colon, it will be added by the script.  Additionally, the script copies
GUI screen file definitions from all installed synApps modules to the subdirectory
`/tmp/docker_ioc/synapps-6.1/`.  The script also copies the IOC's boot directory to
`/tmp/docker_ioc/CONTAINER_NAME/xxx-R6-1/`.  This is a one-time copy as the IOC starts.
It does not contain live updates from autosave/restore or other such.

| directory | contents |
| ---- | ---- |
| `/tmp/docker_ioc/synapps-6.1/screens/adl/` | MEDM `.adl` screens and related files |
| `/tmp/docker_ioc/synapps-6.1/screens/opi/` | CSS BOY `.opi` screens and related files |
| `/tmp/docker_ioc/synapps-6.1/screens/ui/` | caQtDM `.ui` screens and related files |

The `remove_container.sh` script stops the IOC in the container, then stops and removes the container.

## example use

Start the IOC in a container and keep it running
with a never-ending, trivial script:

    docker run -d --net=host --name iocxxx \
        prjemian/synapps-6.1:latest \
        bash -c "while true; do date; sleep 10; done"

Start the XXX IOC:

    docker exec iocxxx iocxxx/softioc/xxx.sh start

Once the IOC has started, the full list of PVs provided
will be available in file: `iocxxx/dbl-all.txt`.

    docker exec iocxxx cat iocxxx/dbl-all.txt

You can interact with the iocxxx container by attaching
to the container and running the bash shell:

    docker attach iocxxx

From the bash shell in the container, you may use EPICS
commands such as `caget` to view the content of a PV:

    root@345225848f10:/opt/synApps/support# caget xxx:datetime
    xxx:datetime                   2019-09-30 03:59:24

Detach with the keyboard combination `^P ^Q` (CTRL+p CTRL+q).
If you `exit` the container, it will stop.

### use a custom IOC prefix

EPICS expects that every PV on a network has a unique name.
To ensure this, synApps IOCs are created with a PV `PREFIX`
that is not used by any other IOC on the network.  It is customary
that this is a short sequence of letters/numbers starting with a letter
and ending with a `:` (colon).  (A colon is used as a visual separator
in many of the PVs created in a synApps IOC.)

To create PVs with a different prefix, set the `PREFIX`
variable (say `vm7:`) in the container before you start the IOC, such as::

    export PREFIX=vm7:
    iocxxx/softioc/xxx.sh start

or specify the PREFIX variable as you start the container:

    docker run -d --net=host --name iocvm7 \
        -e "PREFIX=vm7:" \
        prjemian/synapps-6.1 \
        bash -c "while true; do date; sleep 10; done"

While you are at it, create yet another IOC (say `bc1`):

    docker run -d --net=host --name iocbc1 \
        -e "PREFIX=bc1:" \
        prjemian/synapps-6.1 \
        bash -c "while true; do date; sleep 10; done"

*This* synApps image has been modified to allow setting a custom IOC prefix.

## Environment variables

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

## background

* docker source: `prjemian/epics-base-7.0.3`
* `prjemian/os_only`
* `ubuntu:latest` (Ubuntu 18.04)
