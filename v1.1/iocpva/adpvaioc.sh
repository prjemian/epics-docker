#!/bin/bash

# starts the IOC in a screen session
# this script goes into the container

export IOCPVA=${AREA_DETECTOR}/pvaDriver/iocs/pvaDriverIOC/iocBoot/iocPvaDriver
ln -s ${IOCPVA} /opt/iocpva

cd ${IOCPVA}

sed -i s+'"13PVA1:"'+'"\${PREFIX:-13PVA1:}'+g   ./st_base.cmd
sed -i s+'P=13PVA1:'+'P=${PREFIX}'+g ./st_base.cmd
sed -i s+'dbpf 13PVA1:cam'+'dbpf ${PREFIX}:cam'+g ./st_base.cmd
sed -i s+'13SIM1'+'${PREFIX}'+g ./st_base.cmd
if [ -f "autosave/auto_settings.sav" ]; then
    sed -i s+'13PVA1:'+$PREFIX+g autosave/auto_settings.sav
fi

cd ${IOCPVA}
ln -s ./envPaths ./envPaths.linux
cp /opt/iocxxx/softioc/in-screen.sh ./
cp /opt/iocxxx/softioc/xxx.sh ./adpva.sh
sed -i s+'xxx'+'adpva'+g   ./adpva.sh
sed -i s+'IOC_BINARY=adpva'+'IOC_BINARY=pvaDriverApp'+g   ./adpva.sh
sed -i s+'#!IOC_STARTUP_DIR='+'IOC_STARTUP_DIR=EDIT_STUB\n# '+g   ./adpva.sh
sed -i s+EDIT_STUB+$(pwd)+g   ./adpva.sh
sed -i s+st.cmd.Linux+st.cmd.linux+g   ./adpva.sh

# start the IOC in a screen session
./adpva.sh start

# -------------------------------------------
# screens for MEDM and caQtDM
cp $AREA_DETECTOR/pvaDriver/pvaDriverApp/op/adl/*.adl /opt/screens/adl/
cp $AREA_DETECTOR/pvaDriver/pvaDriverApp/op/ui/autoconvert/*.ui /opt/screens/ui/

# -------------------------------------------
# edit files in docker container IOC for use with GUI software
export PRE=${PREFIX::-1}
export caqtdm_starter=./start_caQtDM_${PRE}
echo "changing 13PVA1: to ${PREFIX} in ${caqtdm_starter}"
cp /opt/iocSimDetector/start_caQtDM_adsim ${caqtdm_starter}
sed -i s+13SIM1+${PRE}+g ${caqtdm_starter}
sed -i s+'sim_cam_image'+'pva_cam_image'+g ${caqtdm_starter}
