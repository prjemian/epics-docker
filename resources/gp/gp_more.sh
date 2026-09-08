#!/bin/bash
# gp_more.sh -- additional synApps GUI features (issue #33) wired for
# simulation (no hardware). Also adds alarm clock and a 2nd ramp/tweak
# (explicitly requested).
#
# Items (all use sim motors / soft records):
#   - Optical tables Table2, Table3, Table4 (Table1 done in gp_optics.sh)
#   - 2-post mirror
#   - User Filters (filterMotor x2 + filterLock)
#   - I0 (Io) intensity calc
#   - count down timer
#   - alarm clock
#   - ramp/tweak 2 (rt2)
#   - scanParms (scan parameter presets)
#   - 3-element detector (aggregates soft mca1..mca3)
#   - trajectory scans (traj1)
#
# Usage: gp_more.sh IOCGP GP_RESOURCES OPTICS STD SSCAN MCA MOTOR

set -euo pipefail
IOCGP="${1:?}"; GP_RESOURCES="${2:?}"
OPTICS="${3:?}"; STD="${4:?}"; SSCAN="${5:?}"; MCA="${6:?}"; MOTOR="${7:?}"

echo "# gp: additional features (#33 + alarm clock + ramp/tweak 2)"

cat > "${IOCGP}/more.iocsh" <<'EOF'
# gp additional features (#33)

# Optical tables 2-4 (Table1 is in optics.iocsh). Use spare/general motors.
epicsEnvSet("TBLDIR", "$(OPTICS)/opticsApp/Db")
dbLoadRecords("$(TBLDIR)/table.db","P=$(PREFIX),Q=Table2,T=table2,M0X=m1,M0Y=m2,M1Y=m3,M2X=m4,M2Y=m5,M2Z=m6,GEOM=SRI")
dbLoadRecords("$(TBLDIR)/table.db","P=$(PREFIX),Q=Table3,T=table3,M0X=m7,M0Y=m8,M1Y=m9,M2X=m10,M2Y=m11,M2Z=m12,GEOM=SRI")
dbLoadRecords("$(TBLDIR)/table.db","P=$(PREFIX),Q=Table4,T=table4,M0X=m13,M0Y=m14,M1Y=m15,M2X=m16,M2Y=m17,M2Z=m18,GEOM=SRI")

# 2-post mirror
dbLoadRecords("$(OPTICS)/opticsApp/Db/2postMirror.db","P=$(PREFIX),Q=M1,mDn=m19,mUp=m20,LENGTH=0.3")

# User Filters (motorized attenuator foils) + interlock
dbLoadRecords("$(OPTICS)/opticsApp/Db/filterMotor.db","P=$(PREFIX),Q=fltr1:,MOTOR=m21,LOCK=fltr_1_2:")
dbLoadRecords("$(OPTICS)/opticsApp/Db/filterMotor.db","P=$(PREFIX),Q=fltr2:,MOTOR=m22,LOCK=fltr_1_2:")
dbLoadRecords("$(OPTICS)/opticsApp/Db/filterLock.db","P=$(PREFIX),Q=fltr2:,LOCK=fltr_1_2:,LOCK_PV=$(PREFIX)gp:bit1")

# I0 (Io) intensity calc
dbLoadRecords("$(OPTICS)/opticsApp/Db/Io.db","P=$(PREFIX)Io:")

# count down timer
dbLoadRecords("$(STD)/stdApp/Db/countDownTimer.vdb","P=$(PREFIX),N=1")

# alarm clock
dbLoadRecords("$(STD)/stdApp/Db/alarmClock.vdb","P=$(PREFIX),N=1")

# ramp/tweak 2
dbLoadRecords("$(STD)/stdApp/Db/ramp_tweak.db","P=$(PREFIX),Q=rt2")

# scanParms (scan parameter presets, tied to scan1)
dbLoadRecords("$(SSCAN)/sscanApp/Db/scanParms.db","P=$(PREFIX),Q=sp1:,SCANREC=$(PREFIX)scan1,POS=p1,RDBK=r1")

# 3-element detector: aggregates soft mca1..mca3
dbLoadRecords("$(MCA)/mcaApp/Db/3element.db","P=$(PREFIX),BASENAME=mca")

# trajectory scans (traj1)
dbLoadRecords("$(MOTOR)/motorApp/Db/trajectoryScan.db","P=$(PREFIX),R=traj1:,NAXES=2,NELM=300,NPULSE=300")
EOF

# Io and trajectory need sequencer programs started after iocInit.
cat > "${IOCGP}/more_afterinit.iocsh" <<'EOF'
doAfterIocInit("seq &Io, 'P=$(PREFIX)Io:,MONO=$(PREFIX)BraggEAO,VSC=$(PREFIX)scaler1'")
doAfterIocInit("seq &MAX_trajectoryScan, 'P=$(PREFIX),R=traj1:,M1=m1,M2=m2,M3=m3,M4=m4,M5=m5,M6=m6,M7=m7,M8=m8,PORT=none'")
EOF

# wire into boot script (more.iocsh loads records; after-init starts seqs)
sed -i 's:< common.iocsh:< common.iocsh\n< more.iocsh:' "${IOCGP}/st.cmd.Linux"
printf '\n< more_afterinit.iocsh\n' >> "${IOCGP}/st.cmd.Linux"
