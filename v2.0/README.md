# EPICS synApps

**_Note_**: under construction

Contents

- [EPICS synApps](#epics-synapps)
  - [How to use this image](#how-to-use-this-image)
  - [Details](#details)
  - [IOCs Provided](#iocs-provided)
    - [Starter Scripts](#starter-scripts)
  - [Initial Plans](#initial-plans)

## How to use this image

Run custom XXX or ADSimDetector IOCs.  Copy (download) the `iocmgr.sh` shell
script to a directory on your executable path and make the script executable.

See [](../README.md#quick-start) and [`iocmgr.sh`](./docs/iocmgr.md#examples) for examples.

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
