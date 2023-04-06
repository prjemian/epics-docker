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
cd "${IOCGP}"
sed -i s:'< common.iocsh':'< common.iocsh\n< motors.iocsh':g    ./st.cmd.Linux

echo "# ................................ customize motors -- motors.iocsh" 2>&1 | tee -a "${LOG_FILE}"
cp "${IOCGP}/examples/motors.iocsh" "${IOCGP}/motors.iocsh"
sed -i /motor.substitutions/s/^/#/g "${IOCGP}/motors.iocsh"
sed -i /softMotor.substitutions/s/^#//g "${IOCGP}/motors.iocsh"
sed -i /motorSim.substitutions/s/^#//g "${IOCGP}/motors.iocsh"
sed -i s/NUM_AXES=16/NUM_AXES=56/g "${IOCGP}/motors.iocsh"
sed -i s/HIGH_LIM=32000/HIGH_LIM=2100000/g "${IOCGP}/motors.iocsh"
sed -i s/LOW_LIM=-32000/LOW_LIM=-2100000/g "${IOCGP}/motors.iocsh"
sed -i \
    s+'\$(MOTOR)/iocsh/motorSim.iocsh'+"${IOCGP}/motorSim.iocsh"+g \
    "${IOCGP}/motors.iocsh"

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
echo file "${IOCGP}/asyn_motor.db"  > "${SUBFILE}"
echo {  >> "${SUBFILE}"
echo pattern  >> "${SUBFILE}"
echo {N,  M, ADDR, DESC, EGU, DIR, VELO, VBAS, ACCL, BDST, BVEL, BACC, MRES, PREC, DLLM, DHLM, INIT}  >> "${SUBFILE}"
for n in $(seq 1 56); do
    echo {${n}, \"m${n}\", $((${n}-1)), \"motor ${n}\",  degrees,  Pos,  1, .1, .2, 0, 1, .2, 1e-4, 4, -1000, 1000, \"\"}  >> "${SUBFILE}"
done
echo }  >> "${SUBFILE}"
export SUBFILE=

echo "# ................................ customize motors -- patch asyn_motor.db" 2>&1 | tee -a "${LOG_FILE}"
# see: https://github.com/prjemian/epics-docker/pull/55#issuecomment-1499219783
cp "${MOTOR}/db/asyn_motor.db" "${IOCGP}/asyn_motor.db"
patch  "${IOCGP}/asyn_motor.db"  "${RESOURCES}/gp_asyn_motor.db.patch"

echo "# ................................ customize motors -- pre_assigned_motor_names.iocsh" 2>&1 | tee -a "${LOG_FILE}"
cat > ./pre_assigned_motor_names.iocsh  << EOF
# motor assignments:
# m1-m28 unassigned
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
# m41-m44 unassigned
dbpf(\${PREFIX}m45.DESC, "THETA monochromator")
dbpf(\${PREFIX}m46.DESC, "Y monochromator")
dbpf(\${PREFIX}m47.DESC, "Z monochromator")
# m48 unassigned
dbpf(\${PREFIX}m49.DESC, "Slit1V:mXp")
dbpf(\${PREFIX}m50.DESC, "Slit1V:mXn")
dbpf(\${PREFIX}m51.DESC, "Slit1H:mXp")
dbpf(\${PREFIX}m52.DESC, "Slit1H:mXn")
dbpf(\${PREFIX}m53.DESC, "Slit2V:mXp")
dbpf(\${PREFIX}m54.DESC, "Slit2V:mXn")
dbpf(\${PREFIX}m55.DESC, "Slit2H:mXp")
dbpf(\${PREFIX}m56.DESC, "Slit2H:mXn")
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

# Slit1 (2slit.db): m49-m52
sed -i s/'Slit1V,mXp=m3,mXn=m4'/'Slit1V,mXp=m49,mXn=m50'/g   ./optics.iocsh
sed -i s/'Slit1H,mXp=m5,mXn=m6'/'Slit1H,mXp=m51,mXn=m52'/g   ./optics.iocsh
cat >> ./optics.iocsh << EOF

# add Slit2 (2slit_soft.vdb): m53-m56
dbLoadRecords("\$(OPTICS)/opticsApp/Db/2slit_soft.vdb","P=\$(PREFIX),SLIT=Slit2V,mXp=m53,mXn=m54,PAIRED_WITH=Slit2H")
dbLoadRecords("\$(OPTICS)/opticsApp/Db/2slit_soft.vdb","P=\$(PREFIX),SLIT=Slit2H,mXp=m55,mXn=m56,PAIRED_WITH=Slit2V")
EOF

# optical table: m35 - m40
sed -i s/',T=table1,M0X=m1,M0Y=m2,M1Y=m3,M2X=m4,M2Y=m5,M2Z=m6'/',T=table1,M0X=m35,M0Y=m36,M1Y=m37,M2X=m38,M2Y=m39,M2Z=m40'/g   ./optics.iocsh

# Coarse/Fine stage: m33 - m34
# uncomment CoarseFineMotor
sed -i '/CoarseFineMotor/s/^#//g' "${IOCGP}/optics.iocsh"
sed -i s/'CM=m7,FM=m8'/'CM=m33,FM=m34'/g  "${IOCGP}/optics.iocsh"
sed -i s:'CM=m7,FM=m8':'CM=m33,FM=m34':g   "${XXX}/xxxApp/op/ui/xxx.ui"

# 4-circle diffractometer
cp "${OPTICS}/iocsh/orient.iocsh"  "${IOCGP}/orient.iocsh"
sed -i s+'\$(OPTICS)/iocsh/orient.iocsh'+"${IOCGP}/orient.iocsh"+g "${IOCGP}/optics.iocsh"
sed -i '/orient.iocsh/s/^#//g' "${IOCGP}/optics.iocsh"
# INSTANCE=_0 is used as $(O) in the GUI screens: $(P)orient$(O):H
sed -i s/'INSTANCE=1, M_TTH=m9'/'INSTANCE=_0, M_TTH=m29'/g  "${IOCGP}/optics.iocsh"
sed -i s/M_TH=m10/M_TH=m30/g  "${IOCGP}/optics.iocsh"
sed -i s/M_CHI=m11/M_CHI=m31/g  "${IOCGP}/optics.iocsh"
sed -i s/'M_PHI=m12'/'M_PHI=m32, PREC=6'/g  "${IOCGP}/optics.iocsh"
# https://7id.xray.aps.anl.gov/calculators/crystal_lattice_parameters.html
cat > "${IOCGP}/substitutions/7id-crystals.db" << EOF
file "\$(OPTICS)/db/orient_xtals.db"
{
    pattern
    {N,  xtal,            a,       b,       c,       alpha, beta,  gamma}
    {1,  Silicon,         5.43095, 5.43095, 5.43095, 90,    90,    90}
    {2,  "Beryllium hcp", 2.2858,  2.2858,  3.5843,  90,    90,   120}
    {3,  VO2,             5.743,   4.517,   5.375,   90,   122.6,  90}
    {4,  Germanium,       5.64613, 5.64613, 5.64613, 90,    90,    90}
    {5,  Diamond,         3.56683, 3.56683, 3.56683, 90,    90,    90}
    {6,  "Boron Nitride", 3.6150,  3.6150,  3.6150,  90,    90,    90}
    {7,  CdTe,            6.482,   6.482,   6.482,   90,    90,    90}
    {8,  SiC,             3.086,   3.086,  15.117,   90,    90,    90}
    {9,  undefined,       1, 1, 1, 90, 90, 90}
    {10, undefined,       1, 1, 1, 90, 90, 90}
}
EOF
sed -i s+'orient_xtals.substitutions'+'7id-crystals.db'+g  "${IOCGP}/optics.iocsh"


echo "# ................................ customize std" 2>&1 | tee -a "${LOG_FILE}"
cd "${IOCGP}"
cp examples/std.iocsh    ./
sed -i s:'< common.iocsh':'< common.iocsh\n< std.iocsh':g    ./st.cmd.Linux
sed -i '/SCALER/s/^#//g' "${IOCGP}/std.iocsh"
cat >> "${IOCGP}/std.iocsh" << EOF

# extra Soft scalers for testing
iocshLoad("\$(SCALER)/iocsh/softScaler.iocsh", "P=\$(PREFIX), INSTANCE=scaler2")
iocshLoad("\$(SCALER)/iocsh/softScaler.iocsh", "P=\$(PREFIX), INSTANCE=scaler3")
EOF

echo "# ................................ pre-assigned scaler channels" 2>&1 | tee -a "${LOG_FILE}"
cat > ./pre_assigned_scaler_channel_names.iocsh  << EOF
dbpf(\${PREFIX}scaler1.NM1, "timebase")
dbpf(\${PREFIX}scaler1.NM2, "I0")
dbpf(\${PREFIX}scaler1.NM3, "scint")
dbpf(\${PREFIX}scaler1.NM4, "diode")
dbpf(\${PREFIX}scaler1.NM5, "I000")
dbpf(\${PREFIX}scaler1.NM6, "I00")
EOF

cat >> st.cmd.Linux << EOF
#
# pre-assigned scaler channels
< pre_assigned_scaler_channel_names.iocsh
EOF

echo "# ................................ fb_epid" 2>&1 | tee -a "${LOG_FILE}"
echo ""  >> ./std.iocsh
echo "# feedback: fb_epid"  >> ./std.iocsh
echo dbLoadTemplate\(\"substitutions/fb_epid.substitutions\",\"PREFIX=\$\(PREFIX\)\"\)  >> ./std.iocsh
sed -i s/'P=gp:epid1'/'P=\"$(PREFIX)epid1\"'/g   ./substitutions/fb_epid.substitutions
sed -i s/'IN=gp:epid1:sim.VAL'/'IN=\"$(P):sim.VAL\"'/g   ./substitutions/fb_epid.substitutions
sed -i s/'OUT=gp:epid1:sim.D'/'OUT=\"$(P):sim.D\"'/g   ./substitutions/fb_epid.substitutions
sed -i s/'PERMIT1=\"gp:epid1:on.VAL\"'/'PERMIT1=\"$(P):on.VAL\"'/g   ./substitutions/fb_epid.substitutions


echo "# ................................ add general purpose PVs" 2>&1 | tee -a "${LOG_FILE}"
# database for general purpose PVs
cp "${RESOURCES}/general_purpose.db" "${IOCGP}/substitutions/general_purpose.db"
export SUBFILE="${IOCGP}/general_purpose.iocsh"  # build the iocsh loader
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

# patch the caQtDM (.ui) screen
# TODO:

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
bash "${RESOURCES}/gp_build_gp_sh.sh"

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
