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
  - [Authors](#authors)
  - [Acknowledgements](#acknowledgements)

## Quick start 

***Area detector IOC with simulated camera***

1. Download and install `iocmgr.sh` bash shell script for Linux.
2. Run `iocmgr.sh start adsim test1` to start `ioctest1`

**That's it!** You just started a custom
[ADSimDetector](https://areadetector.github.io/master/ADSimDetector/simDetector.html)
IOC.

*Next steps*: Get an [EPICS client](./v2.0/docs/epics_clients.md) (not part of
this docker image) to operate the EPICS controls and view the images.

### custom synApps

*Download* [`iocmgr.sh`](./v2.0/docs/iocmgr.md#download) (if not already installed)

These IOCs will use the [`GP`](./v2.0/docs/gp.md) IOC support.

```sh
cd ~/bin
wget https://raw.githubusercontent.com/prjemian/epics-docker/main/v2.0/resources/iocmgr.sh
chmod +x iocmgr.sh
```

*Run* two separate [GP](./v2.0/docs/gp.md) IOCs with prefixes `blue:` and
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

*Run* two separate [ADSIM](./v2.0/docs/gp.md) IOCs with prefixes `air:` and
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

## Authors

- Pete Jemian

## Acknowledgements

- Contributors
  - Chen Zhang
  - Jeff Hoffman
  - Quan Zhou

- moved here from [virtualbeamline](https://github.com/prjemian/virtualbeamline),
  a fork of [KedoKudo/virtualbeamline](https://github.com/KedoKudo/virtualbeamline).
