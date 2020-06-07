#!/bin/bash

# configure area detector for PVA, qsrv, ...

# revert these items turned off in assemble_synApps.sh
sed -i s:'WITH_PVA = NO':'WITH_PVA = YES':g configure/CONFIG_SITE.local
sed -i s:'WITH_QSRV = NO':'WITH_QSRV = YES':g configure/CONFIG_SITE.local

# sed -i s:'WITH_NEXUS     = YES':'WITH_NEXUS = NO':g configure/CONFIG_SITE.local

# build ADURL
sed -i s:'#ADURL=':'ADURL=':g configure/RELEASE.local
