#!/bin/bash
# gp_optics.sh -- optics support wired to the gp sim motors.
#
# Ships a complete optics.iocsh overlay (not sed-on-upstream): slit pairs,
# optical table, kohzu monochromator, coarse/fine stage, 4-circle orientation
# with a crystals table. Motor assignments match the v2 GP layout.
#
# Usage: gp_optics.sh IOCGP GP_RESOURCES OPTICS

set -euo pipefail
IOCGP="${1:?}"
GP_RESOURCES="${2:?}"
OPTICS="${3:?}"

echo "# gp: optics"

# crystals table for the 4-circle orient support
cat > "${IOCGP}/substitutions/gp-crystals.db" <<'EOF'
file "$(OPTICS)/db/orient_xtals.db"
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

# complete optics overlay
cat > "${IOCGP}/optics.iocsh" <<'EOF'
# gp optics (wired to the gp sim motors)

### Slits
dbLoadRecords("$(OPTICS)/opticsApp/Db/2slit.db","P=$(PREFIX),SLIT=Slit1V,mXp=m49,mXn=m50,RELTOCENTER=0")
dbLoadRecords("$(OPTICS)/opticsApp/Db/2slit.db","P=$(PREFIX),SLIT=Slit1H,mXp=m51,mXn=m52,RELTOCENTER=0")
dbLoadRecords("$(OPTICS)/opticsApp/Db/2slit_soft.vdb","P=$(PREFIX),SLIT=Slit2V,mXp=m53,mXn=m54,PAIRED_WITH=Slit2H")
dbLoadRecords("$(OPTICS)/opticsApp/Db/2slit_soft.vdb","P=$(PREFIX),SLIT=Slit2H,mXp=m55,mXn=m56,PAIRED_WITH=Slit2V")

### Optical table
epicsEnvSet("DIR", "$(OPTICS)/opticsApp/Db")
dbLoadRecords("$(DIR)/table.db","P=$(PREFIX),Q=Table1,T=table1,M0X=m35,M0Y=m36,M1Y=m37,M2X=m38,M2Y=m39,M2Z=m40,GEOM=SRI")

### Kohzu monochromator (standard geometry)
iocshLoad("$(OPTICS)/iocsh/kohzu_mono.iocsh", "PREFIX=$(PREFIX), M_THETA=m45,M_Y=m46,M_Z=m47, YOFF_LO=17.4999,YOFF_HI=17.5001, GEOM=1, LOG=kohzuCtl.log")

### Coarse/Fine stage
dbLoadRecords("$(OPTICS)/opticsApp/Db/CoarseFineMotor.db","P=$(PREFIX)cf1:,PM=$(PREFIX),CM=m33,FM=m34")

### 4-circle orientation matrix, wired to m29-m32 (as in v2.0.1).
### INSTANCE=_0 is used as $(O) by the GUI screens: $(P)orient$(O):H
iocshLoad("$(OPTICS)/iocsh/orient.iocsh", "PREFIX=$(PREFIX), INSTANCE=_0, M_TTH=m29, M_TH=m30, M_CHI=m31, M_PHI=m32, PREC=6, SUB=substitutions/gp-crystals.db")
EOF

# wire into boot script
sed -i 's:< common.iocsh:< common.iocsh\n< optics.iocsh:' "${IOCGP}/st.cmd.Linux"
