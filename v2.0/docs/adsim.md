# IOCADSIM : ADSimDetector IOC with Custom Prefix

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

## Convert these lines into documentation

Lines printed on console when IOC started with `PREFIX=ioc:`.

```bash
dbLoadDatabase("/opt/synApps/support/areaDetector-R3-11/ADSimDetector/iocs/simDetectorIOC/dbd/simDetectorApp.dbd")
dbLoadRecords("/opt/synApps/support/areaDetector-R3-11/ADSimDetector/iocs/simDetectorIOC/../../db/simDetector.template","P=ioc:,R=cam1:,PORT=SIM1,ADDR=0,TIMEOUT=1")
dbLoadRecords("NDStdArrays.template", "P=ioc:,R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=SIM1,TYPE=Int8,FTVL=UCHAR,NELEMENTS=12000000")
dbLoadRecords("NDFileNetCDF.template","P=ioc:,R=netCDF1:,PORT=FileNetCDF1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=SIM1")
dbLoadRecords("NDFileTIFF.template",  "P=ioc:,R=TIFF1:,PORT=FileTIFF1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=SIM1")
dbLoadRecords("NDFileJPEG.template",  "P=ioc:,R=JPEG1:,PORT=FileJPEG1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=SIM1")
dbLoadRecords("NDFileNexus.template", "P=ioc:,R=Nexus1:,PORT=FileNexus1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=SIM1")
dbLoadRecords("NDFileHDF5.template",  "P=ioc:,R=HDF1:,PORT=FileHDF1,ADDR=0,TIMEOUT=1,XMLSIZE=2048,NDARRAY_PORT=SIM1")
dbLoadRecords("NDFileMagick.template","P=ioc:,R=Magick1:,PORT=FileMagick1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=SIM1")
dbLoadRecords("NDROI.template",       "P=ioc:,R=ROI1:,  PORT=ROI1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=SIM1")
dbLoadRecords("NDROI.template",       "P=ioc:,R=ROI2:,  PORT=ROI2,ADDR=0,TIMEOUT=1,NDARRAY_PORT=SIM1")
dbLoadRecords("NDROI.template",       "P=ioc:,R=ROI3:,  PORT=ROI3,ADDR=0,TIMEOUT=1,NDARRAY_PORT=SIM1")
dbLoadRecords("NDROI.template",       "P=ioc:,R=ROI4:,  PORT=ROI4,ADDR=0,TIMEOUT=1,NDARRAY_PORT=SIM1")
dbLoadRecords("NDROIStat.template",   "P=ioc:,R=ROIStat1:  ,PORT=ROISTAT1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=SIM1,NCHANS=2048")
dbLoadRecords("NDROIStatN.template",  "P=ioc:,R=ROIStat1:1:,PORT=ROISTAT1,ADDR=0,TIMEOUT=1,NCHANS=2048")
dbLoadRecords("NDROIStatN.template",  "P=ioc:,R=ROIStat1:2:,PORT=ROISTAT1,ADDR=1,TIMEOUT=1,NCHANS=2048")
dbLoadRecords("NDROIStatN.template",  "P=ioc:,R=ROIStat1:3:,PORT=ROISTAT1,ADDR=2,TIMEOUT=1,NCHANS=2048")
dbLoadRecords("NDROIStatN.template",  "P=ioc:,R=ROIStat1:4:,PORT=ROISTAT1,ADDR=3,TIMEOUT=1,NCHANS=2048")
dbLoadRecords("NDROIStatN.template",  "P=ioc:,R=ROIStat1:5:,PORT=ROISTAT1,ADDR=4,TIMEOUT=1,NCHANS=2048")
dbLoadRecords("NDROIStatN.template",  "P=ioc:,R=ROIStat1:6:,PORT=ROISTAT1,ADDR=5,TIMEOUT=1,NCHANS=2048")
dbLoadRecords("NDROIStatN.template",  "P=ioc:,R=ROIStat1:7:,PORT=ROISTAT1,ADDR=6,TIMEOUT=1,NCHANS=2048")
dbLoadRecords("NDROIStatN.template",  "P=ioc:,R=ROIStat1:8:,PORT=ROISTAT1,ADDR=7,TIMEOUT=1,NCHANS=2048")
dbLoadRecords("NDProcess.template",   "P=ioc:,R=Proc1:,  PORT=PROC1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=SIM1")
dbLoadRecords("NDFileTIFF.template",  "P=ioc:,R=Proc1:TIFF:,PORT=PROC1TIFF,ADDR=0,TIMEOUT=1,NDARRAY_PORT=SIM1")
dbLoadRecords("NDScatter.template",   "P=ioc:,R=Scatter1:,  PORT=SCATTER1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=SIM1")
dbLoadRecords("NDGather.template",   "P=ioc:,R=Gather1:, PORT=GATHER1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=SIM1")
dbLoadRecords("NDGatherN.template",   "P=ioc:,R=Gather1:, N=1, PORT=GATHER1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=SIM1")
dbLoadRecords("NDGatherN.template",   "P=ioc:,R=Gather1:, N=2, PORT=GATHER1,ADDR=1,TIMEOUT=1,NDARRAY_PORT=SIM1")
dbLoadRecords("NDGatherN.template",   "P=ioc:,R=Gather1:, N=3, PORT=GATHER1,ADDR=2,TIMEOUT=1,NDARRAY_PORT=SIM1")
dbLoadRecords("NDGatherN.template",   "P=ioc:,R=Gather1:, N=4, PORT=GATHER1,ADDR=3,TIMEOUT=1,NDARRAY_PORT=SIM1")
dbLoadRecords("NDGatherN.template",   "P=ioc:,R=Gather1:, N=5, PORT=GATHER1,ADDR=4,TIMEOUT=1,NDARRAY_PORT=SIM1")
dbLoadRecords("NDGatherN.template",   "P=ioc:,R=Gather1:, N=6, PORT=GATHER1,ADDR=5,TIMEOUT=1,NDARRAY_PORT=SIM1")
dbLoadRecords("NDGatherN.template",   "P=ioc:,R=Gather1:, N=7, PORT=GATHER1,ADDR=6,TIMEOUT=1,NDARRAY_PORT=SIM1")
dbLoadRecords("NDGatherN.template",   "P=ioc:,R=Gather1:, N=8, PORT=GATHER1,ADDR=7,TIMEOUT=1,NDARRAY_PORT=SIM1")
dbLoadRecords("NDStats.template",     "P=ioc:,R=Stats1:,  PORT=STATS1,ADDR=0,TIMEOUT=1,HIST_SIZE=256,XSIZE=1024,YSIZE=1024,NCHANS=2048,NDARRAY_PORT=SIM1")
dbLoadRecords("/opt/synApps/support/areaDetector-R3-11/ADCore/db/NDTimeSeries.template",  "P=ioc:,R=Stats1:TS:, PORT=STATS1_TS,ADDR=0,TIMEOUT=1,NDARRAY_PORT=STATS1,NDARRAY_ADDR=1,NCHANS=2048,ENABLED=1")
dbLoadRecords("NDStats.template",     "P=ioc:,R=Stats2:,  PORT=STATS2,ADDR=0,TIMEOUT=1,HIST_SIZE=256,XSIZE=1024,YSIZE=1024,NCHANS=2048,NDARRAY_PORT=SIM1")
dbLoadRecords("/opt/synApps/support/areaDetector-R3-11/ADCore/db/NDTimeSeries.template",  "P=ioc:,R=Stats2:TS:, PORT=STATS2_TS,ADDR=0,TIMEOUT=1,NDARRAY_PORT=STATS2,NDARRAY_ADDR=1,NCHANS=2048,ENABLED=1")
dbLoadRecords("NDStats.template",     "P=ioc:,R=Stats3:,  PORT=STATS3,ADDR=0,TIMEOUT=1,HIST_SIZE=256,XSIZE=1024,YSIZE=1024,NCHANS=2048,NDARRAY_PORT=SIM1")
dbLoadRecords("/opt/synApps/support/areaDetector-R3-11/ADCore/db/NDTimeSeries.template",  "P=ioc:,R=Stats3:TS:, PORT=STATS3_TS,ADDR=0,TIMEOUT=1,NDARRAY_PORT=STATS3,NDARRAY_ADDR=1,NCHANS=2048,ENABLED=1")
dbLoadRecords("NDStats.template",     "P=ioc:,R=Stats4:,  PORT=STATS4,ADDR=0,TIMEOUT=1,HIST_SIZE=256,XSIZE=1024,YSIZE=1024,NCHANS=2048,NDARRAY_PORT=SIM1")
dbLoadRecords("/opt/synApps/support/areaDetector-R3-11/ADCore/db/NDTimeSeries.template",  "P=ioc:,R=Stats4:TS:, PORT=STATS4_TS,ADDR=0,TIMEOUT=1,NDARRAY_PORT=STATS4,NDARRAY_ADDR=1,NCHANS=2048,ENABLED=1")
dbLoadRecords("NDStats.template",     "P=ioc:,R=Stats5:,  PORT=STATS5,ADDR=0,TIMEOUT=1,HIST_SIZE=256,XSIZE=1024,YSIZE=1024,NCHANS=2048,NDARRAY_PORT=SIM1")
dbLoadRecords("/opt/synApps/support/areaDetector-R3-11/ADCore/db/NDTimeSeries.template",  "P=ioc:,R=Stats5:TS:, PORT=STATS5_TS,ADDR=0,TIMEOUT=1,NDARRAY_PORT=STATS5,NDARRAY_ADDR=1,NCHANS=2048,ENABLED=1")
dbLoadRecords("NDTransform.template", "P=ioc:,R=Trans1:,  PORT=TRANS1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=SIM1")
dbLoadRecords("NDOverlay.template", "P=ioc:,R=Over1:, PORT=OVER1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=SIM1")
dbLoadRecords("NDOverlayN.template","P=ioc:,R=Over1:1:,NAME=ROI1,   SHAPE=1,O=Over1:,XPOS=ioc:ROI1:MinX_RBV,YPOS=ioc:ROI1:MinY_RBV,XSIZE=ioc:ROI1:SizeX_RBV,YSIZE=ioc:ROI1:SizeY_RBV,PORT=OVER1,ADDR=0,TIMEOUT=1")
dbLoadRecords("NDOverlayN.template","P=ioc:,R=Over1:2:,NAME=ROI2,   SHAPE=1,O=Over1:,XPOS=ioc:ROI2:MinX_RBV,YPOS=ioc:ROI2:MinY_RBV,XSIZE=ioc:ROI2:SizeX_RBV,YSIZE=ioc:ROI2:SizeY_RBV,PORT=OVER1,ADDR=1,TIMEOUT=1")
dbLoadRecords("NDOverlayN.template","P=ioc:,R=Over1:3:,NAME=ROI3,   SHAPE=1,O=Over1:,XPOS=ioc:ROI3:MinX_RBV,YPOS=ioc:ROI3:MinY_RBV,XSIZE=ioc:ROI3:SizeX_RBV,YSIZE=ioc:ROI3:SizeY_RBV,PORT=OVER1,ADDR=2,TIMEOUT=1")
dbLoadRecords("NDOverlayN.template","P=ioc:,R=Over1:4:,NAME=ROI4,   SHAPE=1,O=Over1:,XPOS=ioc:ROI4:MinX_RBV,YPOS=ioc:ROI4:MinY_RBV,XSIZE=ioc:ROI4:SizeX_RBV,YSIZE=ioc:ROI4:SizeY_RBV,PORT=OVER1,ADDR=3,TIMEOUT=1")
dbLoadRecords("NDOverlayN.template","P=ioc:,R=Over1:5:,NAME=Cursor1,SHAPE=1,O=Over1:,XPOS=junk,                  YPOS=junk,                  XSIZE=junk,                   YSIZE=junk,                   PORT=OVER1,ADDR=4,TIMEOUT=1")
dbLoadRecords("NDOverlayN.template","P=ioc:,R=Over1:6:,NAME=Cursor2,SHAPE=1,O=Over1:,XPOS=junk,                  YPOS=junk,                  XSIZE=junk,                   YSIZE=junk,                   PORT=OVER1,ADDR=5,TIMEOUT=1")
dbLoadRecords("NDOverlayN.template","P=ioc:,R=Over1:7:,NAME=Box1,   SHAPE=1,O=Over1:,XPOS=junk,                  YPOS=junk,                  XSIZE=junk,                   YSIZE=junk,                   PORT=OVER1,ADDR=6,TIMEOUT=1")
dbLoadRecords("NDOverlayN.template","P=ioc:,R=Over1:8:,NAME=Box2,   SHAPE=1,O=Over1:,XPOS=junk,                  YPOS=junk,                  XSIZE=junk,                   YSIZE=junk,                   PORT=OVER1,ADDR=7,TIMEOUT=1")
dbLoadRecords("NDColorConvert.template", "P=ioc:,R=CC1:,  PORT=CC1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=SIM1")
dbLoadRecords("NDColorConvert.template", "P=ioc:,R=CC2:,  PORT=CC2,ADDR=0,TIMEOUT=1,NDARRAY_PORT=SIM1")
dbLoadRecords("NDCircularBuff.template", "P=ioc:,R=CB1:,  PORT=CB1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=SIM1")
dbLoadRecords("NDAttribute.template",  "P=ioc:,R=Attr1:,    PORT=ATTR1,ADDR=0,TIMEOUT=1,NCHANS=2048,NDARRAY_PORT=SIM1")
dbLoadRecords("NDAttributeN.template", "P=ioc:,R=Attr1:1:,  PORT=ATTR1,ADDR=0,TIMEOUT=1,NCHANS=2048")
dbLoadRecords("NDAttributeN.template", "P=ioc:,R=Attr1:2:,  PORT=ATTR1,ADDR=1,TIMEOUT=1,NCHANS=2048")
dbLoadRecords("NDAttributeN.template", "P=ioc:,R=Attr1:3:,  PORT=ATTR1,ADDR=2,TIMEOUT=1,NCHANS=2048")
dbLoadRecords("NDAttributeN.template", "P=ioc:,R=Attr1:4:,  PORT=ATTR1,ADDR=3,TIMEOUT=1,NCHANS=2048")
dbLoadRecords("NDAttributeN.template", "P=ioc:,R=Attr1:5:,  PORT=ATTR1,ADDR=4,TIMEOUT=1,NCHANS=2048")
dbLoadRecords("NDAttributeN.template", "P=ioc:,R=Attr1:6:,  PORT=ATTR1,ADDR=5,TIMEOUT=1,NCHANS=2048")
dbLoadRecords("NDAttributeN.template", "P=ioc:,R=Attr1:7:,  PORT=ATTR1,ADDR=6,TIMEOUT=1,NCHANS=2048")
dbLoadRecords("NDAttributeN.template", "P=ioc:,R=Attr1:8:,  PORT=ATTR1,ADDR=7,TIMEOUT=1,NCHANS=2048")
dbLoadRecords("/opt/synApps/support/areaDetector-R3-11/ADCore/db/NDTimeSeries.template",  "P=ioc:,R=Attr1:TS:, PORT=ATTR1_TS,ADDR=0,TIMEOUT=1,NDARRAY_PORT=ATTR1,NDARRAY_ADDR=1,NCHANS=2048,ENABLED=1")
dbLoadRecords("NDFFT.template", "P=ioc:, R=FFT1:, PORT=FFT1, ADDR=0, TIMEOUT=1, NDARRAY_PORT=SIM1, NAME=FFT1, NCHANS=1024")
dbLoadRecords("NDCodec.template", "P=ioc:, R=Codec1:, PORT=CODEC1, ADDR=0, TIMEOUT=1, NDARRAY_PORT=SIM1")
dbLoadRecords("NDCodec.template", "P=ioc:, R=Codec2:, PORT=CODEC2, ADDR=0, TIMEOUT=1, NDARRAY_PORT=SIM1")
dbLoadRecords("NDBadPixel.template", "P=ioc:, R=BadPix1:, PORT=BADPIX1, ADDR=0, TIMEOUT=1, NDARRAY_PORT=SIM1")
dbLoadRecords("/opt/synApps/support/autosave-R5-10-2/asApp/Db/save_restoreStatus.db", "P=ioc:")
dbLoadRecords("NDPva.template",  "P=ioc:,R=Pva1:, PORT=PVA1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=SIM1")
dbLoadRecords("NDStdArrays.template", "P=ioc:,R=image2:,PORT=Image2,ADDR=0,TIMEOUT=1,NDARRAY_PORT=FFT1,TYPE=Float64,FTVL=DOUBLE,NELEMENTS=12000000")
```
