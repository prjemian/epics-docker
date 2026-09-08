# adpva: custom pvaDriver IOC

The **`adpva`** persona is a customized
[pvaDriver](https://github.com/areaDetector/pvaDriver) IOC — an area detector
that receives its images over **pvAccess (PVA)** from another NTNDArray
source, rather than from a physical camera.

A common use: point `adpva` at another AD IOC's PVA image channel (e.g. an
`adsim` IOC's `$(PREFIX)Pva1:` output) to exercise the PVA image path.

Runtime-settable PV prefix (default `adpva:`); no recompilation to change it.

## Features

~7200 PVs under your chosen prefix (`$(PREFIX)`):

feature | what you get
--- | ---
**PVA image source** | `$(PREFIX)cam1:` consuming an NTNDArray from a PVA channel. `Manufacturer_RBV = "PVAccess driver"`. Set the source channel via the driver's `PvName`.
**Image + plugins** | `image1:`, PVA server (`Pva1:`), file writers, ROI/stats/etc.
**autosave** | settings saved/restored.

## Quick start

```bash
docker run -d --rm --name iocadpva --net=host \
    -e IOC=adpva -e PREFIX=adpva: \
    prjemian/synapps:latest

caget adpva:cam1:Acquire_RBV
caget adpva:cam1:Manufacturer_RBV      # -> PVAccess driver
```

Example: relay an `adsim` detector's PVA images:

```bash
# start an adsim detector that serves PVA images on adsim:Pva1:
docker run -d --rm --name iocadsim --net=host -e IOC=adsim -e PREFIX=adsim: prjemian/synapps:latest
# point adpva at that PVA channel (set cam1:PvName to the source)
caput adpva:cam1:PvName adsim:Pva1:Image
```

> On rootless podman add `--no-hosts`. Use a unique prefix per IOC.

## Using compose

```bash
ADPVA_PREFIX=adpva docker compose --profile host  up -d adpva-host
ADPVA_PREFIX=adpva docker compose --profile ports up -d adpva-ports
```

## See also

- [area-detector overview](./area_detector.md)
- [adsim](./adsim.md) — a PVA image source to relay
