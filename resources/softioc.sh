#!/bin/bash
# softioc.sh -- EPICS base softIoc persona.
#
# Runs `softIoc` with a small demo database, using the PV PREFIX passed
# from the environment. Exposes softIoc's command-line options via the
# IOC_ARGS env var for callers who want them.
#
# Env vars:
#   PREFIX     PV prefix (default: ioc:)
#   IOC_ARGS   extra args passed verbatim to softIoc (optional)

set -euo pipefail

PREFIX="${PREFIX:-ioc:}"
IOC_ARGS="${IOC_ARGS:-}"

# Locate softIoc regardless of host arch (binln is the stable symlink).
softIoc_bin="${EPICS_BASE}/binln/softIoc"

# Minimal demo database: an uptime counter and a couple of scratch PVs,
# all under ${PREFIX}. Kept tiny; richer personas come in later phases.
demo_db="$(mktemp --suffix=.db)"
cat > "${demo_db}" <<'EOF'
record(calc, "$(P)UPTIME") {
    field(DESC, "IOC uptime, seconds")
    field(SCAN, "1 second")
    field(INPA, "$(P)UPTIME.VAL")
    field(CALC, "A+1")
    field(EGU,  "s")
}
record(stringout, "$(P)IOC_NAME") {
    field(DESC, "persona name")
    field(VAL,  "softioc")
    field(PINI, "YES")
}
record(ao, "$(P)float1") {
    field(DESC, "scratch analog value")
    field(PREC, "3")
}
EOF

echo "# softIoc PREFIX='${PREFIX}' db='${demo_db}'"

# softIoc: -m sets macros, -d loads a database, -x can set an IOC prefix
# for the iocsh dbLoadRecords context. Here we pass P via -m.
exec "${softIoc_bin}" -m "P=${PREFIX}" -d "${demo_db}" ${IOC_ARGS}
