#!/bin/bash
# entrypoint.sh -- launch the selected IOC persona under procServ.
#
# The persona is chosen by the IOC env var (default: softioc).
# procServ supervises the IOC: auto-restart, no controlling TTY required
# (podman-friendly).
#
# Console: by default procServ listens on a UNIX domain socket INSIDE the
# container (${IOC_CONSOLE_SOCK}). Attach via the container, e.g.
#   docker exec -it <container> console        (or: make console PREFIX=...)
# This needs no host port, so any number of IOCs run concurrently under
# --net=host without port bookkeeping.
#
# Opt-in: set IOC_CONSOLE_PORT to expose the console on a host TCP port
# instead (the old behaviour); then each concurrent --net=host IOC needs a
# distinct port.
#
# Env vars (all overridable at container run time):
#   IOC               persona name; runs /usr/local/bin/${IOC}.sh
#   PREFIX            EPICS PV prefix (default: ioc:)
#   IOC_CONSOLE_SOCK  unix socket path for the console (default: /tmp/ioc.sock)
#   IOC_CONSOLE_PORT  if set, use this host TCP port instead of the socket

set -euo pipefail

IOC="${IOC:-softioc}"
PREFIX="${PREFIX:-ioc:}"
IOC_CONSOLE_SOCK="${IOC_CONSOLE_SOCK:-/tmp/ioc.sock}"

persona="/usr/local/bin/${IOC}.sh"
if [ ! -x "${persona}" ]; then
    echo "ERROR: unknown IOC persona '${IOC}' (no executable ${persona})" >&2
    echo "Set IOC to a provided persona (e.g. softioc)." >&2
    exit 2
fi

export PREFIX

# procServ console endpoint: TCP port if IOC_CONSOLE_PORT is set, else a
# UNIX socket inside the container.
if [ -n "${IOC_CONSOLE_PORT:-}" ]; then
    endpoint="${IOC_CONSOLE_PORT}"
    echo "# starting IOC persona='${IOC}' PREFIX='${PREFIX}' console=telnet:${IOC_CONSOLE_PORT}"
else
    endpoint="unix:${IOC_CONSOLE_SOCK}"
    echo "# starting IOC persona='${IOC}' PREFIX='${PREFIX}' console=${endpoint} (attach via exec)"
fi

# --foreground : procServ is PID 1, forwards signals, container stays up
# --logfile -  : IOC output to container stdout (docker/podman logs)
# --name       : label shown on the console
exec procServ \
    --foreground \
    --logfile - \
    --name "${IOC}" \
    "${endpoint}" \
    "${persona}"
