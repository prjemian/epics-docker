# README.md

TODO:

The
[`prjemian/synApps-6.2`](https://hub.docker.com/r/prjemian/synapps-6.2/tags)
image provides EPICS [synApps release
6.2](https://www.aps.anl.gov/BCDA/synApps), EPICS software tools that
help to create a control system for beamlines.

- [README.md](#readmemd)
  - [Overview](#overview)
    - [modifications of synApps-6.2](#modifications-of-synapps-62)
  - [default application](#default-application)
  - [default working directory](#default-working-directory)
  - [example use](#example-use)
  - [This Docker Image Provides ...](#this-docker-image-provides-)
    - [motor assignments](#motor-assignments)
  - [Environment variables](#environment-variables)
  - [Docker images used by this image](#docker-images-used-by-this-image)

## Overview

The [EPICS synApps](https://www.aps.anl.gov/BCDA/synApps) module is
installed (already compiled) in directory: `/opt/synApps/support`.

### modifications of synApps-6.2

* the IOC prefix may be specified
  * enable this image to create multiple such IOCs with different PV prefixes
* various components from the synApps [optics](https://github.com/epics-modules/optics) module have been enabled
* various components from the synApps [std](https://github.com/epics-modules/std) module have been enabled
* motor channels have been marked for use by components from optics and std
* a database of general purpose variables (bit, int, float, text, longtext) has been added

## default application

By default, the bash shell is run but no IOC is started.

    docker run -ti --rm --net=host --name synApps prjemian/custom-synapps-6.2:latest

See the [*example use*](#example-use) section for an IOC example.

## default working directory

The default working directory is `${SUPPORT}`

## example use

Start the IOC in a container with prefix `ioc:`:

    docker run -ti -d --rm --net=host \
        --name iocioc -e PREFIX=ioc: \
        prjemian/custom-synapps-6.2:latest \
        iocxxx/softioc/xxx.sh run

Once the IOC has started, the full list of PVs provided
will be available in file: `iocxxx/dbl-all.txt`.

    docker exec iocioc cat iocxxx/dbl-all.txt

You can interact with *iocioc* console in the container by attaching
to the container:

    docker attach iocxxx

Detach with the keyboard combination `^P ^Q` (<control>+p <control>+q).
If you `exit` the container, it will stop.

You can access the bash shell in the *iocioc* container:

    docker exec -it iocxxx bash

From the bash shell in the container, you may use EPICS
commands such as `caget` to view the content of a PV:

    root@345225848f10:/opt/synApps/support# caget xxx:UPTIME
    xxx:UPTIME                     00:05:33

The difference between these two methods is shown in this table:

command | provides | what happens when you type `exit`
--- | --- | ---
`docker attach iocxxx` | IOC console | IOC and container stop
`docker exec -it iocxxx bash` | container linux command line | IOC & container stay running

## This Docker Image Provides ...

* `${IOCXXX}` : IOC boot directory ready to run with customizable PV prefix (default: `xxx:`)

* simulated 48 motors: : `$(PREFIX)m1` .. `$(PREFIX)m48`
* common:
  * autosave support (disappears once the container is removed unless mapped to external volume)
  * Stream protocol support
  * devIocStats, such as `$(PREFIX)UPTIME`
  * caPutRecorder support
  * 4 sscan records: `$(PREFIX)scan1` ..  `$(PREFIX)scan4` and  `$(PREFIX)scanH`
  * configMenu support
  * userCalc support
    * 10 swait records: `$(PREFIX)userCalc1` .. `$(PREFIX)userCalc10`
    * 10 scalcout records: `$(PREFIX)userStringCalc1` .. `$(PREFIX)userStringCalc10`
  * 2 sets of luascript support: `$(PREFIX)set1`, `$(PREFIX)set2`
  * string sequence records
  * interpolation support
  * 2 busy records:  `$(PREFIX)mybusy1`, `$(PREFIX)mybusy2`
  * alive record support (for use at Advanced Photon Source)
* from [optics](https://github.com/epics-modules/optics):
  * simulated 4-blade slits: `$(PREFIX)Slit1H` and `$(PREFIX)Slit1V`
  * simulated optical table: `$(PREFIX)Table1`
  * simulated double-crystal *boomerang* monochromator (energy, wavelength, and motions: theta, Y1, Z2)
  * simulated 4-circle diffractometer database (axes: 2theta, theta, chi, phi)
* from [std](https://github.com/epics-modules/std):
  * 1 Coarse/Fine stage database: `$(PREFIX)cf1`
  * 1 ramp/tweak database: `$(PREFIX)rt1`
  * simulated 16-channel scaler: `$(PREFIX)scaler1`
  * 1 4-step measurement database: `$(PREFIX)4step`
  * 1 PV history database
  * 1 software timer database
  * 1 miscellaneous PVs database
    * 1 ISO8601 time record: `$(PREFIX)iso8601`
  * 1 fb_epid database: `$(PREFIX)epid1`
* 20 sets of general purpose PVs: `$(PREFIX)gp`
  * 1-bit `bit`: `$(PREFIX)gp:bit1` ..  `$(PREFIX)gp:bit20` (default labels: 0="off", 1="on")
  * 32-bit `int`: `$(PREFIX)gp:int1` ..  `$(PREFIX)gp:int20`
  * double-precision `float`: `$(PREFIX)gp:float1` ..  `$(PREFIX)gp:float20`
  * 40-character `text`: `$(PREFIX)gp:text1` ..  `$(PREFIX)gp:text20`
  * 1024 character `longtext`: `$(PREFIX)gp:longtext1` ..  `$(PREFIX)gp:longtext20`

To customize the PV prefix, add the `PREFIX` environment variable when
starting the container such as in the examples above.

With this docker image, it is possible to create multiple containers,
each running an EPICS IOC.  Each container should be started with a
different `PREFIX` to avoid name contention amongst the available EPICS
PVs.  There are other ways to use this image to run multiple IOCs in the
same container, but that description is beyond the scope of this
documentation.

### motor assignments

motor | assignment
--- | ---
m1 - m28 | unassigned
m29 | 4-circle diffractometer M_TTH
m30 | 4-circle diffractometer M_TH
m31 | 4-circle diffractometer M_CHI
m32 | 4-circle diffractometer M_PHI
m33 | Coarse/Fine stage, coarse CM
m34 | Coarse/Fine stage, fine FM
m35 | optical table M0X
m36 | optical table M0Y
m37 | optical table M1Y
m38 | optical table M2X
m39 | optical table M2Y
m40 | optical table M2Z
m41 | Slit1V:mXp
m42 | Slit1V:mXn
m43 | Slit1H:mXp
m44 | Slit1H:mXn
m45 | monochromator M_THETA
m46 | monochromator M_Y
m47 | monochromator M_Z
m48 | unassigned


## Environment variables

These environment variables were defined when creating this docker image
(from `grep ENV Dockerfile`):

    # --none--


## Docker images used by this image

These are the docker images from which this image is based:

from | image | description
--- | --- | ---
`prjemian/synapps-6.2` |  `prjemian/custom-synapps-6.2` | this image
`prjemian/epics-base-7.0.4.1` |  `prjemian/synapps-6.2` | synApps release 6.2
`prjemian/os_only-1.1` | `prjemian/epics-base-7.0.4.1` |  EPICS base release 7.0.4.1
`ubuntu` | `prjemian/os_only-1.1` | Linux OS for this EPICS installation
dockerhub | `ubuntu` | Ubuntu 20.04.1 LTS (at the time of the build)
