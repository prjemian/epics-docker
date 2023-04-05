#!/bin/bash

# PV prefix is $PREFIX (default: gp:)
# enable:
# * 56 motors
# * scaler
# * Kohzu monochromator

echo "# --- --- --- --- --- script ---> $(readlink -f ${0})"

source "${HOME}/.bash_aliases"
LOG_FILE="${LOG_DIR}/create_gp_ioc.log"

export GP="${IOCS_DIR}/iocgp"
export IOCGP="${GP}/iocBoot/iocgp"

cat >> "${HOME}/.bash_aliases"  << EOF
#
# create_gp_ioc.sh
export GP="${GP}"
export IOCGP="${IOCGP}"
EOF

echo "# ................................ copy XXX to GP" 2>&1 | tee -a "${LOG_FILE}"
"${RESOURCES}/tarcopy.sh" "${XXX}" "${GP}"
cd "${GP}"
/bin/rm -rf ./.git* ./.ci* ./.travis.yml
make -C "${GP}" clean


echo "# ................................ customize default PREFIX" 2>&1 | tee -a "${LOG_FILE}"
cd "${GP}"
changePrefix xxx gp  # default PREFIX is gp:
cd "${IOCGP}"
ln -s "${IOCGP}" /home/iocgp
sed -i s/'IOC_NAME=gp'/'export PREFIX=${PREFIX:-gp:\}\nIOC_NAME=\$\{PREFIX\}'/g   ./softioc/gp.sh
sed -i s/'epicsEnvSet("PREFIX", "gp:")'/'epicsEnvSet("PREFIX", $(PREFIX=gp:))'/g   ./settings.iocsh

echo "# ................................ repair iocStats timezone setup" 2>&1 | tee -a "${LOG_FILE}"
# change the TIMEZONE environment variable per issue #30
# https://github.com/prjemian/epics-docker/issues/30
dbfile="${SUPPORT}/$(ls ${SUPPORT} | grep iocStats)/db/iocAdminSoft.db"
sed -i s:'EPICS_TIMEZONE':'EPICS_TZ':g "${dbfile}"


echo "# ................................ recompile" 2>&1 | tee -a "${LOG_FILE}"
make -C "${GP}"


echo "# ................................ customize motors" 2>&1 | tee -a "${LOG_FILE}"
MOTOR="${SUPPORT}/$(ls ${SUPPORT} | grep motor)"
cd "${IOCGP}"
cp examples/motors.iocsh ./
sed -i s:'< common.iocsh':'< common.iocsh\n< motors.iocsh':g    ./st.cmd.Linux

echo "# ................................ customize motors -- motors.iocsh" 2>&1 | tee -a "${LOG_FILE}"
cat > "${IOCGP}/motors.iocsh"  << EOF
iocshLoad("${IOCGP}/motorSim.iocsh", "INSTANCE=motorSim, HOME_POS=0, NUM_AXES=56, HIGH_LIM=2100000, LOW_LIM=-2100000, SUB=substitutions/motorSim.substitutions")

# Allstop, alldone
iocshLoad("\$(MOTOR)/iocsh/allstop.iocsh", "P=\$(PREFIX)")
EOF
echo "# ................................ customize motors -- motorSim.iocsh" 2>&1 | tee -a "${LOG_FILE}"
cat > "${IOCGP}/motorSim.iocsh"  << EOF
motorSimCreate(\$(CONTROLLER=0), 0, \$(LOW_LIM=-32000), \$(HIGH_LIM=32000), \$(HOME_POS=0), 1, \$(NUM_AXES=1))
drvAsynMotorConfigure("\$(INSTANCE)\$(CONTROLLER=0)", "\$(INSTANCE)", \$(CONTROLLER=0), \$(NUM_AXES=1))

