#!/bin/bash
# softioc.sh -- EPICS base softIoc persona (standard, base-only).
#
# A pure `softIoc` from EPICS base. It defines NO records and ships NO .db and
# NO st.cmd: the databases, macros, access-security file, prefix, and/or a
# startup script are entirely the caller's choice, supplied via IOC_ARGS
# (passed verbatim to softIoc). With no IOC_ARGS, softIoc starts empty.
#
# PREFIX is NOT used here. It remains a run-time/orchestration parameter only
# (it names the container ioc<prefix>); it does not define any records. If you
# want your database prefixed, pass it yourself, e.g.
#   -e IOC_ARGS="-m P=demo: -d /path/to/mounted.db"
#
# softIoc options (see `softIoc -h`): -d <db>, -m <macro=val,...>, -a <acf>,
#   -x <prefix> (base's softIocExit.db), and an optional trailing st.cmd.

set -euo pipefail

softIoc_bin="${EPICS_BASE}/binln/softIoc"
IOC_ARGS="${IOC_ARGS:-}"

echo "# softIoc (EPICS base; records are user-supplied) args='${IOC_ARGS}'"
# shellcheck disable=SC2086
exec "${softIoc_bin}" ${IOC_ARGS}
