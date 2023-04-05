# IOCGP : General purpose XXX IOC with Custom Prefix

- [motors](./gp_motors.md)

## Status

<pre>
$ <b>iocmgr.sh status gp gp</b>
docker container status
b44a69fa53ae   prjemian/synapps:latest          "bash"                    2 minutes ago   Up 2 minutes                         iocgp

processes in docker container
UID                 PID                 PPID                C                   STIME               TTY                 TIME                CMD
root                1810030             1810003             0                   17:10               pts/0               00:00:00            bash
root                1810090             1810030             0                   17:10               ?                   00:00:00            SCREEN -dm -S gp: -h 5000 /opt/synApps/iocs/iocgp/iocBoot/iocgp/softioc/../../../bin/linux-x86_64/gp st.cmd.Linux
root                1810091             1810090             1                   17:10               ?                   00:00:02            /opt/synApps/iocs/iocgp/iocBoot/iocgp/softioc/../../../bin/linux-x86_64/gp st.cmd.Linux

IOC status
gp: is running (pid=22) in a screen session (pid=21)
</pre>

## Convert these lines into documentation

Lines printed on console when IOC started with `PREFIX=ioc:`.

```bash
iocshLoad("/opt/synApps/support/autosave-R5-10-2/iocsh/autosave_settings.iocsh", "PREFIX=ioc:, SAVE_PATH=/opt/synApps/iocs/iocgp/iocBoot/iocgp")
iocshLoad("/opt/synApps/support/autosave-R5-10-2/iocsh/save_restore.iocsh",      "PREFIX=ioc:, POSITIONS_FILE=auto_positions, SETTINGS_FILE=auto_settings")
iocshLoad("/opt/synApps/support/autosave-R5-10-2/iocsh/autosaveBuild.iocsh",     "PREFIX=ioc:, BUILD_PATH=autosave")
iocshLoad("/opt/synApps/support/caputRecorder-master/iocsh/caputRecorder.iocsh", "PREFIX=ioc:")
iocshLoad("/opt/synApps/support/sscan-R2-11-4/iocsh/sscan.iocsh", "PREFIX=ioc:, MAX_PTS=1000, REQ_FILE=saveData.req")
iocshLoad("/opt/synApps/support/autosave-R5-10-2/iocsh/configMenu.iocsh", "PREFIX=ioc:,CONFIG=scan1")
iocshLoad("/opt/synApps/support/calc-R3-7-4/iocsh/userCalc.iocsh", "PREFIX=ioc:, ARRAY_SIZE=8000")
iocshLoad("/opt/synApps/support/calc-R3-7-4/iocsh/userCalc_extra.iocsh", "PREFIX=ioc:, N=1, ARRAY_SIZE=8000")
iocshLoad("/opt/synApps/support/calc-R3-7-4/iocsh/sseq.iocsh", "PREFIX=ioc:, INSTANCE=ES:")
iocshLoad("/opt/synApps/support/scaler-4-0/iocsh/softScaler.iocsh", "P=ioc:, INSTANCE=scaler1")
iocshLoad("/opt/synApps/support/scaler-4-0/iocsh/softScaler.iocsh", "P=ioc:, INSTANCE=scaler2")
iocshLoad("/opt/synApps/support/scaler-4-0/iocsh/softScaler.iocsh", "P=ioc:, INSTANCE=scaler3")
iocshLoad("/opt/synApps/support/optics-R2-13-5/iocsh/orient.iocsh", "PREFIX=ioc:, INSTANCE=_0, M_TTH=m29, M_TH=m30, M_CHI=m31, M_PHI=m32, PREC=6, SUB=substitutions/orient_xtals.substitutions")
iocshLoad("/opt/synApps/support/optics-R2-13-5/iocsh/kohzu_mono.iocsh", "PREFIX=ioc:, M_THETA=m45,M_Y=m46,M_Z=m47, YOFF_LO=17.4999,YOFF_HI=17.5001, GEOM=1, LOG=kohzuCtl.log")
iocshLoad("/opt/synApps/iocs/iocgp/iocBoot/iocgp/motorSim.iocsh", "INSTANCE=motorSim, HOME_POS=0, NUM_AXES=56, HIGH_LIM=2100000, LOW_LIM=-2100000, SUB=substitutions/motorSim.substitutions")
iocshLoad("/opt/synApps/support/motor-R7-2-2/iocsh/allstop.iocsh", "P=ioc:")
```

