# EPICS synApps

Docker image [`prjemian/synapps`](https://hub.docker.com/r/prjemian/synApps)
providing [EPICS base](https://epics.anl.gov/base/),
[synApps](https://www.aps.anl.gov/BCDA/synApps), and [Area
Detector](https://areadetector.github.io/areaDetector/) software providing
[IOCs](#iocs-provided) (servers) for development, simulation, testing, and
training.

Contents

- [EPICS synApps](#epics-synapps)
  - [Quick start](#quick-start)
  - [What this repository provides](#what-this-repository-provides)
  - [How to use this image](#how-to-use-this-image)
    - [Running an IOC in the container](#running-an-ioc-in-the-container)
  - [Details](#details)
    - [custom synApps](#custom-synapps)
    - [custom Area Detector (ADSimDetector)](#custom-area-detector-adsimdetector)
    - [Hint](#hint)
  - [IOCs Provided](#iocs-provided)
    - [Starter Scripts](#starter-scripts)
  - [Docker Image](#docker-image)
  - [Authors](#authors)
  - [Acknowledgements](#acknowledgements)

## Quick start

Two steps: **_Area detector IOC with simulated camera_**

1. Download and install
   [`iocmgr.sh`](https://raw.githubusercontent.com/prjemian/epics-docker/main/resources/iocmgr.sh)
   (bash shell script for Linux).
2. Run **`iocmgr.sh start adsim test1`** to start `ioctest1`

**That's it!** You just started a [custom](./docs/adsim.md) version of the
[ADSimDetector](https://areadetector.github.io/master/ADSimDetector/simDetector.html)
IOC.

_Next steps_: Get an [EPICS client](./docs/epics_clients.md) to operate the
IOC's controls and view the images it generates.

<!--
TODO: show example caQtDM screen view
-->

## What this repository provides

- [Scripts](./resources/) to install EPICS software to build IOCs (servers)
- [Documentation](./docs/README.md) for the EPICS IOCs
- [Steps](./Dockerfile) to build the [docker image](#docker-image)

**Note**:  This repository does not provide EPICS
[client](./docs/epics_clients.md) software.

## How to use this image

Run custom [XXX](./docs/gp.md) or [ADSimDetector](./docs/adsim.md) IOCs.  Copy
(download) the `iocmgr.sh` shell script to a directory on your executable path
and make the script executable.

See the [Quick Start](#quick-start) section and
[`iocmgr.sh`](./docs/iocmgr.md#examples) for examples.

IOCs are created in docker containers.  If you wish, the container's `/tmp` is
available for read-only mount on the docker host computer.  This table shows the
same directory from the IOC or the host filesystem.  Any files created in the
container (such as by an area detector IOC) will be available as long as the
container is running.

system | filesystem
--- | ---
IOC | `/tmp`
host | `/tmp/docker_ioc/iocPRE`

Use the same docker image (`prjemian/synapps:latest`) for all IOCs.  The
`iocmgr.sh` script runs only _one IOC per container_.  Starting containers is
usually very fast.

### Running an IOC in the container

Running an IOC in a container is usually a two-step process, similar to running
an IOC in any computer.

1. Start a container with the image (and any additional features such as network and volume provisioning).  Use `docker run ...`
2. Start the IOC _in the container_ (usually with `screen` or `procServ`, so it runs in the background)  Use `docker exec ...`.

<!--
TODO: document how to mount container directories: `/tmp` (and `/opt`)

TODO: here's an interactive session as an example
# Start an interactive session from the docker host workstation:
docker run -it --rm prjemian/synapps

# Next commands are in the docker container...

# set a PV PREFIX for the new IOC
export PREFIX=demo:

# run a GP IOC (in a background `screen` session)
gp.sh start

# check a PV value
caget demo:UPTIME
-->

## Details

Additional [documentation](./docs/README.md) is available.

### custom synApps

_Download_ [`iocmgr.sh`](./docs/iocmgr.md#download) (if not already installed)

These IOCs will use the [`GP`](./docs/gp.md) IOC support.

```sh
cd ~/bin
wget https://raw.githubusercontent.com/prjemian/epics-docker/main/resources/iocmgr.sh
chmod +x iocmgr.sh
```

_Run_ two separate [GP](./docs/gp.md) IOCs with prefixes `ocean:` and
`sky:`.  (Do not specify the trailing `:`.  The script will manage that for you.)

```sh
iocmgr.sh start GP ocean
iocmgr.sh start GP sky
```

### custom Area Detector (ADSimDetector)

_Download_ [`iocmgr.sh`](./docs/iocmgr.md#download) (if not already installed)

```sh
cd ~/bin
wget https://raw.githubusercontent.com/prjemian/epics-docker/main/resources/iocmgr.sh
chmod +x iocmgr.sh
```

_Run_ two separate [ADSIM](./docs/gp.md) IOCs with prefixes `air:` and
`land:`.  (Do not specify the trailing `:`.  The script will manage that for you.)

```sh
iocmgr.sh start ADSIM air
iocmgr.sh start ADSIM land
```

### Hint

You _could_ create a new script to start all the IOCs you want.
Here's an example which starts all four IOCs above:

```bash
#!/bin/bash

iocmgr.sh restart GP ocean
iocmgr.sh restart GP sky
iocmgr.sh restart ADSIM air
iocmgr.sh restart ADSIM oxy
```

- Save this into `~/bin/start_iocs.sh`
- make it executable: **`chmod +x ~/bin/start_iocs.sh`**
- then call it to start/restart the four IOCs: **`start_iocs.sh`**

## IOCs Provided

<!--
TODO: add docs for XXX, ADSimDetector, ADURL, and pvaDriver IOCs
-->

- XXX
- ADSimDetector
- ADURL (TODO)
- pvaDriver (TODO)
- [GP](./docs/gp.md), a custom XXX with user PREFIX
- [ADSIM](./docs/adsim.md), a custom ADSimDetector with user PREFIX

### Starter Scripts

script | location | comments
--- | --- | ---
`iocmgr.sh` | docker host | User script to manage IOCs and GUIs
`start_MEDM_PRE` | container `/tmp` | Called by `iocmgr.sh` (start the MEDM GUI for `PRE` IOC)
`start_caQtDM_PRE` | container `/tmp` | Called by `iocmgr.sh` (start the caQtDM GUI for `PRE` IOC)
`adsim.sh` | container `/root/bin` | Starts the custom ADSimDetector IOC in the container.
`gp.sh` | container `/root/bin` | Starts the custom XXX IOC in the container.

## Docker Image

The current docker image (`prjemian/synapps:latest`) is listed in the next
table.  A full list of related docker images is [on a separate
page](./docs/docker_images.md).

release | image | docs | notes
--- | --- | --- | ---
**v2.0.0** | [`prjemian/synApps`](https://hub.docker.com/r/prjemian/synApps/tags) | [docs](./README.md) | Debian 11 Bullseye, EPICS base 7.0.5, synApps 6.2.1, AD 3.11 (all-in-one)

## Authors

- Pete Jemian

## Acknowledgements

- Contributors
  - Chen Zhang
  - Jeff Hoffman
  - Quan Zhou

- moved here from [virtualbeamline](https://github.com/prjemian/virtualbeamline),
  a fork of [KedoKudo/virtualbeamline](https://github.com/KedoKudo/virtualbeamline).
