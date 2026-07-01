#!/bin/bash
# ad_drivers.sh -- enable + fetch extra areaDetector drivers before the AD
# build. ADSimDetector + ADCore + ADSupport are already handled by the
# synApps assembler; this adds the drivers listed in AD_DRIVERS.
#
# For each driver variable (a RELEASE.local name, e.g. ADURL):
#   1. uncomment its line in areaDetector's configure/RELEASE.local
#   2. git submodule update --init the driver's directory
# The subsequent AD `make` then builds it.
#
# ADUVC also needs its bundled libuvc built (uvcSupport); handled here.
#
# Usage: ad_drivers.sh AREA_DETECTOR "DRIVER1 DRIVER2 ..."

set -euo pipefail
AD="${1:?usage: ad_drivers.sh AREA_DETECTOR DRIVERS}"
DRIVERS="${2:-}"

rel="${AD}/configure/RELEASE.local"
cd "${AD}"

# map RELEASE.local var -> submodule directory name
dir_for() {
    case "$1" in
        ADCSIMDETECTOR) echo "ADCSimDetector" ;;
        ADURL)          echo "ADURL" ;;
        PVADRIVER)      echo "pvaDriver" ;;
        FFMPEGSERVER)   echo "ffmpegServer" ;;
        FFMPEGVIEWER)   echo "ffmpegViewer" ;;
        ADUVC)          echo "ADUVC" ;;
        *)              echo "" ;;
    esac
}

for drv in ${DRIVERS}; do
    d="$(dir_for "${drv}")"
    if [ -z "${d}" ]; then
        echo "# ad_drivers: WARNING unknown driver '${drv}', skipping" >&2
        continue
    fi
    echo "# ad_drivers: enable ${drv} (${d})"
    # uncomment "#DRV=$(AREA_DETECTOR)/Dir"
    sed -i "s|^#\(${drv}=\$(AREA_DETECTOR)/${d}\)|\1|" "${rel}"

    echo "# ad_drivers: fetch submodule ${d}"
    git submodule update --init --depth 1 "${d}" 2>&1 | tail -2

    # driver-specific extra support
    if [ "${drv}" = "ADUVC" ] && [ -d "${d}/uvcSupport" ]; then
        echo "# ad_drivers: build bundled libuvc for ADUVC"
        make -C "${d}/uvcSupport" 2>&1 | tail -3 || \
            echo "# ad_drivers: WARNING libuvc build had issues" >&2
    fi
done

echo "# ad_drivers: enabled in RELEASE.local:"
grep -E "^(ADCSIMDETECTOR|ADURL|PVADRIVER|FFMPEGSERVER|FFMPEGVIEWER|ADUVC)=" "${rel}" || true
