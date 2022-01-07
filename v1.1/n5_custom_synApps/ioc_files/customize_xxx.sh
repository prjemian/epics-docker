#!/bin/bash

# customize_xxx.sh

cd "${IOCXXX}/"

# PV prefix is $PREFIX (default: xxx:)
# enable:
# * 56 motors
# * scaler
# * Kohzu monochromator

cp examples/motors.iocsh ./
cp examples/optics.iocsh    ./
cp examples/std.iocsh    ./

# change the TIMEZONE environment variable per issue #30
# https://github.com/prjemian/epics-docker/issues/30
# get the exact path to the EPICS database file
export dbFile=$(readlink -f /opt/synApps/support/iocStats*/db/iocAdminSoft.db)
sed -i s:'EPICS_TIMEZONE':'EPICS_TZ':g "${dbFile}"

# motors
sed -i s:'#iocshLoad("$(MOTOR)/modules/motorMotorSim/iocsh/motorSim.iocsh"':'iocshLoad("$(MOTOR)/iocsh/motorSim.iocsh"':g ./motors.iocsh
sed -i s:'LOW_LIM=':'HIGH_LIM=32000, LOW_LIM=':g ./motors.iocsh
sed -i s:'NUM_AXES=16':'NUM_AXES=56':g ./motors.iocsh

# https://github.com/prjemian/epics-docker/issues/24
patch "${MOTOR}/db/asyn_motor.db" "/opt/asyn_motor.db.diffs"

