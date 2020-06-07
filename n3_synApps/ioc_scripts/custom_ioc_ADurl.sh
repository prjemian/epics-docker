#!/bin/bash

# build a custom IOC: ADurl
echo "# build custom IOC: ADurl"

cd ${AD}/ADURL/iocs
tar cf - urlIOC | (cd ${SYNAPPS}/iocs && tar xf -)

cd ${SYNAPPS}/iocs/urlIOC
