#!/bin/bash
# gp_build.sh -- build the customized "gp" (general purpose) synApps IOC.
#
# Full-parity port of the v2.0 GP customizations, applied to a copy of the
# stock synApps xxx template. Where v2 edited upstream files in place with many
# `sed` calls, we prefer shipped overlay files (this dir) plus the minimal
# wiring needed to include them. The functional result matches v2 GP:
#
#   * runtime-overridable PV prefix (default gp:)
#   * 56 soft/sim motors (m1..m56) with descriptive names
#   * optics: kohzu mono, slit pairs, coarse/fine, orient/4-circle, crystals
#   * std: soft scalers (scaler1..3) with named channels, fb_epid feedback
#   * general-purpose PVs: $(PREFIX)gp:{float,bit,int,text,longtext,array}1..20
#   * iocStats timezone fix; ALIVE disabled
#
# Env (from the build stage): SUPPORT, MOTOR, OPTICS, SCALER, XXX, GP_DIR,
# GP_RESOURCES (this directory).
#
# Usage: gp_build.sh

set -euo pipefail

: "${SUPPORT:?}"
GP_RESOURCES="$(cd "$(dirname "$0")" && pwd)"

# Resolve module dirs (version-independent).
XXX="$(ls -d "${SUPPORT}"/xxx-* | head -n1)"
MOTOR="$(ls -d "${SUPPORT}"/motor-* | head -n1)"
OPTICS="$(ls -d "${SUPPORT}"/optics-* | head -n1)"
SCALER="$(ls -d "${SUPPORT}"/scaler-* | head -n1)"

GP="${SUPPORT}/iocgp"

echo "# gp_build: copy xxx -> gp (directory copy; NO changePrefix)"
# We deliberately do NOT use synApps' changePrefix: it rewrites/renames source
# files at build time, which fights the runtime-prefix goal and is a
# maintenance burden. The PV prefix is made runtime-settable below with a
# one-line, non-destructive macro-default edit. Internal app/db names stay as
# xxx's -- only the runtime PV prefix matters to consumers.
cp -a "${XXX}/" "${GP}"
rm -rf "${GP}"/.git* "${GP}"/.ci* "${GP}"/.travis.yml
make -C "${GP}" clean || true

# The boot dir keeps its stock name (iocxxx) since we skip changePrefix.
IOCGP="${GP}/iocBoot/iocxxx"
cd "${IOCGP}"

echo "# gp_build: make PV prefix runtime-overridable (default gp:)"
# EPICS macro default: environment PREFIX wins, else gp:. No changePrefix.
sed -i 's/epicsEnvSet("PREFIX", "xxx:")/epicsEnvSet("PREFIX", $(PREFIX=gp:))/' settings.iocsh

echo "# gp_build: disable ALIVE"
sed -i '/ALIVE/s/^/#/g' common.iocsh

echo "# gp_build: iocStats timezone fix (EPICS_TIMEZONE -> EPICS_TZ)"
iocstats_db="$(ls "${SUPPORT}"/iocStats-*/db/iocAdminSoft.db 2>/dev/null | head -n1 || true)"
[ -n "${iocstats_db}" ] && sed -i 's:EPICS_TIMEZONE:EPICS_TZ:g' "${iocstats_db}" || true

# Sub-steps (each ships its own overlay files where practical).
bash "${GP_RESOURCES}/gp_general_purpose.sh" "${IOCGP}" "${GP_RESOURCES}"
bash "${GP_RESOURCES}/gp_motors.sh"          "${IOCGP}" "${GP_RESOURCES}" "${MOTOR}"
bash "${GP_RESOURCES}/gp_optics.sh"          "${IOCGP}" "${GP_RESOURCES}" "${OPTICS}"
bash "${GP_RESOURCES}/gp_std.sh"             "${IOCGP}" "${GP_RESOURCES}" "${SCALER}"

# Display files are handled at the runtime stage by collect_screens.sh, which
# copies them to an all-in-one directory and fixes the COPIES only (leaving the
# module screens as-supplied). See the base-synapps stage.

echo "# gp_build: compile gp IOC"
make -C "${GP}"

echo "# gp_build: done -> ${GP}"
