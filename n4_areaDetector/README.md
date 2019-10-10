# README.md

The [`prjemian/synapps-6.1-ad-3.7`](https://hub.docker.com/r/prjemian/synapps-6.1-ad-3.7/tags) 
image provides EPICS [areaDetector release 3.7](https://github.com/areaDetector) in addition to
[synApps release 6.1](https://www.aps.anl.gov/BCDA/synApps),
EPICS software tools that help to create a control system for beamlines.

Specifically, this image includes [ADSimDetector](https://github.com/areaDetector/ADSimDetector),
a simulation of an area detector, with a working IOC.

# one-time setup

Bash shell scripts (for linux-x86_64 host architecture) to help you start 
and stop the images (and load screen files for use by your GUI programs).

     cd ~/bin
     wget https://raw.githubusercontent.com/prjemian/epics-docker/master/n4_areaDetector/start_adsim.sh
     wget https://raw.githubusercontent.com/prjemian/epics-docker/master/n3_synApps/remove_container.sh

The `start_adsim.sh` script runs the docker image in a container.  The default IOC prefix 
is `13SIM1:` as defined in ADSimDetector.  If you supply an IOC prefix to be uses instead of the default, 
do not add the trailing colon, it will be added by the script.  Additionally, the script copies
GUI screen file definitions from both synApps and areaDetector to the subdirectory 
`/tmp/docker_ioc/synapps-6.1-ad-3.7/`.  The script also copies the IOC's boot directory to
`/tmp/docker_ioc/CONTAINER_NAME/iocSimDetector/`.  This is a one-time copy as the IOC starts.  
It does not contain live updates from autosave/restore or other such.

| directory | contents |
| ---- | ---- |
| `/tmp/docker_ioc/synapps-6.1-ad-3.7/screens/adl/` | MEDM `.adl` screens and related files |
| `/tmp/docker_ioc/synapps-6.1-ad-3.7/screens/opi/` | CSS BOY `.opi` screens and related files |
| `/tmp/docker_ioc/synapps-6.1-ad-3.7/screens/ui/` | caQtDM `.ui` screens and related files |

The `remove_container.sh` script stops the IOC in the container, then stops and removes the container.

# create a Sim Detector IOC using prefix: "adsky:"

Note you do not include the trailing `:` character.

     start_adsim.sh adsky

## test that IOC iocadsky is running and accessible from host

(Presumes the host has a working [`caget`](https://epics.anl.gov/base/R3-14/12-docs/CAref.html#caget) executable.)

    user@localhost:~ $ caget adsky:cam1:Acquire
    adsky:cam1:Acquire             Done

## test that IOC iocadsky is running and accessible within the container

(IOC iocadsky has a working [`caget`](https://epics.anl.gov/base/R3-14/12-docs/CAref.html#caget) executable.)

    user@localhost:~ $ docker exec iocadsky caget adsky:cam1:Acquire
    adsky:cam1:Acquire             Done

## start caQtDM GUI for iocadsky:

This is a bash shell script engineered for a Linux host architecture.
(Presumes the host has a working [`caQtDM`](http://caqtdm.github.io/) executable.)

     /tmp/docker_ioc/iocadsky/iocSimDetector/start_caQtDM_adsim

This sets CAQTDM_DISPLAY_PATH as follows:

     CAQTDM_DISPLAY_PATH=.
     CAQTDM_DISPLAY_PATH=${CAQTDM_DISPLAY_PATH}:/tmp/docker_ioc/iocadsky/iocSimDetector
     CAQTDM_DISPLAY_PATH=${CAQTDM_DISPLAY_PATH}:/tmp/docker_ioc/synapps-6.1-ad-3.7/screens/ui

# remove iocadsky container (and first, stop the IOC)

    remove_container.sh iocadsky

----

# docker commands

# Run the image without starting the IOC

1. Create docker container from the latest docker image
1. Give the container a name [consistent](https://epics.anl.gov/bcda/aps/IOCnaming.php) with the prefix.
1. Set the desired [IOC prefix](https://www.aps.anl.gov/BCDA/EPICS-Process-Variable-Naming-Conventions) (`AD_PREFIX` for this docker image).
1. Give the container something to do so it will not quit.  Here, it reports the time every ten seconds.  Basically, *IOC is (still) alive*.

```
docker run \
    -d \
    --net=host \
    --name iocadsky \
    -e "AD_PREFIX=adsky:" \
    prjemian/synapps-6.1-ad-3.7:latest \
    bash -c "while true; do date; sleep 10; done"
```

## start the ADSimDetector IOC (in the running container)

Use the container's name:

    docker exec iocadsky iocSimDetector/simDetector.sh start

## Is iocadsky running? (in the running container)

Use the container's name:

    docker exec iocadsky iocSimDetector/simDetector.sh status

## Restart iocadsky (in the running container)

Use the container's name:

    docker exec iocadsky iocSimDetector/simDetector.sh restart

## Stop iocadsky (without stopping the container)

Use the container's name:

    docker exec iocadsky iocSimDetector/simDetector.sh stop

## Access bash shell of iocadsky container

Use the container's name:

    docker exec -it iocadsky bash

You can `exit` from this shell with confidence 
that it will not stop the IOC or the container.

## Access iocsh of iocadsky EPICS IOC (in the container)

Use the container's name:

    docker exec -it iocadsky iocSimDetector/simDetector.sh console

The IOC runs in a [`screen`]() session.  Type `^a^d` 
(<control>A, then <control>d) to leave the screen 
session with the IOC still running.
If you type `exit`, you will stop the IOC (even though
the container continues running).
See above for how to restart the IOC in the container.

## View the console log of the container

    docker logs iocadsky

This will show the output of the timestamps 
(or output of whatever keep-alive process you are using.)``


## background

* docker source: `prjemian/synapps-6.1-ad-3.7:latest`
* `prjemian/epics-base-7.0.3:latest`
* `prjemian/os_only:latest`
* `ubuntu:latest` (Ubuntu 18.04)
