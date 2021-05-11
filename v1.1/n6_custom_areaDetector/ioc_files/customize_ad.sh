#!/bin/bash

# customize_ad.sh

# * IOCADSIMDETECTOR
# * IOCADURL

# ------------------------------------------------------

cd ${IOCADSIMDETECTOR}
pwd
ls -lAFgh

cp ${IOCXXX}/softioc/xxx.sh ./adsim.sh
sed -i s+'IOC_NAME=xxx'+'IOC_NAME=\${PREFIX:-13SIM1}'+g   ./adsim.sh
sed -i s:'IOC_BINARY=xxx':'IOC_BINARY=simDetectorApp':g   ./adsim.sh
sed -i s:'IOC_STARTUP_DIR=/home/username/epics/ioc/synApps/xxx/iocBoot/iocxxx/softioc':'':g   ./adsim.sh
sed -i s:'IOC_STARTUP_DIR=`dirname ${SNAME}`/..':'IOC_STARTUP_DIR=`dirname ${SNAME}`':g   ./adsim.sh
sed -i s:'IOC_STARTUP_FILE="st.cmd.Linux"':'IOC_STARTUP_FILE="st.cmd"':g   ./adsim.sh

# default PREFIX is 13SIM1:
sed -i s/'epicsEnvSet("PREFIX", "13SIM1:")'/'epicsEnvSet("PREFIX", $(PREFIX=13SIM1:))'/g   ./st_base.cmd

cat >> ./st.cmd << EOF
#
dbl > dbl-all.txt
EOF

# ------------------------------------------------------

cd ${IOCADURL}
pwd
ls -lAFgh

# default PREFIX is 13URL1:
sed -i s/'epicsEnvSet("PREFIX", "13URL1:")'/'epicsEnvSet("PREFIX", $(PREFIX=13URL1:))'/g   ./st_base.cmd

# TODO: update GUI files, too?
