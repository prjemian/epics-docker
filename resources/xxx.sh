#!/bin/bash
# xxx.sh -- synApps "xxx" template IOC persona, AS SUPPLIED by upstream.
#
# This persona runs the stock synApps xxx template exactly as it ships:
# it executes iocBoot/iocxxx/st.cmd.Linux unmodified. Consequently:
#
#   * The PV prefix is whatever the template ships (default "xxx:"), set in
#     settings.iocsh via changePrefix at build time -- NOT the container's
#     runtime PREFIX. We intentionally do not modify the template to inject a
#     runtime prefix; that would defeat the "as-supplied" goal. A customized,
#     runtime-prefix persona ("gp") is provided separately.
#   * Upstream's README notes the template expects site/hardware editing of
#     st.cmd.* to run fully. It may log warnings or not initialize every
#     component in this generic container. That is the honest "as-supplied"
#     behavior; use the "gp" persona for a ready-to-run simulation IOC.
#
# Env vars:
#   (PREFIX from the container is ignored here by design.)

set -euo pipefail

XXX_IOCBOOT="$(ls -d "${SUPPORT}"/xxx-*/iocBoot/iocxxx 2>/dev/null | head -n1)"
if [ -z "${XXX_IOCBOOT}" ] || [ ! -d "${XXX_IOCBOOT}" ]; then
    echo "ERROR: xxx template iocBoot dir not found under ${SUPPORT}" >&2
    exit 2
fi

xxx_bin="$(ls -d "${SUPPORT}"/xxx-*/bin/*/xxx 2>/dev/null | head -n1)"
if [ -z "${xxx_bin}" ]; then
    echo "ERROR: xxx IOC binary not found (was it built?)" >&2
    exit 2
fi

echo "# xxx (as-supplied) starting from ${XXX_IOCBOOT}"
echo "# note: PV prefix is the template default (see settings.iocsh), not \$PREFIX"

cd "${XXX_IOCBOOT}"
exec "${xxx_bin}" st.cmd.Linux
