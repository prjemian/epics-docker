#!/bin/bash
# gp_mca.sh -- add soft (simulated, no-hardware) MCA support (issue #45).
#
# Instantiates two soft MCA records using mca's simple_mca.db with the
# "Soft Channel" device support (devMCA_soft), which the gp IOC dbd already
# includes. No hardware or asyn port needed.
#
# Produces: $(PREFIX)mca1, $(PREFIX)mca2  (2048 channels each)
#
# Usage: gp_mca.sh IOCGP GP_RESOURCES MCA

set -euo pipefail
IOCGP="${1:?}"
GP_RESOURCES="${2:?}"
MCA="${3:?}"
CHANS="${CHANS:-2048}"

echo "# gp: 2 soft MCA instances (${CHANS} channels each)"

cat > "${IOCGP}/mca.iocsh" <<EOF
# gp soft MCA (simulated, no hardware) -- issue #45
dbLoadRecords("\$(MCA)/mcaApp/Db/simple_mca.db", "P=\$(PREFIX),M=mca1,DTYP=Soft Channel,CHANS=${CHANS},PREC=3,INP=")
dbLoadRecords("\$(MCA)/mcaApp/Db/simple_mca.db", "P=\$(PREFIX),M=mca2,DTYP=Soft Channel,CHANS=${CHANS},PREC=3,INP=")
EOF

# wire into the boot script
sed -i 's:< common.iocsh:< common.iocsh\n< mca.iocsh:' "${IOCGP}/st.cmd.Linux"
