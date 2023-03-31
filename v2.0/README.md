# EPICS synApps

**_Note_**: under construction

Contents

- [EPICS synApps](#epics-synapps)
  - [How to use this image](#how-to-use-this-image)
  - [Initial Plans](#initial-plans)
  - [Environment Variables](#environment-variables)
  - [IOCs Provided](#iocs-provided)

## How to use this image

TODO

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

## Environment Variables

variable | comments
--- | ---
`APP_ROOT` | parent directory of `EPICS_BASE` and synApps
`EPICS_BASE` | directory containg specific version of EPICS base to be used
`EPICS_HOST_ARCH` | architecture name for EPICS software compilation
`PATH` | list of directories for executable software

## IOCs Provided

- XXX
- ADSimDetector
- ADURL
- pvaDriver
- GP
