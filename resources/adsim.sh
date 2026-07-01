#!/bin/bash
# adsim.sh -- custom ADSimDetector IOC persona.
#
# Runs the customized simulated area-detector IOC (built from AD's
# simDetectorIOC example with prjemian's customizations: runtime prefix,
# one camera, PVA + Magick plugins, autosave). Honors the container's runtime
# PREFIX (default adsim:), no recompilation to change it.
#
# Env vars:
#   PREFIX   PV prefix (default adsim:), consumed by st_base.cmd's
#            epicsEnvSet("PREFIX", $(PREFIX=adsim:)) macro default.

set -euo pipefail

PREFIX="${PREFIX:-adsim:}"
export PREFIX

BOOT="${SUPPORT}/iocadsim"
if [ ! -d "${BOOT}" ]; then
    echo "ERROR: adsim IOC boot dir not found: ${BOOT}" >&2
    exit 2
fi

# The simDetectorApp binary lives in the stock AD example IOC (referenced by
# envPaths' TOP); locate it under areaDetector.
bin="$(ls -d "${SUPPORT}"/areaDetector-*/ADSimDetector/iocs/simDetectorIOC/bin/*/simDetectorApp 2>/dev/null | head -n1)"
if [ -z "${bin}" ]; then
    echo "ERROR: simDetectorApp binary not found (was ADSimDetector built?)" >&2
    exit 2
fi

echo "# adsim (custom ADSimDetector) starting from ${BOOT} with PREFIX='${PREFIX}'"
cd "${BOOT}"
exec "${bin}" st.cmd
