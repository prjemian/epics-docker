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
`IOC_CONSOLE_PORT` | `2048` | procServ console (telnet) port
`IOC_ARGS` | _(empty)_ | extra args passed to `softIoc` (softioc persona only)

Default prefix per persona: `softioc`→`ioc:`, `gp`→`gp:`, `adsim`→`adsim:`,
`adcsim`→`adcsim:`, `adurl`→`adurl:`, `adpva`→`adpva:`, `xxx`→`xxx:` (fixed).

> **Duplicate PVs:** two IOCs serving the same prefix on the same subnet
> conflict (Channel Access duplicate PV). Give each IOC a unique prefix.

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

## procServ console

IOCs run under [`procServ`](https://github.com/ralphlange/procServ)
(auto-restart, no TTY needed). Attach to the IOC shell over telnet:

```bash
telnet localhost 2048          # Ctrl-] then 'quit' to detach; do NOT Ctrl-C
```

Container stdout carries the IOC log (`docker logs <name>`).

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
