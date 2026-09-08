#!/bin/bash
# smoke-test.sh -- verify IOC persona(s) start and serve PVs.
#
# Usage: smoke-test.sh ENGINE IMAGE
# For each persona, runs the image, waits for the IOC, and cagets a PV
# *inside* the container (no host EPICS client needed).
#
# The softioc persona is base-only and defines NO records of its own, so the
# test supplies its own database (resources/smoke.db) via IOC_ARGS. The other
# personas serve records from their standard/customized sources.

set -euo pipefail

ENGINE="${1:?usage: smoke-test.sh ENGINE IMAGE}"
IMAGE="${2:?usage: smoke-test.sh ENGINE IMAGE}"

# Extra `run` flags (e.g. --no-hosts for rootless podman).
RUN_FLAGS="${RUN_FLAGS:-}"

# Location of this script (to find the test database).
HERE="$(cd "$(dirname "$0")" && pwd)"

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

# --- softioc (always present): base-only, so the TEST supplies its own db ---
# Mount resources/smoke.db and load it via IOC_ARGS with prefix P=smoke:.
# Verify the self-incrementing $(P)test_heartbeat advances (proves the IOC is
# up and scanning). The softioc persona itself defines no records.
test_softioc() {
    local name="synapps-smoke-softioc-$$" pv="smoke:test_heartbeat"
    echo "=== persona 'softioc' (test supplies smoke.db, PREFIX=smoke:) ==="
    # shellcheck disable=SC2086
    "${ENGINE}" run ${RUN_FLAGS} --rm -d --name "${name}" \
        -v "${HERE}/smoke.db:/tmp/smoke.db:ro" \
        -e IOC=softioc \
        -e IOC_ARGS="-m P=smoke: -d /tmp/smoke.db" \
        "${IMAGE}" >/dev/null
    trap '"${ENGINE}" rm -f "'"${name}"'" >/dev/null 2>&1 || true' RETURN

    if ! wait_pv "${name}" "${pv}"; then
        "${ENGINE}" logs "${name}" >&2 || true
        "${ENGINE}" rm -f "${name}" >/dev/null 2>&1 || true
        fail "persona 'softioc': IOC did not serve ${pv} in time"
    fi
    local v1 v2
    v1="$("${ENGINE}" exec "${name}" caget -t "${pv}")"
    sleep 2
    v2="$("${ENGINE}" exec "${name}" caget -t "${pv}")"
    "${ENGINE}" rm -f "${name}" >/dev/null 2>&1 || true
    if [ "${v2}" -gt "${v1}" ] 2>/dev/null; then
        echo "PASS: persona 'softioc' ${pv} advanced ${v1} -> ${v2}"
    else
        fail "persona 'softioc': ${pv} did not advance (${v1} -> ${v2})"
    fi
}
test_softioc

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

# --- areaDetector camera personas (only those the image provides) ---
# Unique prefixes, no host networking. Each camera has its own probe PV:
#   adsim/adurl/adpva = area cameras (cam1:), adcsim = ADC/waveform (det1:).
adcam_probe() {
    case "$1" in
        adcsim) echo "det1:TimeStamp_RBV" ;;
        *)      echo "cam1:Acquire_RBV" ;;
    esac
}
for cam in adsim adcsim adurl adpva; do
    if "${ENGINE}" run ${RUN_FLAGS} --rm --entrypoint test "${IMAGE}" \
            -x "/usr/local/bin/${cam}.sh" >/dev/null 2>&1; then
        pfx="smoketest${cam}:"
        test_persona "${cam}" "${pfx}" "${pfx}$(adcam_probe "${cam}")"
    else
        echo "# (${cam} persona not in this image; skipping)"
    fi
done

echo "SMOKE TEST PASSED"
