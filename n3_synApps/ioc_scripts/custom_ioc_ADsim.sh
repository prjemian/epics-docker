#!/bin/bash

# build a custom IOC: ADsim
echo "# build custom IOC: ADsim"

cd ${AD}/ADSimDetector/iocs
tar cf - simDetectorIOC | (cd ${SYNAPPS}/iocs && tar xf -)

cd ${SYNAPPS}/iocs/simDetectorIOC

# sed -i s:'ADSIMDETECTOR = ':'ADSIMDETECTOR = $(AD)/ADSimDetector\n# ADSIMDETECTOR = ':g  configure/RELEASE
# echo "ADSIMDETECTOR = $(AREA_DETECTOR)/ADSimDetector" > configure/RELEASE.local
# FIXME: can't make rebuild yet
