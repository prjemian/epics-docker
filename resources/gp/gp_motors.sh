#!/bin/bash
# gp_motors.sh -- 56 soft/sim motors (m1..m56) with descriptive names.
#
# Uses motor's own iocsh/motorSim.iocsh (R7-3-1 ships a clean one, so we no
# longer hand-write it as v2 did). motor > R7.2.2 needs asyn_motor_model2.db
# (per motor's EXAMPLE_motorSim.substitutions note), which also removes the
# need for v2's asyn_motor.db.patch.
#
# Usage: gp_motors.sh IOCGP GP_RESOURCES MOTOR

set -euo pipefail
IOCGP="${1:?}"
GP_RESOURCES="${2:?}"
MOTOR="${3:?}"
NUM_AXES=56
HIGH_LIM=2100000
LOW_LIM=-2100000
# SREV = steps per revolution. The motor-record default is smaller than we
# want for the sim motors. Default 8000 per issue #23 (5-digit precision for
# crystallography/monochromator simulation). Tunable via MOTOR_SREV.
MOTOR_SREV="${MOTOR_SREV:-8000}"

echo "# gp: ${NUM_AXES} sim motors"

# 56-axis substitutions load motor's AS-SUPPLIED asyn_motor_model2.db
# unmodified. SREV is not a macro in that db, so rather than edit the db we
# set SREV at runtime via dbpf (see pre_assigned_motor_names.iocsh below).
subs="${IOCGP}/substitutions/motorSim.substitutions"
{
    echo 'file "$(MOTOR)/db/asyn_motor_model2.db"'
    echo '{'
    echo 'pattern'
    echo '{N,  M,      ADDR, DESC,        EGU,     DIR, VELO, VBAS, ACCL, BDST, BVEL, BACC, MRES,  PREC, DLLM,      DHLM,     INIT}'
    for n in $(seq 1 "${NUM_AXES}"); do
        printf '{%d, "m%d", %d, "motor %d", degrees, Pos, 1, .1, .2, 0, 1, .2, 1e-4, 4, %d, %d, ""}\n' \
            "${n}" "${n}" "$((n-1))" "${n}" "${LOW_LIM}" "${HIGH_LIM}"
    done
    echo '}'
} > "${subs}"

# Our motors.iocsh overlay: load the sim controller + 56-axis substitutions,
cat > "${IOCGP}/motors.iocsh" <<EOF
# gp motors: ${NUM_AXES} simulated soft motors
iocshLoad("\$(MOTOR)/iocsh/motorSim.iocsh", "INSTANCE=motorSim, CONTROLLER=0, HOME_POS=0, NUM_AXES=${NUM_AXES}, HIGH_LIM=${HIGH_LIM}, LOW_LIM=${LOW_LIM}, SUB=substitutions/motorSim.substitutions")
iocshLoad("\$(MOTOR)/iocsh/allstop.iocsh", "P=\$(PREFIX)")
EOF

# per-axis field overrides + descriptive names (applied after iocInit)
motor_names="${IOCGP}/pre_assigned_motor_names.iocsh"
{
    echo "# gp motors: set SREV (steps/rev) on all ${NUM_AXES} axes"
    for n in $(seq 1 "${NUM_AXES}"); do
        echo "dbpf(\${PREFIX}m${n}.SREV, ${MOTOR_SREV})"
    done
    echo "# descriptive axis names"
} > "${motor_names}"

# 4-circle diffractometer motors are m29-m32 (as in v2.0.1; gp_optics.sh
# wires the orient support to them).
cat >> "${IOCGP}/pre_assigned_motor_names.iocsh" <<'EOF'
dbpf(${PREFIX}m29.DESC, "TTH 4-circle")
dbpf(${PREFIX}m30.DESC, "TH 4-circle")
dbpf(${PREFIX}m31.DESC, "CHI 4-circle")
dbpf(${PREFIX}m32.DESC, "PHI 4-circle")
dbpf(${PREFIX}m33.DESC, "CM coarse/fine")
dbpf(${PREFIX}m34.DESC, "FM coarse/fine")
dbpf(${PREFIX}m35.DESC, "M0X table")
dbpf(${PREFIX}m36.DESC, "M0Y table")
dbpf(${PREFIX}m37.DESC, "M1Y table")
dbpf(${PREFIX}m38.DESC, "M2X table")
dbpf(${PREFIX}m39.DESC, "M2Y table")
dbpf(${PREFIX}m40.DESC, "M2Z table")
dbpf(${PREFIX}m45.DESC, "THETA monochromator")
dbpf(${PREFIX}m46.DESC, "Y monochromator")
dbpf(${PREFIX}m47.DESC, "Z monochromator")
dbpf(${PREFIX}m49.DESC, "Slit1V:mXp")
dbpf(${PREFIX}m50.DESC, "Slit1V:mXn")
dbpf(${PREFIX}m51.DESC, "Slit1H:mXp")
dbpf(${PREFIX}m52.DESC, "Slit1H:mXn")
dbpf(${PREFIX}m53.DESC, "Slit2V:mXp")
dbpf(${PREFIX}m54.DESC, "Slit2V:mXn")
dbpf(${PREFIX}m55.DESC, "Slit2H:mXp")
dbpf(${PREFIX}m56.DESC, "Slit2H:mXn")
EOF

# wire both into the boot script
sed -i 's:< common.iocsh:< common.iocsh\n< motors.iocsh:' "${IOCGP}/st.cmd.Linux"
printf '\n< pre_assigned_motor_names.iocsh\n' >> "${IOCGP}/st.cmd.Linux"
