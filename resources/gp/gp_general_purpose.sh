#!/bin/bash
# gp_general_purpose.sh -- add the general-purpose scratch PVs.
# Produces $(PREFIX)gp:{float,bit,int,text,longtext,array}1..20
# (apstools CI relies on e.g. gp:gp:float1).
#
# Usage: gp_general_purpose.sh IOCGP GP_RESOURCES

set -euo pipefail
IOCGP="${1:?}"
GP_RESOURCES="${2:?}"
N=20

echo "# gp: general-purpose PVs (1..${N})"
cp "${GP_RESOURCES}/general_purpose.db" "${IOCGP}/substitutions/general_purpose.db"

# substitutions file: N instances
subs="${IOCGP}/substitutions/general_purpose.substitutions"
{
    echo "# general_purpose.substitutions -- PVs for general purposes"
    echo
    echo "file \"substitutions/general_purpose.db\""
    echo "{"
    echo "    pattern { N }"
    for n in $(seq 1 "${N}"); do echo "    { ${n} }"; done
    echo "}"
} > "${subs}"

# iocsh loader (R=gp: keeps the historic gp:gp:* names)
cat > "${IOCGP}/general_purpose.iocsh" <<'EOF'
dbLoadTemplate("substitutions/general_purpose.substitutions", "P=$(PREFIX),R=gp:")
EOF

# include it from the boot script
sed -i 's:< common.iocsh:< common.iocsh\n< general_purpose.iocsh:' "${IOCGP}/st.cmd.Linux"