# this line overrides MOTOR/iocsh/motorSim.iocsh
dbLoadTemplate("${IOCGP}/substitutions/motorSim.substitutions", "P=\$(PREFIX), DTYP='asynMotor', PORT=\$(INSTANCE)\$(CONTROLLER=0), DHLM=\$(HIGH_LIM=32000), DLLM=\$(LOW_LIM=-32000)")
EOF
echo "# ................................ customize motors -- substitutions/motor.substitutions" 2>&1 | tee -a "${LOG_FILE}"
# re-write the substitutions file for 56 motors (easier than modifying it)
sed -i s:'dbLoadTemplate("substitutions/motor.substitutions"':'#dbLoadTemplate("substitutions/motor.substitutions"':g ./motors.iocsh
export SUBFILE=./substitutions/motorSim.substitutions
echo file \"\$\(MOTOR\)/db/asyn_motor.db\"  > "${SUBFILE}"
echo {  >> "${SUBFILE}"
echo pattern  >> "${SUBFILE}"
echo {N,  M, ADDR, DESC, EGU, DIR, VELO, VBAS, ACCL, BDST, BVEL, BACC, MRES, PREC, DLLM, DHLM, INIT}  >> "${SUBFILE}"
for n in $(seq 1 56); do
    echo {${n}, \"m${n}\", $((${n}-1)), \"motor ${n}\",  degrees,  Pos,  1, .1, .2, 0, 1, .2, 1e-4, 4, -1000, 1000, \"\"}  >> "${SUBFILE}"
done
echo }  >> "${SUBFILE}"
export SUBFILE=

echo "# ................................ customize motors -- pre_assigned_motor_names.iocsh" 2>&1 | tee -a "${LOG_FILE}"
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


echo "# ................................ customize optics" 2>&1 | tee -a "${LOG_FILE}"
cd "${IOCGP}"
cp examples/optics.iocsh    ./
sed -i s:'< common.iocsh':'< common.iocsh\n< optics.iocsh':g    ./st.cmd.Linux

# monochromator: m45 - m47
# append new line instead of edit in place
echo ""  >> ./optics.iocsh
echo "# monochromator"  >> ./optics.iocsh
echo iocshLoad\(\"\$\(OPTICS\)/iocsh/kohzu_mono.iocsh\", \"PREFIX=\$\(PREFIX\), M_THETA=m45,M_Y=m46,M_Z=m47, YOFF_LO=17.4999,YOFF_HI=17.5001, GEOM=1, LOG=kohzuCtl.log\"\)  >> ./optics.iocsh

# slits (2slit.db): m41 - m44
sed -i s/'Slit1V,mXp=m3,mXn=m4'/'Slit1V,mXp=m41,mXn=m42'/g   ./optics.iocsh
sed -i s/'Slit1H,mXp=m5,mXn=m6'/'Slit1H,mXp=m43,mXn=m44'/g   ./optics.iocsh

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


echo "# ................................ customize std" 2>&1 | tee -a "${LOG_FILE}"
cd "${IOCGP}"
cp examples/std.iocsh    ./
sed -i s:'< common.iocsh':'< common.iocsh\n< std.iocsh':g    ./st.cmd.Linux
sed -i s:'#iocshLoad("$(STD)/iocsh/softScaler':'iocshLoad("$(STD)/iocsh/softScaler':g ./std.iocsh

# PID support
echo ""  >> ./std.iocsh
echo "# feedback: fb_epid"  >> ./std.iocsh
echo dbLoadTemplate\(\"substitutions/fb_epid.substitutions\",\"PREFIX=\$\(PREFIX\)\"\)  >> ./std.iocsh
sed -i s/'P=gp:epid1'/'P=\"$(PREFIX)epid1\"'/g   ./substitutions/fb_epid.substitutions
sed -i s/'IN=gp:epid1:sim.VAL'/'IN=\"$(P):sim.VAL\"'/g   ./substitutions/fb_epid.substitutions
sed -i s/'OUT=gp:epid1:sim.D'/'OUT=\"$(P):sim.D\"'/g   ./substitutions/fb_epid.substitutions
sed -i s/'PERMIT1=\"gp:epid1:on.VAL\"'/'PERMIT1=\"$(P):on.VAL\"'/g   ./substitutions/fb_epid.substitutions


echo "# ................................ add general purpose PVs" 2>&1 | tee -a "${LOG_FILE}"
# database for general purpose PVs
mv /tmp/general_purpose.db "${IOCGP}/substitutions"

# build the iocsh loader
export SUBFILE="${IOCGP}/general_purpose.iocsh"
echo dbLoadTemplate\(\"substitutions/general_purpose.substitutions\", \"P=\$\(PREFIX\),R=gp:\"\) > "${SUBFILE}"
export SUBFILE=
sed -i s:'< common.iocsh':'< common.iocsh\n< general_purpose.iocsh':g    ./st.cmd.Linux

# build the substitutions that uses this database
export SUBFILE="${IOCGP}/substitutions/general_purpose.substitutions"
echo "# general_purpose.substitutions"  > "${SUBFILE}"
echo "# PVs for general purposes"  >> "${SUBFILE}"
echo   >> "${SUBFILE}"
echo file \"${IOCGP}/substitutions/general_purpose.db\"  >> "${SUBFILE}"
echo {  >> "${SUBFILE}"
echo pattern  >> "${SUBFILE}"
echo {N}  >> "${SUBFILE}"
for n in $(seq 1 20); do
    echo {${n}}  >> "${SUBFILE}"
done
echo }  >> "${SUBFILE}"

echo "# ................................ remove ALIVE support" 2>&1 | tee -a "${LOG_FILE}"
# comment out any line with ALIVE
sed -i '/ALIVE/s/^/#/g' "${IOCGP}/common.iocsh"

echo "# ................................ GUI screens" 2>&1 | tee -a "${LOG_FILE}"
# update with motor assignments: 4-circle diffractometer orientation
sed \
    -i \
    s:'mTTH=SM1,mTH=SM2,mCHI=SM3,mPHI=SM4':'mTTH=m29,mTH=m30,mCHI=m31,mPHI=m32':g \
    "${GP}/gpApp/op/ui/gp.ui"


echo "# ................................ starter shortcut" 2>&1 | tee -a "${LOG_FILE}"
cat > "${HOME}/bin/gp.sh"  << EOF
#!/bin/bash

source "${HOME}/.bash_aliases"

cd "${IOCGP}/softioc"
bash ./gp.sh "\${1}"

if [ "\${1}" == "start" ]; then
    # allow time for the IOC to start (in screen, possibly)
    sleep 2
    bash ./gp.sh status
fi
EOF
chmod +x "${HOME}/bin/gp.sh"


echo "# ................................ install custom screen(s)" 2>&1 | tee -a "${LOG_FILE}"
cd "${IOCGP}/"
export SCREENS="${IOCGP}/screens"
${RESOURCES}/tarcopy.sh "${XXX}/xxxApp/op/" "${SCREENS}/"
mv /tmp/{gp_,}screens
${RESOURCES}/tarcopy.sh /tmp/screens "${SCREENS}/"
/bin/rm -rf /tmp/screens
${RESOURCES}/modify_adl_in_ui_files.sh  "${SCREENS}/ui"
${RESOURCES}/modify_adl_in_ui_files.sh  "${SCREENS}/ui/autoconvert"

# change "xxx:" to "$(P)" in all screen files
find "${SCREENS}/" -type f -exec sed -i 's/xxx:/$(P)/g' {} \;
find "${SCREENS}/" -type f -exec sed -i 's/ioc=xxx/ioc=gp/g' {} \;
find "${SCREENS}/" -type f -exec sed -i 's/xxxA/$(P)A/g' {} \;
find "${SCREENS}/" -type f -exec sed -i 's/>xxx/>gp/g' {} \;
