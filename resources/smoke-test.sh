#!/bin/bash
# smoke-test.sh -- verify IOC persona(s) start and serve PVs.
#
# Usage: smoke-test.sh ENGINE IMAGE
# For each persona, runs the image, waits for the IOC, and cagets a PV
# *inside* the container (no host EPICS client needed).
#
# Personas tested depend on what the image provides:
#   softioc : always (base-epics and up). PVs under a runtime PREFIX.
#   xxx     : if /usr/local/bin/xxx.sh exists (base-synapps and up).
#             As-supplied template; fixed prefix "xxx:".

set -euo pipefail

ENGINE="${1:?usage: smoke-test.sh ENGINE IMAGE}"
IMAGE="${2:?usage: smoke-test.sh ENGINE IMAGE}"

# Extra `run` flags (e.g. --no-hosts for rootless podman).
RUN_FLAGS="${RUN_FLAGS:-}"

fail() { echo "FAIL: $*" >&2; exit 1; }

# wait_pv NAME PV -- return 0 once PV is readable inside container NAME.
wait_pv() {
    local name="$1" pv="$2" i
    for i in $(seq 1 40); do
        if "${ENGINE}" exec "${name}" caget "${pv}" >/dev/null 2>&1; then
            return 0
        fi
        sleep 1
    done
    return 1
}

# test_persona IOC PREFIX PROBE_PV
test_persona() {
    local ioc="$1" prefix="$2" probe="$3"
    local name="synapps-smoke-${ioc}-$$"
    echo "=== persona '${ioc}' (PREFIX=${prefix}) ==="
    # shellcheck disable=SC2086
    "${ENGINE}" run ${RUN_FLAGS} --rm -d --name "${name}" \
        -e "IOC=${ioc}" -e "PREFIX=${prefix}" "${IMAGE}" >/dev/null
    trap '"${ENGINE}" rm -f "'"${name}"'" >/dev/null 2>&1 || true' RETURN

    if ! wait_pv "${name}" "${probe}"; then
        "${ENGINE}" logs "${name}" >&2 || true
        "${ENGINE}" rm -f "${name}" >/dev/null 2>&1 || true
        fail "persona '${ioc}': IOC did not serve ${probe} in time"
    fi
    "${ENGINE}" exec "${name}" caget "${probe}"
    "${ENGINE}" rm -f "${name}" >/dev/null 2>&1 || true
    echo "PASS: persona '${ioc}' serves ${probe}"
}

# --- softioc (always present) ---
test_persona softioc "smoke:" "smoke:UPTIME"

# --- xxx (only if the image provides it) ---
if "${ENGINE}" run ${RUN_FLAGS} --rm --entrypoint test "${IMAGE}" \
        -x /usr/local/bin/xxx.sh >/dev/null 2>&1; then
    # As-supplied xxx uses its own fixed prefix "xxx:", ignoring PREFIX.
    test_persona xxx "ignored:" "xxx:UPTIME"
else
    echo "# (xxx persona not in this image; skipping)"
fi

# --- gp (only if the image provides it) ---
# Use a UNIQUE prefix (not bare gp:) and no host networking so the test IOC
# never collides with a gp: IOC already on the subnet. Probe the CI-contract
# general-purpose PV (<prefix>gp:float1).
if "${ENGINE}" run ${RUN_FLAGS} --rm --entrypoint test "${IMAGE}" \
        -x /usr/local/bin/gp.sh >/dev/null 2>&1; then
    test_persona gp "smoketestgp:" "smoketestgp:gp:float1"
else
    echo "# (gp persona not in this image; skipping)"
fi

echo "SMOKE TEST PASSED"
