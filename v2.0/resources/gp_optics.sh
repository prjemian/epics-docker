#!/bin/bash

echo "# running: $(readlink -f ${0})"
source "${HOME}/.bash_aliases"

echo "# ................................ customize optics"
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

# update GUI with motor assignments: 4-circle diffractometer orientation
sed \
    -i \
    s:'mTTH=SM1,mTH=SM2,mCHI=SM3,mPHI=SM4':'mTTH=m29,mTH=m30,mCHI=m31,mPHI=m32':g \
    "${GP}/gpApp/op/ui/gp.ui"

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
