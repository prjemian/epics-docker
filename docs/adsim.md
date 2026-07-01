# adsim: custom ADSimDetector IOC

The **`adsim`** persona is a customized
[ADSimDetector](https://areadetector.github.io/areaDetector/) IOC — a
**simulated area detector** (no camera hardware) for development, testing,
training, and simulation. It is the area-detector counterpart of the
[`gp`](./gp.md) IOC, and provides the detector used by APS Bluesky/ophyd test
suites (e.g. `apstools`, which checks `ad:cam1:Acquire_RBV`).

Like `gp`, `adsim` uses a **runtime-settable PV prefix** (default `adsim:`) —
no recompilation to change it.

## Features

~7400 PVs under your chosen prefix (`$(PREFIX)`):

feature | what you get
--- | ---
**Simulated camera** | one camera `$(PREFIX)cam1:` (1024x1024, `Manufacturer=Simulated detector`). No hardware. (The stock 2nd camera SIM2/cam2 is disabled.)
**Image access** | `$(PREFIX)image1:` (NDStdArrays) and a **PVA server** (`$(PREFIX)Pva1:`) for pvAccess image delivery.
**File writers** | HDF5 (`HDF1:`), TIFF (`TIFF1:`), JPEG (`JPEG1:`), netCDF (`netCDF1:`), and Magick (`FileMagick`). NeXus is intentionally omitted (superseded by HDF5).
**Processing plugins** | ROI (`ROI1:`), statistics (`Stats1:`), color convert (`CC1:`), process (`Proc1:`), overlay (`Over1:`), FFT (`FFT1:`), and more — the standard ADCore plugin chain.
**autosave** | detector settings saved/restored.

The PV **prefix is chosen at run time** — the same image serves `adsim:`,
`ad:`, `mydet:`, etc.

## Quick start

```bash
docker run -d --rm --name iocadsim --net=host \
    -e IOC=adsim -e PREFIX=adsim: \
    prjemian/synapps:latest
```

Check it (with an EPICS client on the same host):

```bash
caget adsim:cam1:Acquire_RBV
caget adsim:cam1:Manufacturer_RBV
# acquire one image
caput adsim:cam1:Acquire 1
```

> On rootless podman add `--no-hosts`.

## Choosing the PV prefix (no rebuild)

The prefix is a run-time choice; run several detectors at once with distinct
prefixes and container names:

```bash
docker run -d --rm --name iocair  --net=host -e IOC=adsim -e PREFIX=air:  prjemian/synapps:latest
docker run -d --rm --name iocland --net=host -e IOC=adsim -e PREFIX=land: prjemian/synapps:latest
```

> **Avoid duplicate PVs on the network:** give each detector a unique prefix.

### Migrating from v2

v2 exposed this detector as persona `ADSIM` with prefix `ad:` (container
`iocad`). For the same PV names in v3, set `PREFIX=ad:`. The camera suffix
`cam1:` is unchanged, so `ad:cam1:Acquire_RBV` still resolves. See
[the transition guide](./v3_transition.md).

## Using compose (docker or podman)

[`compose.yaml`](../compose.yaml) provides `adsim` services in two networking
profiles:

```bash
# Linux / CI: host networking
ADSIM_PREFIX=adsim docker compose --profile host up -d adsim-host

# Docker Desktop / Windows / macOS / Synology: ports mapped
ADSIM_PREFIX=adsim docker compose --profile ports up -d adsim-ports
```

Set `ADSIM_PREFIX` (no trailing colon) to choose the prefix; the container is
named `ioc<ADSIM_PREFIX>`.

## Viewing images

Detector images are available via:
- **Channel Access array** `$(PREFIX)image1:ArrayData`
- **pvAccess** `$(PREFIX)Pva1:` (start an image viewer that supports PVA)

Display tools (MEDM/caQtDM) are not in this server image; the collected
screens (`/opt/epics/screens`, see [gp docs](./gp.md#display-screens)) include
the ADSimDetector screens, launched with `-macro "P=<prefix>,R=cam1:"`.

## Console & inside the container

```bash
telnet localhost 2048          # procServ console (Ctrl-] then quit to detach)
docker exec iocadsim caget adsim:cam1:Acquire_RBV
```

On `docker exec` you land in `/home`, with an `iocadsim` link to the IOC boot
directory and `build-logs/build-adsim.log`.

## Tuning

env / build-arg | effect
--- | ---
`PREFIX` | PV prefix at run time (default `adsim:`).
`IOC_CONSOLE_PORT` | procServ console (telnet) port (default `2048`).

## See also

- [gp](./gp.md) — customized synApps IOC
- [xxx](./xxx.md) — as-supplied synApps template IOC
- [v2 -> v3 transition](./v3_transition.md)