```bash
dbLoadDatabase("../../dbd/iocgpLinux.dbd")
dbLoadRecords("/opt/synApps/support/autosave-R5-10-2/asApp/Db/save_restoreStatus.db", "P=ioc:, DEAD_SECONDS=5")
dbLoadRecords("/opt/synApps/support/caputRecorder-master/caputRecorderApp/Db/caputPoster.db","P=ioc:,N=300")
dbLoadRecords("/opt/synApps/support/caputRecorder-master/caputRecorderApp/Db/caputRecorder.db","P=ioc:,N=300")
dbLoadRecords("/opt/synApps/support/sscan-R2-11-4/sscanApp/Db/standardScans.db","P=ioc:,MAXPTS1=1000,MAXPTS2=1000,MAXPTS3=1000,MAXPTS4=1000,MAXPTSH=1000")
dbLoadRecords("/opt/synApps/support/sscan-R2-11-4/sscanApp/Db/saveData.db","P=ioc:")
dbLoadRecords("/opt/synApps/support/sscan-R2-11-4/sscanApp/Db/scanProgress.db","P=ioc:scanProgress:")
dbLoadRecords("/opt/synApps/support/autosave-R5-10-2/asApp/Db/configMenu.db","P=ioc:,CONFIG=scan1")
dbLoadRecords("/opt/synApps/support/calc-R3-7-4/db/userCalcGlobalEnable.db", "P=ioc:")
dbLoadRecords("/opt/synApps/support/calc-R3-7-4/db/userCalcs10.db",          "P=ioc:")
dbLoadRecords("/opt/synApps/support/calc-R3-7-4/db/userCalcOuts10.db",       "P=ioc:")
dbLoadRecords("/opt/synApps/support/calc-R3-7-4/db/userStringCalcs10.db",    "P=ioc:")
dbLoadRecords("/opt/synApps/support/calc-R3-7-4/db/userArrayCalcs10.db",     "P=ioc:, N=8000")
dbLoadRecords("/opt/synApps/support/calc-R3-7-4/db/userTransforms10.db",     "P=ioc:")
dbLoadRecords("/opt/synApps/support/calc-R3-7-4/db/userAve10.db",            "P=ioc:")
dbLoadRecords("/opt/synApps/support/calc-R3-7-4/db/userCalcs10more.db","P=ioc:,N10=10,N1=11,N2=12,N3=13,N4=14,N5=15,N6=16,N7=17,N8=18,N9=19")
dbLoadRecords("/opt/synApps/support/calc-R3-7-4/db/userCalcOuts10more.db","P=ioc:,N10=10,N1=11,N2=12,N3=13,N4=14,N5=15,N6=16,N7=17,N8=18,N9=19")
dbLoadRecords("/opt/synApps/support/calc-R3-7-4/db/userStringCalcs10more.db","P=ioc:,N10=10,N1=11,N2=12,N3=13,N4=14,N5=15,N6=16,N7=17,N8=18,N9=19")
dbLoadRecords("/opt/synApps/support/calc-R3-7-4/db/userArrayCalcs10more.db","P=ioc:,N10=10,N1=11,N2=12,N3=13,N4=14,N5=15,N6=16,N7=17,N8=18,N9=19,N=8000")
dbLoadRecords("/opt/synApps/support/calc-R3-7-4/db/userTransforms10more.db","P=ioc:,N10=10,N1=11,N2=12,N3=13,N4=14,N5=15,N6=16,N7=17,N8=18,N9=19")
dbLoadRecords("/opt/synApps/support/calc-R3-7-4/db/userAve10more.db","P=ioc:,N10=10,N1=11,N2=12,N3=13,N4=14,N5=15,N6=16,N7=17,N8=18,N9=19")
dbLoadRecords("/opt/synApps/support/lua-R3-0-2/luaApp/Db/luascripts10.db", "P=ioc:, R=set1:")
dbLoadRecords("/opt/synApps/support/lua-R3-0-2/luaApp/Db/luascripts10.db", "P=ioc:, R=set2:")
dbLoadRecords("/opt/synApps/support/calc-R3-7-4/db/userStringSeqs10.db","P=ioc:")
dbLoadRecords("/opt/synApps/support/calc-R3-7-4/db/editSseq.db", "P=ioc:,Q=ES:")
dbLoadRecords("/opt/synApps/support/calc-R3-7-4/calcApp/Db/interp.db", "P=ioc:,N=2000")
dbLoadRecords("/opt/synApps/support/calc-R3-7-4/calcApp/Db/interpNew.db", "P=ioc:,Q=1,N=2000")
dbLoadRecords("/opt/synApps/support/busy-R1-7-3/busyApp/Db/busyRecord.db", "P=ioc:,R=mybusy1")
dbLoadRecords("/opt/synApps/support/busy-R1-7-3/busyApp/Db/busyRecord.db", "P=ioc:,R=mybusy2")
dbLoadTemplate("substitutions/general_purpose.substitutions", "P=ioc:,R=ioc:")
dbLoadRecords("/opt/synApps/support/std-R3-6-3/stdApp/Db/ramp_tweak.db","P=ioc:,Q=rt1")
dbLoadRecords("/opt/synApps/support/asyn-R4-42/db/asynRecord.db","P=ioc:,R=asyn_scaler1,PORT=scaler1Port,ADDR=0,OMAX=0,IMAX=0")
dbLoadRecords("/opt/synApps/support/scaler-4-0/db/scaler.db","P=ioc:,S=scaler1,OUT=@asyn(scaler1Port 0 0),DTYP=Asyn Scaler,FREQ=10000000")
dbLoadRecords("/opt/synApps/support/scaler-4-0/db/scalerSoftCtrl.db","P=ioc:,Q=scaler1:,SCALER=ioc:scaler1")
dbLoadRecords("/opt/synApps/support/std-R3-6-3/stdApp/Db/4step.db", "P=ioc:,Q=4step:")
dbLoadRecords("/opt/synApps/support/std-R3-6-3/stdApp/Db/pvHistory.db","P=ioc:,N=1,MAXSAMPLES=1440")
dbLoadRecords("/opt/synApps/support/std-R3-6-3/stdApp/Db/timer.db","P=ioc:,N=1")
dbLoadRecords("/opt/synApps/support/std-R3-6-3/stdApp/Db/misc.db","P=ioc:")
dbLoadRecords("/opt/synApps/support/asyn-R4-42/db/asynRecord.db","P=ioc:,R=asyn_scaler2,PORT=scaler2Port,ADDR=0,OMAX=0,IMAX=0")
dbLoadRecords("/opt/synApps/support/scaler-4-0/db/scaler.db","P=ioc:,S=scaler2,OUT=@asyn(scaler2Port 0 0),DTYP=Asyn Scaler,FREQ=10000000")
dbLoadRecords("/opt/synApps/support/scaler-4-0/db/scalerSoftCtrl.db","P=ioc:,Q=scaler2:,SCALER=ioc:scaler2")
dbLoadRecords("/opt/synApps/support/asyn-R4-42/db/asynRecord.db","P=ioc:,R=asyn_scaler3,PORT=scaler3Port,ADDR=0,OMAX=0,IMAX=0")
dbLoadRecords("/opt/synApps/support/scaler-4-0/db/scaler.db","P=ioc:,S=scaler3,OUT=@asyn(scaler3Port 0 0),DTYP=Asyn Scaler,FREQ=10000000")
dbLoadRecords("/opt/synApps/support/scaler-4-0/db/scalerSoftCtrl.db","P=ioc:,Q=scaler3:,SCALER=ioc:scaler3")
dbLoadTemplate("substitutions/fb_epid.substitutions","PREFIX=ioc:")
dbLoadRecords("/opt/synApps/support/optics-R2-13-5/opticsApp/Db/2slit.db","P=ioc:,SLIT=Slit1V,mXp=m49,mXn=m50,RELTOCENTER=0")
dbLoadRecords("/opt/synApps/support/optics-R2-13-5/opticsApp/Db/2slit.db","P=ioc:,SLIT=Slit1H,mXp=m51,mXn=m52,RELTOCENTER=0")
dbLoadRecords("/opt/synApps/support/optics-R2-13-5/opticsApp/Db/table.db","P=ioc:,Q=Table1,T=table1,M0X=m35,M0Y=m36,M1Y=m37,M2X=m38,M2Y=m39,M2Z=m40,GEOM=SRI")
dbLoadRecords("/opt/synApps/support/optics-R2-13-5/opticsApp/Db/orient.db", "P=ioc:,O=_0,PREC=6")
dbLoadTemplate("substitutions/orient_xtals.substitutions", "P=ioc:, O=_0, PREC=6")
dbLoadRecords("/opt/synApps/support/optics-R2-13-5/opticsApp/Db/CoarseFineMotor.db","P=ioc:cf1:,PM=ioc:,CM=m33,FM=m34")
dbLoadRecords("/opt/synApps/support/optics-R2-13-5/opticsApp/Db/kohzuSeq.db","P=ioc:,M_THETA=m45,M_Y=m46,M_Z=m47,yOffLo=17.4999,yOffHi=17.5001")
dbLoadRecords("/opt/synApps/support/optics-R2-13-5/opticsApp/Db/2slit_soft.vdb","P=ioc:,SLIT=Slit2V,mXp=m53,mXn=m54,PAIRED_WITH=Slit2H")
dbLoadRecords("/opt/synApps/support/optics-R2-13-5/opticsApp/Db/2slit_soft.vdb","P=ioc:,SLIT=Slit2H,mXp=m55,mXn=m56,PAIRED_WITH=Slit2V")
dbLoadTemplate("/opt/synApps/iocs/iocgp/iocBoot/iocgp/substitutions/motorSim.substitutions", "P=ioc:, DTYP='asynMotor', PORT=motorSim0, DHLM=2100000, DLLM=-2100000")
dbLoadRecords("/opt/synApps/support/motor-R7-2-2/db/motorUtil.db", "P=ioc:")
dbLoadRecords("/opt/synApps/support/iocStats-3-1-16/db/iocAdminSoft.db","IOC=ioc:")
dbLoadRecords("/opt/synApps/iocs/iocgp/gpApp/Db/iocAdminSoft_aliases.db","P=ioc:")
```