# re-write the substitutions file for 56 motors (easier than modifying it)
export SUBFILE=./substitutions/motorSim.substitutions
echo file \"\$\(MOTOR\)/db/asyn_motor.db\"  > "${SUBFILE}"
echo {  >> "${SUBFILE}"
echo pattern  >> "${SUBFILE}"
echo {N,  M, ADDR, DESC, EGU, DIR, VELO, VBAS, ACCL, BDST, BVEL, BACC, MRES, PREC, INIT}  >> "${SUBFILE}"
for n in $(seq 1 56); do
    echo {${n}, \"m${n}\", $((${n}-1)), \"motor ${n}\",  degrees,  Pos,  1, .1, .2, 0, 1, .2, 0.01, 5, \"\"}  >> "${SUBFILE}"
done
echo }  >> "${SUBFILE}"
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

cat > ./pre_assigned_motor_names.iocsh  << EOF
# motor assignments:
dbpf(\${PREFIX}m29.DESC, "TTH 4-circle")
dbpf(\${PREFIX}m30.DESC, "TH 4-circle")
dbpf(\${PREFIX}m31.DESC, "CHI 4-circle")
dbpf(\${PREFIX}m32.DESC, "PHI 4-circle")
dbpf(\${PREFIX}m33.DESC, "CM coarse/fine")
dbpf(\${PREFIX}m34.DESC, "FM coarse/fine")
dbpf(\${PREFIX}m35.DESC, "M0X table")
dbpf(\${PREFIX}m36.DESC, "M0Y table")
dbpf(\${PREFIX}m37.DESC, "M1Y table")
dbpf(\${PREFIX}m38.DESC, "M2X table")
dbpf(\${PREFIX}m39.DESC, "M2Y table")
dbpf(\${PREFIX}m40.DESC, "M2Z table")
dbpf(\${PREFIX}m41.DESC, "Slit1V:mXp")
dbpf(\${PREFIX}m42.DESC, "Slit1V:mXn")
dbpf(\${PREFIX}m43.DESC, "Slit1H:mXp")
dbpf(\${PREFIX}m44.DESC, "Slit1H:mXn")
dbpf(\${PREFIX}m45.DESC, "THETA monochromator")
dbpf(\${PREFIX}m46.DESC, "Y monochromator")
dbpf(\${PREFIX}m47.DESC, "Z monochromator")
EOF

cat >> st.cmd.Linux << EOF
#
# pre-assigned motors
< pre_assigned_motor_names.iocsh
EOF

# monochromator: m45 - m47
# append new line instead of edit in place
echo ""  >> ./optics.iocsh
echo "# monochromator"  >> ./optics.iocsh
echo iocshLoad\(\"\$\(OPTICS\)/iocsh/kohzu_mono.iocsh\", \"PREFIX=\$\(PREFIX\), M_THETA=m45,M_Y=m46,M_Z=m47, YOFF_LO=17.4999,YOFF_HI=17.5001, GEOM=1, LOG=kohzuCtl.log\"\)  >> ./optics.iocsh

# slits: m41 - m44
sed -i s/'Slit1V:,mXp=m3,mXn=m4'/'Slit1V,mXp=m41,mXn=m42'/g   ./optics.iocsh
sed -i s/'Slit1H:,mXp=m5,mXn=m6'/'Slit1H,mXp=m43,mXn=m44'/g   ./optics.iocsh

# optical table: m35 - m40
sed -i s/',T=table1,M0X=m1,M0Y=m2,M1Y=m3,M2X=m4,M2Y=m5,M2Z=m6'/',T=table1,M0X=m35,M0Y=m36,M1Y=m37,M2X=m38,M2Y=m39,M2Z=m40'/g   ./optics.iocsh

# Coarse/Fine stage: m33 - m34
# append new config: easier than removing the comment characters
cat >> ./optics.iocsh << EOF
#
# Coarse/Fine stage
dbLoadRecords("\$(OPTICS)/opticsApp/Db/CoarseFineMotor.db","P=\$(PREFIX)cf1:,PM=\$(PREFIX),CM=m33,FM=m34")
EOF
sed -i s:'CM=m7,FM=m8':'CM=m33,FM=m34':g   "${XXX}/xxxApp/op/ui/xxx.ui"

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
echo "# general_purpose.substitutions"  > "${SUBFILE}"
echo "# PVs for general purposes"  >> "${SUBFILE}"
echo   >> "${SUBFILE}"
echo file \"${IOCXXX}/substitutions/general_purpose.db\"  >> "${SUBFILE}"
echo {  >> "${SUBFILE}"
echo pattern  >> "${SUBFILE}"
echo {N}  >> "${SUBFILE}"
for n in $(seq 1 20); do
    echo {${n}}  >> "${SUBFILE}"
done
echo }  >> "${SUBFILE}"
export SUBFILE=./general_purpose.iocsh
echo dbLoadTemplate\(\"substitutions/general_purpose.substitutions\", \"P=\$\(PREFIX\),R=gp:\"\) > "${SUBFILE}"
export SUBFILE=
sed -i s:'< common.iocsh':'< common.iocsh\n< general_purpose.iocsh':g    ./st.cmd.Linux
# patch the caQtDM screen
cat > /opt/changes-gp-ui.diff << EOF
3865c3928
<               <string notr="true">-</string>
---
>               <string notr="true">- General PVs</string>
3882c3945
<               <string>1</string>
---
>               <string>bits;ints;floats;arrays;text;longtext;overview</string>
3885c3948
<               <string>1</string>
---
>               <string>gp_bit20.ui;gp_int20.ui;gp_float20.ui;gp_array20.ui;gp_text20.ui;gp_longtext20.ui;general_purpose.ui</string>
3888c3951
<               <string>1</string>
---
>               <string>P=xxx:,R=gp:;P=xxx:,R=gp:;P=xxx:,R=gp:;P=xxx:,R=gp:;P=xxx:,R=gp:;P=xxx:,R=gp:;P=xxx:,R=gp:</string>
EOF
patch "${XXX}/xxxApp/op/ui/xxx.ui" /opt/changes-gp-ui.diff

# 4-circle diffractometer orientation: motors
sed -i s:'mTTH=SM1,mTH=SM2,mCHI=SM3,mPHI=SM4':'mTTH=m29,mTH=m30,mCHI=m31,mPHI=m32':g   "${XXX}/xxxApp/op/ui/xxx.ui"
