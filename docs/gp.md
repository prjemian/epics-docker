# GP : General purpose XXX IOC with Custom Prefix

## FIXME

```bash
# FIXME:  missing parts?
dbLoadRecords("/opt/synApps/support/optics-R2-13-5/opticsApp/Db/orient.db", "P=PREFIX:,O=_0,PREC=6")
dbLoadTemplate("substitutions/orient_xtals.substitutions", "P=PREFIX:, O=_0, PREC=6")
```

## Major Support Modules Loaded

- 2D slits Slit1 (2slit.db)
- 2D slits Slit2 (2slit_soft.vdb)
- 4-circle diffractometer orientation with crystal lattice parameter database
- 4-step database
- autosave & restore
- busy record: 2 each
- caputRecorder
- coarse/fine motor
- configMenu
- fb_epid: feedback EPID
- interpolation
- iocAdminSoft database
- Kohzu monochromator
- lua script: 20 channels
- motor simulation: [m1 - m56](gp_motors.md) with allstop
- PV history database
- softScaler: [scaler1 - scaler3](gp_scalers.md)
- sscan: scan1 - scan4, scanH, saveData, and scanProgress
- sseq
- table database
- timer database
- userCalcs, userCalcOuts, userStringCalcs, userArrayCalcs, userAve, userStringSeqs: 20 channels each

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
