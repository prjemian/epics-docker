# epics-docker

EPICS base, synApps, and Area Detector packages providing IOCs (servers) for
testing, development, training, and simulation.

## Contents

- [epics-docker](#epics-docker)
  - [Contents](#contents)
  - [Quick start](#quick-start)
    - [custom synApps](#custom-synapps)
    - [custom Area Detector (ADSimDetector)](#custom-area-detector-adsimdetector)
    - [Hint](#hint)
  - [Docker Image](#docker-image)
  - [EPICS Client Software](#epics-client-software)
  - [Authors](#authors)
  - [Acknowledgements](#acknowledgements)

## Quick start 

***Area detector IOC with simulated camera***

1. Download and install `iocmgr.sh` bash shell script for Linux.
2. Run `iocmgr.sh start adsim test1` to start `ioctest1`
3. You have just started a custom [ADSimDetector](https://areadetector.github.io/master/ADSimDetector/simDetector.html) IOC.

*Next steps*: Get an EPICS client (not part of this docker image) to operate the EPICS
controls and view the images.

### custom synApps

*Download* [`iocmgr.sh`](./v2.0/docs/iocmgr.md#download) (if not already installed)

These IOCs will use the [`GP`](./v2.0/docs/gp.md) IOC support.

```sh
cd ~/bin
wget https://raw.githubusercontent.com/prjemian/epics-docker/main/v2.0/resources/iocmgr.sh
chmod +x iocmgr.sh
```

*Start* two separate [GP](./v2.0/docs/gp.md) IOCs with prefixes `blue:` and
`sky:`.  (Do not specify the trailing `:`.  The script will manage that for you.)

```sh
iocmgr.sh start GP blue
iocmgr.sh start GP sky
```

### custom Area Detector (ADSimDetector)

*Download* [`iocmgr.sh`](./v2.0/docs/iocmgr.md#download) (if not already installed)

```sh
cd ~/bin
wget https://raw.githubusercontent.com/prjemian/epics-docker/main/v2.0/resources/iocmgr.sh
chmod +x iocmgr.sh
```

*Start* two separate [ADSIM](./v2.0/docs/gp.md) IOCs with prefixes `air:` and
`oxy:`.  (Do not specify the trailing `:`.  The script will manage that for you.)

```sh
iocmgr.sh start ADSIM air
iocmgr.sh start ADSIM oxy
```

### Hint

You _could_ create a new script to start all the IOCs you want.
Here's an example which starts all four IOCs above:

```bash
#!/bin/bash

iocmgr.sh restart GP blue
iocmgr.sh restart GP sky
iocmgr.sh restart ADSIM air
iocmgr.sh restart ADSIM oxy
```

- Save this into `~/bin/start_iocs.sh`
- make it executable: `chmod +x ~/bin/start_iocs.sh`
- then call it to start/restart the four IOCs: `start_iocs.sh`

## Docker Image

The current docker image (`prjemian/synapps:latest`) is listed in the next
table.  A full list of related docker images is [on a separate
page](./v2.0/docs/docker_images.md).

release | image | docs | notes
--- | --- | --- | ---
**v2.0.0** | [`prjemian/synApps`](https://hub.docker.com/r/prjemian/synApps/tags) | [docs](./v2.0/README.md) | Debian 11 Bullseye, EPICS base 7.0.5, synApps 6.2.1, AD 3.11 (all-in-one)

## EPICS Client Software

The EPICS client software packages in the next table each provide control and/or
image viewer capabilities.

package | command line controls | GUI controls | image viewer
--- | --- | --- | ---
bluesky | yes | notebook | notebook
c2DataViewer | no | no | yes (PVA)
caQtDM | no | yes | yes (CA)
CSS BOY | no | yes | yes
imageJ | no | no | yes
MEDM | no | yes | no
p4p | yes | no | no
phoebus | no | yes | yes
pvapy | yes (PVA) | ? | no
PyDM |  | yes | yes (CA)
pyepics | yes | notebook | no
SPEC | yes | no | no

- CA: Epics Channel Access protocol
- PVA: EPICS PV Access protocol
- notebook: Jupyter notook

**Note**: These EPICS client packages are not part of the `prjemian/synapps` docker
image.

## Authors

- Pete Jemian

## Acknowledgements

- Contributors
  - Chen Zhang
  - Jeff Hoffman
  - Quan Zhou

- moved here from [virtualbeamline](https://github.com/prjemian/virtualbeamline),
  a fork of [KedoKudo/virtualbeamline](https://github.com/KedoKudo/virtualbeamline).
