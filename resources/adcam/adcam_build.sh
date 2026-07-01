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
    echo "ERROR: source IOC boot dir not found: ${SRC}" >&2
    exit 3
fi

echo "# adcam_build[${CAM_NAME}]: copy ${SRC} -> ${DEST}"
mkdir -p "${DEST}"
cp -a "${SRC}/." "${DEST}/"
rm -f "${DEST}"/Makefile*

boot="${DEST}"   # the copied dir IS the iocBoot dir

# --- runtime prefix (no recompile) --------------------------------------
echo "# adcam_build[${CAM_NAME}]: runtime prefix (default ${CAM_PREFIX})"
sed -i "s/epicsEnvSet(\"PREFIX\", \"${CAM_STOCK_PREFIX}\")/epicsEnvSet(\"PREFIX\", \$(PREFIX=${CAM_PREFIX}))/" \
    "${boot}/st_base.cmd"

# --- one camera unless the profile keeps cam2 ---------------------------
if [ "${CAM_KEEP_CAM2:-no}" != "yes" ]; then
    echo "# adcam_build[${CAM_NAME}]: disable 2nd sim camera (SIM2/cam2)"
    sed -i '/SIM2/s/^/#/' "${boot}/st_base.cmd"
    sed -i '/R=cam2:/s/^/#/' "${boot}/st_base.cmd"
fi

# --- plugins: customize a LOCAL copy of commonPlugins (leave ADCore's
#     as-supplied). Enable PVA server + FileMagick; keep all file writers
#     except NeXus. ------------------------------------------------------
echo "# adcam_build[${CAM_NAME}]: plugins (PVA, FileMagick; drop NeXus)"
cp "${ADCORE}/iocBoot/commonPlugins.cmd" "${boot}/commonPlugins.cmd"
# point st_base.cmd at our local copy instead of ADCore's
sed -i 's|< \$(ADCORE)/iocBoot/commonPlugins.cmd|< commonPlugins.cmd|' "${boot}/st_base.cmd"
# enable PVA access server + Magick file plugin (commented out by default)
sed -i '/NDPvaConfigure/s/^#//;  /dbLoadRecords("NDPva/s/^#//;  /startPVAServer/s/^#//' \
    "${boot}/commonPlugins.cmd"
sed -i '/FileMagick/s/^#//' "${boot}/commonPlugins.cmd"
# drop NeXus writer (superseded by HDF5)
sed -i '/NDFileNexus/s/^/#/;  /NexusTemplate/s/^/#/' "${boot}/commonPlugins.cmd"
rm -f "${boot}/NexusTemplate.xml"

# --- write the collected PV list (dbl-all.txt) for tests/consumers ------
grep -q '^dbl > dbl-all.txt' "${boot}/st_base.cmd" || \
    sed -i '/^iocInit()/a dbl > dbl-all.txt' "${boot}/st_base.cmd"

# --- per-profile extra tweaks (optional hook) ---------------------------
if [ -n "${CAM_POST_HOOK:-}" ] && [ -f "${ADCAM_RESOURCES}/${CAM_POST_HOOK}" ]; then
    echo "# adcam_build[${CAM_NAME}]: profile hook ${CAM_POST_HOOK}"
    bash "${ADCAM_RESOURCES}/${CAM_POST_HOOK}" "${boot}"
fi

echo "# adcam_build[${CAM_NAME}]: done -> ${DEST}"
