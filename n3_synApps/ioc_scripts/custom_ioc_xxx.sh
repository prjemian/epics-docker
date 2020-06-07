#!/bin/bash

# build a custom IOC: xxx
echo "# TODO: build a custom IOC: xxx"

# COPY ./ioc_scripts/iocAdminSoft_aliases.db .
# COPY ./ioc_scripts/iocAdminSoft_aliases.iocsh .

# TODO: add components from start_xxx.sh here
# fix for https://github.com/epics-modules/xxx/issues/30                                     ${XXX}/iocBoot/iocxxx/common.iocsh
# RUN sed -i s+"IOC=\$(PREFIX)\")"+"IOC=\$(PREFIX)\")\n< iocAdminSoft_aliases.iocsh"+g ${XXX}/iocBoot/iocxxx/st.cmd.Linux
