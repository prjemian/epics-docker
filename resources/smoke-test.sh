#!/bin/bash
# smoke-test.sh -- verify the softIoc persona starts and serves PVs.
#
# Usage: smoke-test.sh ENGINE IMAGE
# Runs the image, waits for the IOC, and cagets a demo PV *inside* the
# container (no host EPICS client needed).

set -euo pipefail

ENGINE="${1:?usage: smoke-test.sh ENGINE IMAGE}"
IMAGE="${2:?usage: smoke-test.sh ENGINE IMAGE}"

# Extra `run` flags (e.g. --no-hosts for rootless podman).
RUN_FLAGS="${RUN_FLAGS:-}"

PREFIX="smoke:"
NAME="synapps-smoke-$$"

cleanup() { "${ENGINE}" rm -f "${NAME}" >/dev/null 2>&1 || true; }
trap cleanup EXIT

echo "# starting ${IMAGE} as ${NAME} (PREFIX=${PREFIX})"
"${ENGINE}" run ${RUN_FLAGS} --rm -d --name "${NAME}" -e "PREFIX=${PREFIX}" "${IMAGE}" >/dev/null

echo "# waiting for IOC to serve ${PREFIX}UPTIME ..."
ok=0
for i in $(seq 1 30); do
    if "${ENGINE}" exec "${NAME}" caget "${PREFIX}IOC_NAME" >/dev/null 2>&1; then
        ok=1
        break
    fi
    sleep 1
done

if [ "${ok}" -ne 1 ]; then
    echo "FAIL: IOC did not come up in time" >&2
    "${ENGINE}" logs "${NAME}" >&2 || true
    exit 1
fi

echo "# PVs:"
"${ENGINE}" exec "${NAME}" caget "${PREFIX}IOC_NAME" "${PREFIX}UPTIME"

# Confirm UPTIME is advancing (proves SCAN is running).
u1="$("${ENGINE}" exec "${NAME}" caget -t "${PREFIX}UPTIME")"
sleep 2
u2="$("${ENGINE}" exec "${NAME}" caget -t "${PREFIX}UPTIME")"
if [ "${u2}" -gt "${u1}" ] 2>/dev/null; then
    echo "PASS: UPTIME advanced ${u1} -> ${u2}"
else
    echo "FAIL: UPTIME did not advance (${u1} -> ${u2})" >&2
    exit 1
fi

echo "SMOKE TEST PASSED"
