#!/bin/bash

# add general purpose PVs

echo "# running: $(readlink -f ${0})"
source "${HOME}/.bash_aliases"

echo "# ................................ add general purpose PVs"

# database for general purpose PVs
cp "${RESOURCES}/general_purpose.db" "${IOCGP}/substitutions/general_purpose.db"
export SUBFILE="${IOCGP}/general_purpose.iocsh"  # build the iocsh loader
echo dbLoadTemplate\(\"substitutions/general_purpose.substitutions\", \"P=\$\(PREFIX\),R=gp:\"\) > "${SUBFILE}"
export SUBFILE=
sed -i s:'< common.iocsh':'< common.iocsh\n< general_purpose.iocsh':g  "${IOCGP}/st.cmd.Linux"

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
cat > "${RESOURCES}/changes-gp-ui.diff" << EOF
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
>               <string>P=\$(P),R=gp:;P=\$(P),R=gp:;P=\$(P),R=gp:;P=\$(P),R=gp:;P=\$(P),R=gp:;P=\$(P),R=gp:;P=\$(P),R=gp:</string>
EOF

screen_file="${GP}/gpApp/op/ui/gp.ui"
if [ -e "${screen_file}" ]; then
    patch "${screen_file}" "${RESOURCES}/changes-gp-ui.diff"
else
    echo "**** FILE NOT FOUND ****: ${screen_file}"
fi
