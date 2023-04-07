#!/bin/bash

echo "# running: $(readlink -f ${0})"
source "${HOME}/.bash_aliases"


echo "# ................................ customize std"
cd "${IOCGP}"
cp examples/std.iocsh    ./
sed -i s:'< common.iocsh':'< common.iocsh\n< std.iocsh':g    ./st.cmd.Linux
sed -i '/SCALER/s/^#//g' "${IOCGP}/std.iocsh"
cat >> "${IOCGP}/std.iocsh" << EOF

# extra Soft scalers for testing
iocshLoad("\$(SCALER)/iocsh/softScaler.iocsh", "P=\$(PREFIX), INSTANCE=scaler2")
iocshLoad("\$(SCALER)/iocsh/softScaler.iocsh", "P=\$(PREFIX), INSTANCE=scaler3")
EOF

echo "# ................................ pre-assigned scaler channels"
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

echo "# ................................ fb_epid"
echo ""  >> ./std.iocsh
echo "# feedback: fb_epid"  >> ./std.iocsh
echo dbLoadTemplate\(\"substitutions/fb_epid.substitutions\",\"PREFIX=\$\(PREFIX\)\"\)  >> ./std.iocsh
sed -i s/'P=gp:epid1'/'P=\"$(PREFIX)epid1\"'/g   ./substitutions/fb_epid.substitutions
sed -i s/'IN=gp:epid1:sim.VAL'/'IN=\"$(P):sim.VAL\"'/g   ./substitutions/fb_epid.substitutions
sed -i s/'OUT=gp:epid1:sim.D'/'OUT=\"$(P):sim.D\"'/g   ./substitutions/fb_epid.substitutions
sed -i s/'PERMIT1=\"gp:epid1:on.VAL\"'/'PERMIT1=\"$(P):on.VAL\"'/g   ./substitutions/fb_epid.substitutions
