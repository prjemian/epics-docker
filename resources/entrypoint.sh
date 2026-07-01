#!/bin/bash
# entrypoint.sh -- launch the selected IOC persona under procServ.
#
# The persona is chosen by the IOC env var (default: softioc).
# procServ supervises the IOC: auto-restart, console via telnet on
# IOC_CONSOLE_PORT, no controlling TTY required (podman-friendly).
#
# Env vars (all overridable at container run time):
#   IOC               persona name; runs /usr/local/bin/${IOC}.sh
#   PREFIX            EPICS PV prefix (default: ioc:)
#   IOC_CONSOLE_PORT  procServ console (telnet) port (default: 2048)

set -euo pipefail

IOC="${IOC:-softioc}"
PREFIX="${PREFIX:-ioc:}"
IOC_CONSOLE_PORT="${IOC_CONSOLE_PORT:-2048}"

persona="/usr/local/bin/${IOC}.sh"
if [ ! -x "${persona}" ]; then
    echo "ERROR: unknown IOC persona '${IOC}' (no executable ${persona})" >&2
    echo "Set IOC to a provided persona (e.g. softioc)." >&2
    exit 2
fi

export PREFIX

echo "# starting IOC persona='${IOC}' PREFIX='${PREFIX}' console=telnet:${IOC_CONSOLE_PORT}"

# --foreground   : procServ is PID 1, forwards signals, container stays up
# --logfile -    : IOC output to container stdout (docker/podman logs)
# --name         : label shown on the console
exec procServ \
    --foreground \
    --logfile - \
    --name "${IOC}" \
    "${IOC_CONSOLE_PORT}" \
    "${persona}"
