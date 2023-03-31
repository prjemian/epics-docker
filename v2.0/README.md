# EPICS synApps

**_Note_**: under construction

Contents

- [EPICS synApps](#epics-synapps)
  - [How to use this image](#how-to-use-this-image)
  - [Environment Variables](#environment-variables)
  - [IOCs Provided](#iocs-provided)
    - [Starter Scripts](#starter-scripts)
  - [Software versions](#software-versions)
  - [Initial Plans](#initial-plans)

## How to use this image

TODO

## Environment Variables

Defined in image file `~/.bash_aliases`:

variable | comments
--- | ---
`APP_ROOT` | parent directory of `EPICS_BASE` and synApps
`EPICS_BASE` | directory containg specific version of EPICS base to be used
`EPICS_HOST_ARCH` | architecture name for EPICS software compilation
`LOG_DIR` | directory with log files while building the image
`PATH` | list of directories for executable software
`RESOURCES` | directory with scripts and other resources to install the image contents

## IOCs Provided

- XXX
- ADSimDetector
- ADURL
- pvaDriver
- GP

### Starter Scripts

TODO:

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
xxx | R6-2-1

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
