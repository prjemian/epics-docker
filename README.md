# EPICS in a container (v3)

Container image [`prjemian/synapps`](https://hub.docker.com/r/prjemian/synapps)
providing [EPICS base](https://epics.anl.gov/base/),
[synApps](https://www.aps.anl.gov/BCDA/synApps), and [Area
Detector](https://areadetector.github.io/areaDetector/) software as ready-to-run
IOCs (servers) for **development, simulation, testing, and training**.

> **v3 is under active redevelopment.** The recipes are being rebuilt from
> scratch to be smaller, easier to maintain, portable across container
> runtimes and host architectures, and driven by a declarative
> [`compose.yaml`](./compose.yaml). See [`docs/v3.md`](./docs/v3.md) for the
> plan and [`docs/v3_strategy.md`](./docs/v3_strategy.md) for the approach.
> The previous, published implementation is archived under
> [`v2.0/`](./v2.0/) (and earlier lines under `v1.0/`, `v1.1/`).

tag | release | image | downloads | license
--- | --- | --- | --- | ---
[![tag](https://img.shields.io/github/tag/prjemian/epics-docker.svg)](https://github.com/prjemian/epics-docker/tags) | [![release](https://img.shields.io/github/release/prjemian/epics-docker.svg)](https://github.com/prjemian/epics-docker/releases) | [![image](https://img.shields.io/docker/v/prjemian/synapps)](https://hub.docker.com/r/prjemian/synapps) | [![pulls](https://img.shields.io/docker/pulls/prjemian/synapps.svg)](https://hub.docker.com/r/prjemian/synapps) | [![license: EPICS](https://img.shields.io/badge/license-EPICS-blue.svg)](./LICENSE)

## What this repository provides

- A multi-stage recipe ([`Dockerfile`](./Dockerfile)) that builds a small
  runtime image containing a full EPICS stack.
- Ready-to-run IOC **personas** (e.g. `softioc`; synApps and area-detector
  personas to follow), selected at container start with a user-chosen PV
  prefix.
- A declarative run contract ([`compose.yaml`](./compose.yaml)) that works
  with both **docker** and **podman**, on Linux, macOS, Windows, and Synology.
- IOCs supervised by [`procServ`](https://github.com/ralphlange/procServ)
  (no `screen`), so they behave well under rootless podman and in CI.
- A single source of truth for component versions
  ([`versions.env`](./versions.env)).

This repository provides EPICS **servers**. EPICS **client** software is out
of scope.

## Quick start

Build the image and run the `softioc` persona:

```bash
make build                      # build the runtime image
make run PREFIX=demo:           # start softIoc under procServ (host networking)
caget demo:UPTIME               # (with an EPICS client) read a PV
```

Or with compose (choose a networking profile):

```bash
docker compose --profile host  up     # Linux / CI: host sees PVs directly
docker compose --profile ports up     # Docker Desktop / Windows / macOS / Synology
```

**Podman:** the Makefile auto-detects podman (including the `podman-docker`
wrapper) and adds `--no-hosts` automatically, so `make build` works as-is.
To override, set `BUILD_FLAGS=` / `RUN_FLAGS=` explicitly. Run `make vars` to
see the detected engine and flags.

## Documentation

**Getting started**

document | contents
--- | ---
[quick start](./docs/quickstart.md) | Run an IOC; per-audience (workstation, CI, client dev, simulation)
[configuration](./docs/configuration.md) | Environment variables, networking profiles, console, volumes
[maintainer guide](./docs/maintainer.md) | Build, upgrade component versions, extend (add features/cameras)

**Personas (the IOCs provided)**

document | contents
--- | ---
[softioc](./docs/softioc.md) | EPICS base softIoc (minimal; default persona)
[xxx](./docs/xxx.md) | As-supplied synApps template IOC
[gp](./docs/gp.md) | Customized synApps IOC (runtime prefix) — features and how to run it
[area-detector cameras](./docs/area_detector.md) | The camera personas + the adsim vs adcsim distinction
[adsim](./docs/adsim.md) | ADSimDetector — simulated 2D image camera
[adcsim](./docs/adcsim.md) | ADCSimDetector — simulated ADC/waveform digitizer (not a camera)
[adurl](./docs/adurl.md) | ADURL — area detector fed images from a URL
[adpva](./docs/adpva.md) | pvaDriver — area detector fed images over pvAccess

**Design & background**

document | contents
--- | ---
[synApps modules](./docs/synapps_modules.md) | Which synApps modules are included/excluded, and why
[v3 plan](./docs/v3.md) | The maintainer's plan and goals for v3
[requirements & goals](./docs/v3_requirements.md) | Audiences, functional and quality goals, constraints, non-goals
[implementation strategy](./docs/v3_strategy.md) | Architecture and decisions for the rebuild
[v2 -> v3 transition](./docs/v3_transition.md) | How v3 lands without breaking existing tooling (apstools, iocmgr.sh)
[v2.0 build phases](./docs/v2_build_phases.md) | Reconstructed reference for the prior recipe

## Authors

- Pete Jemian

## Acknowledgements

- Contributors
  - Chen Zhang
  - Jeff Hoffman
  - Quan Zhou

- moved here from [virtualbeamline](https://github.com/prjemian/virtualbeamline),
  a fork of [KedoKudo/virtualbeamline](https://github.com/KedoKudo/virtualbeamline).
