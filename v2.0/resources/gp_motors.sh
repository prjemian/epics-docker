#!/bin/bash

echo "# running: $(readlink -f ${0})"
source "${HOME}/.bash_aliases"

echo "# ................................ customize motors"
cd "${IOCGP}"
sed -i s:'< common.iocsh':'< common.iocsh\n< motors.iocsh':g    ./st.cmd.Linux

echo "# ................................ customize motors -- motors.iocsh"
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

echo "# ................................ customize motors -- motorSim.iocsh"
cat > "${IOCGP}/motorSim.iocsh"  << EOF
motorSimCreate(\$(CONTROLLER=0), 0, \$(LOW_LIM=-32000), \$(HIGH_LIM=32000), \$(HOME_POS=0), 1, \$(NUM_AXES=1))
drvAsynMotorConfigure("\$(INSTANCE)\$(CONTROLLER=0)", "\$(INSTANCE)", \$(CONTROLLER=0), \$(NUM_AXES=1))

# this line overrides MOTOR/iocsh/motorSim.iocsh
dbLoadTemplate("${IOCGP}/substitutions/motorSim.substitutions", "P=\$(PREFIX), DTYP='asynMotor', PORT=\$(INSTANCE)\$(CONTROLLER=0), DHLM=\$(HIGH_LIM=32000), DLLM=\$(LOW_LIM=-32000)")
EOF
echo "# ................................ customize motors -- substitutions/motor.substitutions"
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

echo "# ................................ customize motors -- patch asyn_motor.db"
# see: https://github.com/prjemian/epics-docker/pull/55#issuecomment-1499219783
cp "${MOTOR}/db/asyn_motor.db" "${IOCGP}/asyn_motor.db"
patch  "${IOCGP}/asyn_motor.db"  "${RESOURCES}/gp_asyn_motor.db.patch"

echo "# ................................ customize motors -- pre_assigned_motor_names.iocsh"
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
