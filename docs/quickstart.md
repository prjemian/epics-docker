# Quick start

Run an EPICS IOC from the image. Pick the persona with `-e IOC=...` and the PV
prefix with `-e PREFIX=...`. On rootless podman add `--no-hosts`.

```bash
# a full simulation beamline IOC (synApps), prefix gp:
docker run -d --rm --name iocgp --net=host -e IOC=gp -e PREFIX=gp: prjemian/synapps:latest
caget gp:UPTIME
caget gp:gp:float1
```

Personas: `softioc`, `xxx`, `gp`, `adsim`, `adcsim`, `adurl`, `adpva`
(see each persona's doc, and the [area-detector overview](./area_detector.md)).

## By audience

### Local workstation

Run one or more IOCs and drive them with your EPICS client tools:

```bash
docker run -d --rm --name iocgp    --net=host -e IOC=gp    -e PREFIX=gp:    prjemian/synapps:latest
docker run -d --rm --name iocadsim --net=host -e IOC=adsim -e PREFIX=adsim: prjemian/synapps:latest
caget gp:UPTIME adsim:cam1:Acquire_RBV
```

Give each IOC a unique prefix. Screens are in `/opt/epics/screens` (copy them
to a host with MEDM/caQtDM and launch with `-macro "P=<prefix>"`).

### Continuous integration

Start the IOCs your tests need, then run tests against them:

```bash
docker run -d --rm --name iocgp    --net=host -e IOC=gp    -e PREFIX=gp:  prjemian/synapps:latest
docker run -d --rm --name iocadsim --net=host -e IOC=adsim -e PREFIX=ad:  prjemian/synapps:latest
# wait for a PV, then run the test suite
docker exec iocgp caget gp:UPTIME
```

Host networking lets the runner's clients (pyepics/ophyd) see the PVs. See the
[transition guide](./v3_transition.md) for migrating existing `iocmgr.sh`
usage to v3.

### EPICS client-software development

Use `gp` (rich synApps PVs) and/or `adsim` (area-detector) as known servers to
develop and debug clients against. Change the prefix per run — no rebuild.

### Simulation

Combine personas to emulate much of a beamline without hardware: `gp`
(motors, optics, scalers, scans), area-detector cameras (`adsim`, `adcsim`,
`adurl`, `adpva`), all prefix-isolated.

## Using compose

`compose.yaml` provides `host` and `ports` profiles per persona:

```bash
GP_PREFIX=gp    docker compose --profile host up -d gp-host
ADSIM_PREFIX=ad docker compose --profile host up -d adsim-host
```

Use `--profile ports` on Docker Desktop / Windows / macOS / Synology.

## Next

- [configuration](./configuration.md) — env vars, networking, console, volumes
- persona details: [softioc](./softioc.md), [xxx](./xxx.md), [gp](./gp.md),
  [area-detector cameras](./area_detector.md)
