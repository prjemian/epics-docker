#!/bin/bash

# customize_xxx.sh

cd ${IOCXXX}/

# PV prefix is $PREFIX (default: xxx:)
# enable:
# * 56 motors
# * scaler
# * Kohzu monochromator

cp examples/motors.iocsh ./
cp examples/optics.iocsh    ./
cp examples/std.iocsh    ./

sed -i s:'#iocshLoad("$(MOTOR)/modules/motorMotorSim/iocsh/motorSim.iocsh"':'iocshLoad("$(MOTOR)/iocsh/motorSim.iocsh"':g ./motors.iocsh
sed -i s:'LOW_LIM=':'HIGH_LIM=32000, LOW_LIM=':g ./motors.iocsh
sed -i s:'NUM_AXES=16':'NUM_AXES=56':g ./motors.iocsh

# re-write the substitutions file for 48 motors (easier than modifying it)
export SUBFILE=./substitutions/motorSim.substitutions
echo file \"\$\(MOTOR\)/db/asyn_motor.db\"  > ${SUBFILE}
echo {  >> ${SUBFILE}
echo pattern  >> ${SUBFILE}
echo {N,  M, ADDR, DESC, EGU, DIR, VELO, VBAS, ACCL, BDST, BVEL, BACC, MRES, PREC, INIT}  >> ${SUBFILE}
for n in $(seq 1 48); do
    echo {${n}, \"m${n}\", $((${n}-1)), \"motor ${n}\",  degrees,  Pos,  1, .1, .2, 0, 1, .2, 0.01, 5, \"\"}  >> ${SUBFILE}
done
echo }  >> ${SUBFILE}
export SUBFILE=

sed -i s:'dbLoadTemplate("substitutions/motor.substitutions"':'#dbLoadTemplate("substitutions/motor.substitutions"':g ./motors.iocsh

sed -i s:'#iocshLoad("$(STD)/iocsh/softScaler':'iocshLoad("$(STD)/iocsh/softScaler':g ./std.iocsh

sed -i s:'< common.iocsh':'< common.iocsh\n< motors.iocsh':g    ./st.cmd.Linux
sed -i s:'< common.iocsh':'< common.iocsh\n< optics.iocsh':g    ./st.cmd.Linux
sed -i s:'< common.iocsh':'< common.iocsh\n< std.iocsh':g    ./st.cmd.Linux

# default PREFIX is xxx:
sed -i s/'IOC_NAME=xxx'/'export PREFIX=${PREFIX:-xxx:\}\nIOC_NAME=\$\{PREFIX\}'/g   ./softioc/xxx.sh
sed -i s/'epicsEnvSet("PREFIX", "xxx:")'/'epicsEnvSet("PREFIX", $(PREFIX=xxx:))'/g   ./settings.iocsh

# for dbLoadRecords(... iocAdminSoft.db
sed -i s:'IOC=xxx':'IOC=$(PREFIX)':g  ./st.cmd.Linux

# motor assignments:
# m29 4-circle diffractometer M_TTH
# m30 4-circle diffractometer M_TH
# m31 4-circle diffractometer M_CHI
# m32 4-circle diffractometer M_PHI
# m33 Coarse/Fine stage, coarse CM
# m34 Coarse/Fine stage, fine FM
# m35 table M0X
# m36 table M0Y
# m37 table M1Y
# m38 table M2X
# m39 table M2Y
# m40 table M2Z
# m41 Slit1V:mXp
# m42 Slit1V:mXn
# m43 Slit1H:mXp
# m44 Slit1H:mXn
# m45 monochromator M_THETA
# m46 monochromator M_Y
# m47 monochromator M_Z
# m48 unassigned
# m49 unassigned
# m50 unassigned
# m51 unassigned
# m52 unassigned
# m53 unassigned
# m54 unassigned
# m55 unassigned
# m56 unassigned

# monochromator: m45 - m47
# append new line instead of edit in place
echo ""  >> ./optics.iocsh
echo "# monochromator"  >> ./optics.iocsh
echo iocshLoad\(\"\$\(OPTICS\)/iocsh/kohzu_mono.iocsh\", \"PREFIX=\$\(PREFIX\), M_THETA=m45,M_Y=m46,M_Z=m47, YOFF_LO=17.4999,YOFF_HI=17.5001, GEOM=1, LOG=kohzuCtl.log\"\)  >> ./optics.iocsh

# slits: m41 - m44
sed -i s/'Slit1V,mXp=m3,mXn=m4'/'Slit1V,mXp=m41,mXn=m42'/g   ./optics.iocsh
sed -i s/'Slit1H,mXp=m3,mXn=m4'/'Slit1H,mXp=m43,mXn=m44'/g   ./optics.iocsh

# optical table: m35 - m40
sed -i s/',T=table1,M0X=m1,M0Y=m2,M1Y=m3,M2X=m4,M2Y=m5,M2Z=m6'/',T=table1,M0X=m35,M0Y=m36,M1Y=m37,M2X=m38,M2Y=m39,M2Z=m40'/g   ./optics.iocsh

# Coarse/Fine stage: m33 - m34
sed -i s/',CM=m7,FM=m8'/',CM=m33,FM=m34'/g   ./optics.iocsh

# 4-circle diffractometer
# append new line instead of edit in place
echo ""  >> ./optics.iocsh
echo "# 4-circle diffractometer orientation"  >> ./optics.iocsh
echo iocshLoad\(\"\$\(OPTICS\)/iocsh/orient.iocsh\", \"PREFIX=\$\(PREFIX\), INSTANCE=_0, M_TTH=m29, M_TH=m30, M_CHI=m31, M_PHI=m32, PREC=6, SUB=substitutions/orient_xtals.substitutions\"\)  >> ./optics.iocsh

# PID support
echo ""  >> ./std.iocsh
echo "# feedback: fb_epid"  >> ./std.iocsh
echo dbLoadTemplate\(\"substitutions/fb_epid.substitutions\",\"PREFIX=\$\(PREFIX\)\"\)  >> ./std.iocsh
sed -i s/'P=xxx:epid1'/'P=\"$(PREFIX)epid1\"'/g   ./substitutions/fb_epid.substitutions
sed -i s/'IN=xxx:epid1:sim.VAL'/'IN=\"$(P):sim.VAL\"'/g   ./substitutions/fb_epid.substitutions
sed -i s/'OUT=xxx:epid1:sim.D'/'OUT=\"$(P):sim.D\"'/g   ./substitutions/fb_epid.substitutions
sed -i s/'PERMIT1=\"xxx:epid1:on.VAL\"'/'PERMIT1=\"$(P):on.VAL\"'/g   ./substitutions/fb_epid.substitutions

# general purpose PVs
export SUBFILE=./substitutions/general_purpose.substitutions
echo "# general_purpose.substitutions"  > ${SUBFILE}
echo "# PVs for general purposes"  >> ${SUBFILE}
echo   >> ${SUBFILE}
echo file \"${IOCXXX}/substitutions/general_purpose.db\"  >> ${SUBFILE}
echo {  >> ${SUBFILE}
echo pattern  >> ${SUBFILE}
echo {N}  >> ${SUBFILE}
for n in $(seq 1 20); do
    echo {${n}}  >> ${SUBFILE}
done
echo }  >> ${SUBFILE}
export SUBFILE=./general_purpose.iocsh
echo dbLoadTemplate\(\"substitutions/general_purpose.substitutions\", \"P=\$\(PREFIX\),R=gp:\"\) > ${SUBFILE}
export SUBFILE=
sed -i s:'< common.iocsh':'< common.iocsh\n< general_purpose.iocsh':g    ./st.cmd.Linux

# 4-circle diffractometer orientation: motors
sed -i s:'mTTH=SM1,mTH=SM2,mCHI=SM3,mPHI=SM4':'mTTH=m29,mTH=m30,mCHI=m31,mPHI=m32':g   ${XXX}/xxxApp/op/ui/xxx.ui
