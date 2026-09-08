#!/bin/bash
# adcam_build.sh -- build a custom areaDetector camera IOC from a driver
# PROFILE. Shared framework: the ~90% of an AD IOC that is common (runtime
# prefix, plugins, autosave, screens) lives here; the per-driver differences
# (which example IOC to copy, config call, template, default prefix, extra
# plugin tweaks) come from a small profile file.
#
# This lets ADSimDetector, ADCSimDetector, ADURL, pvaDriver, ... share one
# recipe -- each is "framework + profile".
#
# A profile (resources/adcam/profiles/<name>.env) defines:
#   CAM_NAME        persona/dir name (e.g. adsim)         [required]
#   CAM_PREFIX      default runtime PV prefix (e.g. adsim:)[required]
#   CAM_SRC_IOC     path (under AREA_DETECTOR) of the example IOC boot dir to
#                   copy, OR empty if the driver ships none (future drivers)
#   CAM_STOCK_PREFIX  the literal prefix in the stock st_base.cmd (e.g. 13SIM1:)
#   CAM_KEEP_CAM2   "yes" to keep the 2nd sim camera (default: no)
#   CAM_HOST_DEVICE optional note: host hardware this driver needs at run time
#                   (e.g. a USB camera for ADUVC, requiring --device passthrough).
#                   Informational for docs; hardware-free drivers leave it empty.
#
# Usage: adcam_build.sh <profile.env>

set -euo pipefail

PROFILE="${1:?usage: adcam_build.sh <profile.env>}"
# shellcheck disable=SC1090
source "${PROFILE}"

: "${SUPPORT:?}"
: "${CAM_NAME:?}" "${CAM_PREFIX:?}"
ADCAM_RESOURCES="$(cd "$(dirname "$0")" && pwd)"

AREA_DETECTOR="$(ls -d "${SUPPORT}"/areaDetector-* | head -n1)"
ADCORE="${AREA_DETECTOR}/ADCore"

DEST="${SUPPORT}/ioc${CAM_NAME}"

if [ -z "${CAM_SRC_IOC:-}" ]; then
    echo "ERROR: profile ${CAM_NAME} has no CAM_SRC_IOC (driver ships no example IOC)." >&2
    echo "       Assembling an IOC from scratch is not yet implemented." >&2
    exit 3
fi
SRC="${AREA_DETECTOR}/${CAM_SRC_IOC}"
if [ ! -d "${SRC}" ]; then
    echo "# adcam_build[${CAM_NAME}]: SKIP (driver not fetched/built: ${SRC} absent)" >&2
    exit 0
fi

echo "# adcam_build[${CAM_NAME}]: copy ${SRC} -> ${DEST}"
mkdir -p "${DEST}"
cp -a "${SRC}/." "${DEST}/"
rm -f "${DEST}"/Makefile*

boot="${DEST}"   # the copied dir IS the iocBoot dir

# Detect the startup file to customize: most AD IOCs split into st_base.cmd,
# but some (e.g. ADCSimDetector) keep everything in st.cmd.
if [ -f "${boot}/st_base.cmd" ]; then
    cmd="${boot}/st_base.cmd"
elif [ -f "${boot}/st.cmd" ]; then
    cmd="${boot}/st.cmd"
else
    echo "ERROR: no st_base.cmd or st.cmd in ${boot}" >&2
    exit 3
fi
echo "# adcam_build[${CAM_NAME}]: customizing $(basename "${cmd}")"

# --- runtime prefix (no recompile) --------------------------------------
# Replace the stock literal prefix with the $(PREFIX=default) macro. Use | as
# the sed delimiter; {}/:/- are non-special in BRE.
echo "# adcam_build[${CAM_NAME}]: runtime prefix (default ${CAM_PREFIX})"
sed -i "s|epicsEnvSet(\"PREFIX\", \"${CAM_STOCK_PREFIX}\")|epicsEnvSet(\"PREFIX\", \$(PREFIX=${CAM_PREFIX}))|" \
    "${cmd}"

# --- one camera unless the profile keeps cam2 (only if a cam2/SIM2 exists) -
if [ "${CAM_KEEP_CAM2:-no}" != "yes" ] && grep -q 'R=cam2:' "${cmd}"; then
    echo "# adcam_build[${CAM_NAME}]: disable 2nd sim camera (SIM2/cam2)"
    sed -i '/SIM2/s/^/#/' "${cmd}"
    sed -i '/R=cam2:/s/^/#/' "${cmd}"
fi

# --- plugins: customize a LOCAL copy of commonPlugins (leave ADCore's
#     as-supplied). Only if this IOC actually loads commonPlugins. ---------
if grep -q 'commonPlugins.cmd' "${cmd}"; then
    echo "# adcam_build[${CAM_NAME}]: plugins (PVA, FileMagick; drop NeXus)"
    cp "${ADCORE}/iocBoot/commonPlugins.cmd" "${boot}/commonPlugins.cmd"
    sed -i 's|< \$(ADCORE)/iocBoot/commonPlugins.cmd|< commonPlugins.cmd|' "${cmd}"
    sed -i '/NDPvaConfigure/s/^#//;  /dbLoadRecords("NDPva/s/^#//;  /startPVAServer/s/^#//' \
        "${boot}/commonPlugins.cmd"
    sed -i '/FileMagick/s/^#//' "${boot}/commonPlugins.cmd"
    sed -i '/NDFileNexus/s/^/#/;  /NexusTemplate/s/^/#/' "${boot}/commonPlugins.cmd"
    rm -f "${boot}/NexusTemplate.xml"
else
    echo "# adcam_build[${CAM_NAME}]: no commonPlugins in this IOC (skipping plugin tweaks)"
fi

# --- write the collected PV list (dbl-all.txt) for tests/consumers ------
# Insert after iocInit() (some IOCs write it as iocInit, others iocInit()).
grep -q '^dbl > dbl-all.txt' "${cmd}" || \
    sed -i '/^iocInit()\?/a dbl > dbl-all.txt' "${cmd}"

# --- metadata for the generic adcam persona launcher --------------------
# Records the app binary name and default prefix so adcam.sh can start this
# camera without a per-camera script.
{
    echo "CAM_NAME=${CAM_NAME}"
    echo "CAM_PREFIX=${CAM_PREFIX}"
    echo "CAM_APP=${CAM_APP:-}"
    echo "CAM_SRC_IOC=${CAM_SRC_IOC}"
    echo "CAM_HOST_DEVICE='${CAM_HOST_DEVICE:-}'"
} > "${boot}/.adcam"

# --- per-profile extra tweaks (optional hook) ---------------------------
if [ -n "${CAM_POST_HOOK:-}" ] && [ -f "${ADCAM_RESOURCES}/${CAM_POST_HOOK}" ]; then
    echo "# adcam_build[${CAM_NAME}]: profile hook ${CAM_POST_HOOK}"
    bash "${ADCAM_RESOURCES}/${CAM_POST_HOOK}" "${boot}"
fi

echo "# adcam_build[${CAM_NAME}]: done -> ${DEST}"
