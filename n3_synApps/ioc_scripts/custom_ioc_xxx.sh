#!/bin/bash

# build a custom IOC: xxx
echo "# build custom IOC: xxx"

cd ${SUPPORT}
tar cf - xxx-master | (cd ${SYNAPPS}/iocs && tar xf -)

cd ${SYNAPPS}/iocs
mv xxx-master ./xxx
