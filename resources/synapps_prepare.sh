#!/bin/bash
# synapps_prepare.sh -- prepare a downloaded assemble_synApps.sh for our build.
#
# Strategy (see docs/v3_strategy.md): we do NOT source a config file, because
# doing so makes assemble_synApps.sh skip its release-matched default module
# tags entirely. Instead we let the release's own defaults stand (so kept
# modules track the synApps release) and apply two minimal, stable edits:
#
#   1. point EPICS_BASE at our in-image base
#   2. empty each EXCLUDED module (MODULE=...  ->  MODULE=), which the
#      assembler treats as "skip this module" via its `if [[ $MODULE ]]` guards
#
# Upgrading synApps = bump SYNAPPS_VERSION in versions.env (nothing here).
#
# Usage: synapps_prepare.sh <assemble_synApps.sh> <EPICS_BASE_path>

set -euo pipefail

SCRIPT="${1:?usage: synapps_prepare.sh <assemble_synApps.sh> <EPICS_BASE>}"
EPICS_BASE_PATH="${2:?usage: synapps_prepare.sh <assemble_synApps.sh> <EPICS_BASE>}"

# Hardware / not-wanted modules to exclude. Matches the v2.0 selection
# (all hardware-specific drivers). Kept modules (asyn, autosave, busy, calc,
# caputRecorder, iocStats, ip, ipac, lua, mca, modbus, motor, optics, sscan,
# std, stream, xxx, areaDetector) are left at the release's default tags.
EXCLUDE_MODULES=(
    ALLENBRADLEY
    CAMAC
    DAC128V
    DELAYGEN
    DXP
    DXPSITORO
    ETHERIP
    GALIL
    IP330
    IPUNIDIG
    LOVE
    MEASCOMP
    OPCUA
    QUADEM
    SOFTGLUE
    SOFTGLUEZYNQ
    ULDAQ
    VAC
    VME
    YOKOGAWA_DAS
    XSPRESS3
)

echo "# synapps_prepare: EPICS_BASE -> ${EPICS_BASE_PATH}"
# Replace the (tab-indented) default EPICS_BASE assignment.
sed -i -E "s|^([[:space:]]*)EPICS_BASE=.*|\1EPICS_BASE=${EPICS_BASE_PATH//|/\\|}|" "${SCRIPT}"

for mod in "${EXCLUDE_MODULES[@]}"; do
    # Empty the module's tag assignment (keeps the line, disables the module).
    # Only touches "  MODULE=<value>" default assignments.
    if grep -qE "^[[:space:]]*${mod}=" "${SCRIPT}"; then
        sed -i -E "s|^([[:space:]]*)${mod}=.*|\1${mod}=|" "${SCRIPT}"
        echo "# synapps_prepare: excluded ${mod}"
    else
        echo "# synapps_prepare: note: ${mod} not present in this release (skipped)"
    fi
done

# Apply documented per-module version OVERRIDES from the environment.
# Each SYNAPPS_OVERRIDE_<MODULE>=<TAG> sets that module's tag, overriding the
# release default. These are deliberate exceptions (see versions.env). We warn
# on each so overrides are visible in the build log and easy to audit/retire.
for var in $(compgen -A variable | grep '^SYNAPPS_OVERRIDE_' || true); do
    mod="${var#SYNAPPS_OVERRIDE_}"
    tag="${!var}"
    [ -z "${tag}" ] && continue
    if grep -qE "^[[:space:]]*${mod}=" "${SCRIPT}"; then
        sed -i -E "s|^([[:space:]]*)${mod}=.*|\1${mod}=${tag}|" "${SCRIPT}"
        echo "# synapps_prepare: OVERRIDE ${mod}=${tag} (documented exception)"
    else
        echo "# synapps_prepare: WARNING: override target ${mod} not found in script" >&2
    fi
done

echo "# synapps_prepare: done"
