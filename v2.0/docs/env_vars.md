# Environment Variables

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
