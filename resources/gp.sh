#!/bin/bash
# gp.sh -- customized "gp" (general purpose) synApps IOC persona.
#
# Runs the gp IOC built from the synApps xxx template with prjemian's
# customizations (56 sim motors, optics, soft scalers, general-purpose PVs).
# Unlike the as-supplied xxx persona, gp honors the container's runtime PREFIX
# (default gp:), requiring NO recompilation to change the prefix.
#
# Env vars:
#   PREFIX   PV prefix (default gp:), consumed by settings.iocsh's
#            epicsEnvSet("PREFIX", $(PREFIX=gp:)) macro default.

set -euo pipefail

PREFIX="${PREFIX:-gp:}"
export PREFIX

GP_IOCBOOT="$(ls -d "${SUPPORT}"/iocgp/iocBoot/ioc* 2>/dev/null | head -n1)"
if [ -z "${GP_IOCBOOT}" ] || [ ! -d "${GP_IOCBOOT}" ]; then
    echo "ERROR: gp IOC boot dir not found under ${SUPPORT}/iocgp" >&2
    exit 2
fi

gp_bin="$(ls -d "${SUPPORT}"/iocgp/bin/*/xxx 2>/dev/null | head -n1)"
if [ -z "${gp_bin}" ]; then
    echo "ERROR: gp IOC binary not found (was it built?)" >&2
    exit 2
fi

echo "# gp (customized) starting from ${GP_IOCBOOT} with PREFIX='${PREFIX}'"
cd "${GP_IOCBOOT}"
exec "${gp_bin}" st.cmd.Linux
