#!/bin/bash
# adcam.sh -- generic areaDetector camera persona launcher.
#
# One launcher for all adcam personas (adsim, adcsim, adurl, adpva, aduvc).
# The entrypoint sets IOC=<camera>; this finds the customized boot dir
# ${SUPPORT}/ioc<camera> and its .adcam metadata (app binary, default prefix)
# written by adcam_build.sh, and starts the IOC under the runtime PREFIX
# (no recompile to change the prefix).
#
# Env vars:
#   IOC      camera persona name (adsim|adcsim|adurl|adpva|aduvc)
#   PREFIX   PV prefix (default: the camera's profile default)

set -euo pipefail

CAM="${IOC:?adcam.sh: IOC not set}"
BOOT="${SUPPORT}/ioc${CAM}"
meta="${BOOT}/.adcam"

if [ ! -d "${BOOT}" ] || [ ! -f "${meta}" ]; then
    echo "ERROR: adcam persona '${CAM}' not found (${BOOT}/.adcam missing)" >&2
    exit 2
fi

# shellcheck disable=SC1090
source "${meta}"   # CAM_NAME CAM_PREFIX CAM_APP CAM_SRC_IOC

PREFIX="${PREFIX:-${CAM_PREFIX}}"
export PREFIX

# Locate the app binary. It lives in the driver's example IOC bin dir
# (referenced by envPaths' TOP), derived from CAM_SRC_IOC.
ioc_top="${SUPPORT}/areaDetector-*/${CAM_SRC_IOC%%/iocBoot/*}"
bin="$(ls -d ${ioc_top}/bin/*/"${CAM_APP}" 2>/dev/null | head -n1 || true)"
if [ -z "${bin}" ]; then
    echo "ERROR: app binary '${CAM_APP}' for '${CAM}' not found (was the driver built?)" >&2
    exit 2
fi

if [ -n "${CAM_HOST_DEVICE:-}" ]; then
    echo "# note: ${CAM} expects host hardware: ${CAM_HOST_DEVICE}"
fi

echo "# adcam[${CAM}] starting from ${BOOT} with PREFIX='${PREFIX}'"
cd "${BOOT}"
exec "${bin}" st.cmd
