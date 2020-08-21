#!/bin/bash

# edit the IOC before building synApps
# enable 16 motors and the scaler

# change version of StreamDevice
sed -i s:'/StreamDevice-master':'/StreamDevice-2-8-12':g     ${SUPPORT}/configure/RELEASE

cp examples/motors.iocsh ./
cp examples/std.iocsh    ./
cp ${MOTOR}/modules/motorMotorSim/motorSimApp/iocsh/motorSim.iocsh                 ${MOTOR}/motorApp/iocsh/
cp ${MOTOR}/modules/motorMotorSim/motorSimApp/iocsh/EXAMPLE_motorSim.substitutions ${MOTOR}/motorApp/iocsh/

sed -i s:'#iocshLoad("$(STD)/iocsh/softScaler':'iocshLoad("$(STD)/iocsh/softScaler':g std.iocsh
sed -i s:'#iocshLoad("$(MOTOR)/modules/motorMotorSim/iocsh/motorSim.iocsh"':'iocshLoad("$(MOTOR)/modules/motorMotorSim/motorSimApp/iocsh/motorSim.iocsh"':g motors.iocsh
sed -i s:'dbLoadTemplate("substitutions/motor.substitutions"':'#dbLoadTemplate("substitutions/motor.substitutions"':g motors.iocsh

# remove when https://github.com/epics-modules/xxx/pull/27 is merged and released in new synApps version
# Merged 2019-09-30: Confirm can remove since we are using master
# 2020-05-11: still need it
sed -i s:'< common.iocsh':'< common.iocsh\n< std.iocsh\n< motors.iocsh':g    ${XXX}/iocBoot/iocxxx/st.cmd.Linux


sed -i s/'epicsEnvSet("PREFIX", "xxx:")'/'epicsEnvSet("PREFIX", $(PREFIX))'/g   ${XXX}/iocBoot/iocxxx/settings.iocsh
# sed -i s:'# Shell prompt':'&\nepicsEnvSet("IOC", $(PREFIX))':g     ${XXX}/iocBoot/iocxxx/settings.iocsh

# remove Newport support from motor due to build error
#     ../xpsSFTPUpload.h:3:1: error: 'epicsShareFunc' does not name a type
#         3 | epicsShareFunc int xpsSFTPUpload(std::string IPAddress, std::string trajectoryDirectory, std::string fileName,
#         | ^~~~~~~~~~~~~~
#     ../testSFTPUpload.cpp: In function 'int main(int, char**)':
#     ../testSFTPUpload.cpp:11:16: error: 'xpsSFTPUpload' was not declared in this scope
#     11 |   int status = xpsSFTPUpload("164.54.160.71", "/Admin/Public/Trajectories", "TrajectoryScan.trj",
#         |                ^~~~~~~~~~~~~
#     make[3]: *** [/opt/base/configure/RULES_BUILD:249: testSFTPUpload.o] Error 1
#     make[3]: Leaving directory '/opt/synApps/support/motor-master/modules/motorNewport/newportApp/src/O.linux-x86_64'
sed -i s:'SUBMODULES += motorNewport':'# SUBMODULES += motorNewport':g   ${MOTOR}/modules/Makefile
sed -i s:' devNewport.dbd':'':g   ${XXX}/xxxApp/src/Makefile
sed -i s:' devNewportSeq.dbd':'':g   ${XXX}/xxxApp/src/Makefile
sed -i s:' Newport':'':g   ${XXX}/xxxApp/src/Makefile
