#!/bin/bash

echo "# running: $(readlink -f ${0})"
source "${HOME}/.bash_aliases"

echo "# ................................ repair iocStats timezone setup"
# change the TIMEZONE environment variable per issue #30
# https://github.com/prjemian/epics-docker/issues/30
dbfile="${SUPPORT}/$(ls ${SUPPORT} | grep iocStats)/db/iocAdminSoft.db"
sed -i s:'EPICS_TIMEZONE':'EPICS_TZ':g "${dbfile}"
