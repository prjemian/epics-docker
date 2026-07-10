# Configuration

How to configure a running IOC container: the persona, PV prefix, networking,
console, volumes, and the build-time knobs.

## Run-time environment variables

Set with `-e NAME=value` (docker/podman) or the `environment:` block in
`compose.yaml`.

variable | default | meaning
--- | --- | ---
`IOC` | `softioc` | which persona to run: `softioc`, `xxx`, `gp`, `adsim`, `adcsim`, `adurl`, `adpva`
`PREFIX` | persona-specific | PV prefix, **applied at run time (no rebuild)**. Include the trailing colon, e.g. `PREFIX=gp:`. (The as-supplied `xxx` persona ignores this and uses `xxx:`.)
`IOC_CONSOLE_SOCK` | `/tmp/ioc.sock` | procServ console UNIX socket (inside the container)
`IOC_CONSOLE_PORT` | _(unset)_ | opt-in: expose the console on a host TCP port instead of the socket
`IOC_ARGS` | _(empty)_ | extra args passed to `softIoc` (softioc persona only)

Default prefix per persona: `softioc`→`ioc:`, `gp`→`gp:`, `adsim`→`adsim:`,
`adcsim`→`adcsim:`, `adurl`→`adurl:`, `adpva`→`adpva:`, `xxx`→`xxx:` (fixed).

> **Duplicate PVs:** two IOCs serving the same prefix on the same subnet
> conflict (Channel Access duplicate PV). Give each IOC a unique prefix.

### Running several IOCs at once

Give each a unique **prefix** (and therefore a unique container name). Nothing
else to manage — the console is a per-container UNIX socket, so there is **no
port bookkeeping**, and any number of IOCs coexist under `--net=host`:

```bash
# via make: container is named ioc<prefix>; pick only IOC and PREFIX
make run IOC=gp    PREFIX=ocean:
make run IOC=gp    PREFIX=sky:
make run IOC=adsim PREFIX=air:
make stop PREFIX=ocean:

# via docker/podman directly
docker run -d --rm --name iococean --net=host -e IOC=gp -e PREFIX=ocean: prjemian/synapps:latest
docker run -d --rm --name iocsky   --net=host -e IOC=gp -e PREFIX=sky:   prjemian/synapps:latest
```

The `make run`/`make stop` targets name the container `ioc<prefix>` (trailing
colon stripped), e.g. `PREFIX=ocean:` -> `iococean` — matching the
`iocgp`/`iocadsim` style and the compose services.

## Networking

The image serves EPICS **Channel Access** (CA, ports `5064-5065`) and
**pvAccess** (PVA, ports `5075-5076`). Two approaches:

### host networking (Linux, CI)

```bash
docker run -d --rm --net=host -e IOC=gp -e PREFIX=gp: prjemian/synapps:latest
```

Clients on the host see the PVs directly. Fast; the simplest option on Linux.
This is what CI (e.g. apstools) uses.

### port mapping (Docker Desktop, Windows, macOS, Synology)

Where host networking is unavailable, publish the CA/PVA ports (see the
`*-ports` compose services). A client may need its address list pointed at the
container host:

```bash
export EPICS_CA_ADDR_LIST=<container-host>
export EPICS_CA_AUTO_ADDR_LIST=NO
```

> Only one IOC can bind the standard CA/PVA ports on a host at a time in the
> `ports` profile; use host networking (Linux) to run several at once, each
> with a distinct prefix.

### macOS

On macOS, containers run inside a Linux VM (Docker/Podman Desktop), so
`--net=host` does not expose PVs to the Mac -- use the **`ports` profile**.

Architecture: the image is pulled for your Mac's CPU automatically (one tag
resolves to the right variant):

- **Intel Macs** use `linux/amd64` -- supported today.
- **Apple Silicon (M1/M2/M3/...)** use `linux/arm64`. Until a verified arm64
  image is published, Docker Desktop runs the `linux/amd64` variant under
  emulation (works, slower). See the multi-arch status in
  [`docs/v3_strategy.md`](./v3_strategy.md).

## procServ console

IOCs run under [`procServ`](https://github.com/ralphlange/procServ)
(auto-restart, no TTY needed). The console is a **UNIX socket inside the
container** (no host port), so attach by container name:

```bash
make console PREFIX=demo:               # attaches to iocdemo
# or directly:
docker exec -it iocdemo console         # Ctrl-] then 'quit' to detach; NOT Ctrl-C
```

Container stdout carries the IOC log (`docker logs <name>`).

> **Opt-in host TCP console:** set `IOC_CONSOLE_PORT` at run time to expose the
> console on a host port instead (`telnet localhost <port>`). Then each
> concurrent `--net=host` IOC needs a distinct port — which is why the socket
> is the default.

## Volumes

The image is self-contained; no volumes are required. Useful mounts:

purpose | mount
--- | ---
persist areaDetector file-writer output | mount a host dir where the IOC writes (set the file plugin's path to it)
inspect build logs | `/opt/build-logs` (also `/home/build-logs`)
copy screens to a client host | `/opt/epics/screens` (also `/home/screens`)

## Inside the container

`docker exec` lands in `/home`, with convenience links: `base`, `support`,
`screens`, `build-logs`, the IOC boot dirs (`iocgp`, `iocadsim`, ...), and the
persona launchers.

```bash
docker exec iocgp caget gp:UPTIME
```

## Build-time knobs (versions.env)

These are set when **building** the image (single source of truth:
[`versions.env`](../versions.env)); see the
[maintainer guide](./maintainer.md).

variable | meaning
--- | ---
`EPICS_BASE_VERSION` | EPICS base release
`SYNAPPS_VERSION` | synApps assembler release
`SYNAPPS_OVERRIDE_MOTOR` | documented per-module version exception
`AD_DRIVERS` | extra areaDetector drivers to build
`MOTOR_SREV` | steps/rev for the gp sim motors
`DEBIAN_TAG` | base OS image tag

## See also

- [area-detector overview](./area_detector.md)
- [maintainer guide](./maintainer.md)
- [`compose.yaml`](../compose.yaml)
