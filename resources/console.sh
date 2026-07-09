#!/bin/bash
# console.sh -- attach to this IOC's procServ console (inside the container).
#
# Intended to be run via `docker exec -it <container> console`. Connects to the
# procServ UNIX socket, so no host port is involved. Detach with Ctrl-] then
# 'quit' (procServ), NOT Ctrl-C (that would signal the IOC).
#
# If the IOC was started with IOC_CONSOLE_PORT (host TCP), attach with
# `telnet localhost <port>` on the host instead.

set -euo pipefail
sock="${IOC_CONSOLE_SOCK:-/tmp/ioc.sock}"

if [ ! -S "${sock}" ]; then
    echo "ERROR: no procServ console socket at ${sock}" >&2
    echo "(If this IOC was started with IOC_CONSOLE_PORT, use telnet on the host.)" >&2
    exit 2
fi

echo "# attaching to procServ console at ${sock}"
echo "# detach: Ctrl-] then 'quit'  (do NOT Ctrl-C)"
exec nc -U "${sock}"
