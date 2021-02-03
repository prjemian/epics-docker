#!/bin/bash

# edit_xxx.sh

cd ${XXX}/iocBoot/iocxxx/

# enable 16 motors and the scaler

cp examples/motors.iocsh ./
cp examples/std.iocsh    ./

sed -i s:'#iocshLoad("$(MOTOR)/modules/motorMotorSim/iocsh/motorSim.iocsh"':'iocshLoad("$(MOTOR)/iocsh/motorSim.iocsh"':g motors.iocsh
sed -i s:'dbLoadTemplate("substitutions/motor.substitutions"':'#dbLoadTemplate("substitutions/motor.substitutions"':g motors.iocsh

sed -i s:'#iocshLoad("$(STD)/iocsh/softScaler':'iocshLoad("$(STD)/iocsh/softScaler':g std.iocsh

sed -i s:'< common.iocsh':'< common.iocsh\n< std.iocsh\n< motors.iocsh':g    ${XXX}/iocBoot/iocxxx/st.cmd.Linux

# in Linux shell: `export PREFIX=something:`
sed -i s/'epicsEnvSet("PREFIX", "xxx:")'/'epicsEnvSet("PREFIX", $(PREFIX))'/g   ${XXX}/iocBoot/iocxxx/settings.iocsh

# for dbLoadRecords(... iocAdminSoft.db
sed -i s:'IOC=xxx':'IOC=$(PREFIX)':g                                            ${XXX}/iocBoot/iocxxx/st.cmd.Linux
