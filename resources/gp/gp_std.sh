#!/bin/bash
# gp_std.sh -- std support: soft scalers (scaler1..3) with named channels,
# and fb_epid feedback. Ships a complete std.iocsh overlay.
#
# Usage: gp_std.sh IOCGP GP_RESOURCES SCALER

set -euo pipefail
IOCGP="${1:?}"
GP_RESOURCES="${2:?}"
SCALER="${3:?}"

echo "# gp: std (soft scalers + fb_epid)"

# std overlay: keep the useful stock items + add three soft scalers + fb_epid
cat > "${IOCGP}/std.iocsh" <<'EOF'
# gp std support

# user-assignable ramp/tweak
dbLoadRecords("$(STD)/stdApp/Db/ramp_tweak.db","P=$(PREFIX),Q=rt1")
# 4-step measurement
dbLoadRecords("$(STD)/stdApp/Db/4step.db", "P=$(PREFIX),Q=4step:")
# pvHistory
dbLoadRecords("$(STD)/stdApp/Db/pvHistory.db","P=$(PREFIX),N=1,MAXSAMPLES=1440")
# software timer
dbLoadRecords("$(STD)/stdApp/Db/timer.db","P=$(PREFIX),N=1")
# misc PVs
dbLoadRecords("$(STD)/stdApp/Db/misc.db","P=$(PREFIX)")

# soft scalers
iocshLoad("$(SCALER)/iocsh/softScaler.iocsh", "P=$(PREFIX), INSTANCE=scaler1")
iocshLoad("$(SCALER)/iocsh/softScaler.iocsh", "P=$(PREFIX), INSTANCE=scaler2")
iocshLoad("$(SCALER)/iocsh/softScaler.iocsh", "P=$(PREFIX), INSTANCE=scaler3")

# feedback: fb_epid
dbLoadTemplate("substitutions/fb_epid.substitutions","PREFIX=$(PREFIX)")
EOF

# fb_epid substitutions (prefix-parameterized). fb_epid.db lives in the
# OPTICS module (not std).
cat > "${IOCGP}/substitutions/fb_epid.substitutions" <<'EOF'
file "$(OPTICS)/opticsApp/Db/fb_epid.db"
{
    pattern {P,            IN,               OUT,            PERMIT1}
    {"$(PREFIX)epid1", "$(P):sim.VAL", "$(P):sim.D", "$(P):on.VAL"}
}
EOF

# named scaler channels (applied after iocInit)
cat > "${IOCGP}/pre_assigned_scaler_channel_names.iocsh" <<'EOF'
dbpf(${PREFIX}scaler1.NM1, "timebase")
dbpf(${PREFIX}scaler1.NM2, "I0")
dbpf(${PREFIX}scaler1.NM3, "scint")
dbpf(${PREFIX}scaler1.NM4, "diode")
dbpf(${PREFIX}scaler1.NM5, "I000")
dbpf(${PREFIX}scaler1.NM6, "I00")
EOF

# wire into boot script
sed -i 's:< common.iocsh:< common.iocsh\n< std.iocsh:' "${IOCGP}/st.cmd.Linux"
printf '\n< pre_assigned_scaler_channel_names.iocsh\n' >> "${IOCGP}/st.cmd.Linux"
