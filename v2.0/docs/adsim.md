# IOCADSIM : ADSimDetector IOC with Custom Prefix

## Major Support Modules Loaded

- simDetector
- save_restoreStatus
- NDAttribute: 8 each, NDTimeSeries on Attr1:TS:
- NDBadPixel
- NDCircularBuff
- NDCodec: 2 each
- NDColorConvert: 2 each
- NDFFT
- NDFileHDF5
- NDFileJPEG
- NDFileMagick
- NDFileNetCDF
- NDFileNexus
- NDFileTIFF
- NDGather: 8 each
- NDOverlay: 8 each
- NDProcess
- NDPva
- NDROI: 4 each
- NDROIStat: 8 each
- NDScatter
- NDStats: 5 each with NDTimeSeries
- NDStdArrays
- NDTransform

## Status

<pre>
$ <b>iocmgr.sh status adsim ad</b>
docker container status
2fd097b358cc   prjemian/synapps:latest          "bash"                    About a minute ago   Up About a minute                    iocad

processes in docker container
UID                 PID                 PPID                C                   STIME               TTY                 TIME                CMD
root                1810392             1810369             0                   17:10               pts/0               00:00:00            bash
root                1810447             1810392             0                   17:10               ?                   00:00:00            SCREEN -dm -S ad: -h 5000 /opt/synApps/support/areaDetector-R3-11/ADSimDetector/iocs/simDetectorIOC/bin/linux-x86_64/simDetectorApp st.cmd
root                1810451             1810447             1                   17:10               ?                   00:00:01            /opt/synApps/support/areaDetector-R3-11/ADSimDetector/iocs/simDetectorIOC/bin/linux-x86_64/simDetectorApp st.cmd

IOC status
ad: is running (pid=24) in a screen session (pid=20)
</pre>
