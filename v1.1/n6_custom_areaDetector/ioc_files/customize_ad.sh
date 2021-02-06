#!/bin/bash

# customize_ad.sh

# * IOCADSIMDETECTOR
# * IOCADURL

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

# TODO: update GUI files, too?
