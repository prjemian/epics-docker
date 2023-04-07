# EPICS synApps

**_Note_**: under construction

Contents

- [EPICS synApps](#epics-synapps)
  - [How to use this image](#how-to-use-this-image)
  - [Details](#details)
  - [Environment Variables](#environment-variables)
  - [IOCs Provided](#iocs-provided)
    - [Starter Scripts](#starter-scripts)
  - [Software versions](#software-versions)
  - [Source Code](#source-code)
  - [Initial Plans](#initial-plans)

## How to use this image

Run custom XXX or ADSimDetector IOCs.  Copy (download) the `iocmgr.sh` shell
script to a directory on your executable path and make the script executable.

Here are some examples for a GP IOC with prefix `gp`:` and an ADSIM IOC with
prefix `ad1:`:

command | description
--- | ---
`iocmgr.sh start gp gp1` | Start a GP (custom XXX) IOC with prefix `gp1:`
`iocmgr.sh caqtdm gp gp1` | Start caQtDM for the GP IOC with prefix `gp1:`
`iocmgr.sh status gp gp1` | Show status of the GP IOC with prefix `gp1:`
`iocmgr.sh stop gp gp1` | Show status of the GP IOC with prefix `gp1:`
`iocmgr.sh start adsim ad1` | Start a ADSIM (custom ADSimDetector) IOC with prefix `ad1:`
`iocmgr.sh caqtdm adsim ad1` | Start caQtDM for the ADSIM IOC with prefix `ad1:`
`iocmgr.sh status adsim ad1` | Show status of the ADSIM IOC with prefix `ad1:`
`iocmgr.sh stop adsim ad1` | Show status of the ADSIM IOC with prefix `ad1:`

IOCs are created in docker containers and configured with a mount point that is
available read-only to the docker host computer.  This table shows the same
directory from the IOC or the host filesystem.  Any files created in the
container will be available as long as the container is running.

system | filesystem
--- | ---
IOC | `/tmp`
host | `/tmp/docker_ioc/iocPRE`

Use the same docker image (`prjemian/synapps:latest`) for all IOCs.  The
`iocmgr.sh` script runs only *one IOC per container*.  Starting containers is
usually very fast.

## Details

Additional [documentation](./docs/README.md) is available.

## Environment Variables

Defined in image file `~/.bash_aliases`:

variable | comments
--- | ---
`APP_ROOT` | parent directory of `EPICS_BASE` and synApps
`EPICS_BASE` | directory containg specific version of EPICS base to be used
`EPICS_HOST_ARCH` | architecture name for EPICS software compilation
`IOCADSIM` | Startup directory for ADSIM IOC
`IOCGP` | Startup directory for GP IOC
`LOG_DIR` | directory with log files while building the image
`PATH` | list of directories for executable software
`RESOURCES` | directory with scripts and other resources to install the image contents

```bash
# file: ~/.bash_aliases
export LS_OPTIONS='--color=auto'
export EDITOR=nano
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/bin
export PROMPT_DIRTRIM=3
alias ls='ls --color=auto'
alias ll='ls -lAFgh'
export APP_ROOT=/opt
export RESOURCES=/opt/resources
export LOG_DIR=/opt/logs
#
# epics_base.sh
export BASE_VERSION="7.0.5"
export EPICS_BASE_NAME="base-7.0.5"
export EPICS_BASE="/opt/base-7.0.5"
export EPICS_HOST_ARCH="linux-x86_64"
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/bin:/opt/base-7.0.5/bin/linux-x86_64"
#
# epics_synapps.sh
export SYNAPPS="/opt/synApps"
export SUPPORT="/opt/synApps/support"
export IOCS_DIR="/opt/synApps/iocs"
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/bin:/opt/base-7.0.5/bin/linux-x86_64:/opt/synApps/support/utils"
export CAPUTRECORDER_HASH="master"
export MOTOR_HASH="R7-2-2"
export AD="/opt/synApps/support/areaDetector-R3-11"
export ASYN="/opt/synApps/support/asyn-R4-42"
export IOCXXX="/opt/synApps/support/xxx-master/iocBoot/iocxxx"
export MOTOR="/opt/synApps/support/motor-R7-2-2"
export XXX="/opt/synApps/support/xxx-master"
#
# create_gp_ioc.sh
export GP="/opt/synApps/iocs/iocgp"
export IOCGP="/opt/synApps/iocs/iocgp/iocBoot/iocgp"
#
# create_adsim_ioc.sh
export IOCADSIM="/opt/synApps/iocs/iocadsim"
export AREA_DETECTOR="/opt/synApps/support/areaDetector-R3-11"
export ADSIMDETECTOR="/opt/synApps/support/areaDetector-R3-11/ADSimDetector/iocs/simDetectorIOC"
export IOCADSIMDETECTOR="/opt/synApps/support/areaDetector-R3-11/ADSimDetector/iocs/simDetectorIOC/iocBoot/iocSimDetector"
```

## IOCs Provided

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

## Software versions

name | version
--- | ---
OS | `debian:stable-slim`
EPICS base | 7.0.5
synApps | 6.2.1
areaDetector | R3-11
asyn | R4-42
autosave | R5-10-2
busy | R1-7-3
calc | R3-7-4
caputRecorder | master
ether_ip-ether_ip | 3-2
iocStats | 3-1-16
ip | R2-21-1
ipac | 2-16
lua | R3-0-2
mca | R7-9
modbus | R3-2
motor | R7-2-2
optics | R2-13-5
scaler | 4-0
seq | 2-2-9
sscan | R2-11-4
std | R3-6-3
StreamDevice | 2-8-14
xxx | master

## Source Code

The source code is installed in `/opt` in the following subdirectories:

content | description
--- | ---
`assemble_synApps.sh` | script that creates content in `synApps/support`
`base` | soft link to `base-7.0.5`
`base-7.0.5` | EPICS base
`logs` | log files when image features were built
`resources` | scripts for building or running IOCs
`synApps/support` | the synApps modules
`synApps/support/screens` | GUI screens from all the synApps modules
`synApps/iocs` | custom synApps IOCs

## Initial Plans

Redesign the image with these requirements:

- image provides the OS (as a sysAdmin would maintain it)
- All IOCs possible from this one, single image
- EPICS components built by scripts
  - EPICS base
  - EPICS synApps
    - same as in v1.1
    - area detector
      - ADSimDetector
      - ADURL
      - pvaDriver
  - screens
  - custom IOCs (with user-specified prefixes)
    - XXX
    - ADSimDetector
    - ADURL
    - pvaDriver
- scripts are copied to the image as each component is built
- scripts could each be run outside the image to build locally

This new design should be easier to maintain and upgrade than either v1.0 or
v1.1 images.  By providing all IOCs in a single image, this will reduce the
number of downloads in CI processes.
