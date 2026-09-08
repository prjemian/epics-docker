#!/bin/bash
# gp_mca.sh -- add soft (simulated, no-hardware) MCA support (issue #45).
#
# Instantiates soft MCA records using mca's simple_mca.db with the
# "Soft Channel" device support (devMCA_soft), which the gp IOC dbd already
# includes. No hardware or asyn port needed.
#
# Produces: $(PREFIX)mca1..mca3 (2048 channels each). Three instances so the
# 3-element detector aggregation (BASENAME=mca) has records to reference.
#
# Usage: gp_mca.sh IOCGP GP_RESOURCES MCA

set -euo pipefail
IOCGP="${1:?}"
GP_RESOURCES="${2:?}"
MCA="${3:?}"
CHANS="${CHANS:-2048}"
NMCA="${NMCA:-3}"

echo "# gp: ${NMCA} soft MCA instances (${CHANS} channels each)"

{
    echo "# gp soft MCA (simulated, no hardware) -- issue #45"
    for n in $(seq 1 "${NMCA}"); do
        echo "dbLoadRecords(\"\$(MCA)/mcaApp/Db/simple_mca.db\", \"P=\$(PREFIX),M=mca${n},DTYP=Soft Channel,CHANS=${CHANS},PREC=3,INP=\")"
    done
} > "${IOCGP}/mca.iocsh"

# wire into the boot script
sed -i 's:< common.iocsh:< common.iocsh\n< mca.iocsh:' "${IOCGP}/st.cmd.Linux"
