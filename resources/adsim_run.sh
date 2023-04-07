#!/bin/bash
# Run the custom adsim IOC.
# Ensure that multiple, simultaneous IOCs are not started by this user ID.

MY_UID=$(id -u)
IOC_PID="$(/usr/bin/pgrep adsim\$ -u ${MY_UID})"

if [ "" != "${IOC_PID}" ] ; then
  echo "adsim IOC is already running, won't start a new one, PID=${IOC_PID}"
  exit 1
fi

# start the IOC
cd "${IOCADSIM}"
"${ADSIMDETECTOR}/bin/${EPICS_HOST_ARCH}/simDetectorApp" st.cmd
