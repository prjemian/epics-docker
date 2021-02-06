#!/bin/bash

# customize_ad.sh

# * ADSIMDETECTOR_IOC_BOOT_DIR
# * ADURL_IOC_BOOT_DIR

# ------------------------------------------------------

cd ${IOCADSIMDETECTOR}
pwd
ls -lAFgh

# default PREFIX is 13SIM1:
sed -i s/'epicsEnvSet("PREFIX", "13SIM1:")'/'epicsEnvSet("PREFIX", $(PREFIX=13SIM1:))'/g   ./st_base.cmd

# ------------------------------------------------------

cd ${IOCADURL}
pwd
ls -lAFgh

# default PREFIX is 13URL1:
sed -i s/'epicsEnvSet("PREFIX", "13URL1:")'/'epicsEnvSet("PREFIX", $(PREFIX=13URL1:))'/g   ./st_base.cmd

# TODO: modify IOCs with custom PREFIX
# Compare with n5*/ioc_files/customie_xxx.sh

# WORKDIR ${SUPPORT}
# ENV AD_PREFIX="13SIM1:"
# cp ${IOCXXX}/softioc/xxx.sh ./iocSimDetector/simDetector.sh
# sed -i s:'IOC_NAME=xxx':'IOC_NAME=simDetector':g   ./iocSimDetector/simDetector.sh
# sed -i s:'IOC_BINARY=xxx':'IOC_BINARY=simDetectorApp':g   ./iocSimDetector/simDetector.sh
# sed -i s:'IOC_STARTUP_DIR=/home/username/epics/ioc/synApps/xxx/iocBoot/iocxxx/softioc':'':g   ./iocSimDetector/simDetector.sh
# sed -i s:'IOC_STARTUP_DIR=`dirname ${SNAME}`/..':'IOC_STARTUP_DIR=`dirname ${SNAME}`':g   ./iocSimDetector/simDetector.sh
# sed -i s:'IOC_STARTUP_FILE="st.cmd.Linux"':'IOC_STARTUP_FILE="st.cmd"':g   ./iocSimDetector/simDetector.sh
# sed -i s/'epicsEnvSet("PREFIX", "13SIM1:")'/'epicsEnvSet("PREFIX", \$\{AD_PREFIX})'/g   ./iocSimDetector/st_base.cmd
# echo "\ndbl > dbl-all.txt" >> ./iocSimDetector/st_base.cmd
# # done editing
