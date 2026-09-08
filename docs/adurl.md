# adurl: custom ADURL IOC

The **`adurl`** persona is a customized
[ADURL](https://github.com/areaDetector/ADURL) IOC — an area detector that
reads its images **from a URL** instead of a physical camera. Useful for
feeding known test images into the areaDetector pipeline (no camera hardware).

Runtime-settable PV prefix (default `adurl:`); no recompilation to change it.

## Features

~7200 PVs under your chosen prefix (`$(PREFIX)`):

feature | what you get
--- | ---
**URL image source** | `$(PREFIX)cam1:` with a URL/file list; the driver fetches images from the configured URL(s). `Manufacturer_RBV = "URL Driver"`.
**Image + plugins** | `image1:`, PVA server (`Pva1:`), file writers (HDF5/TIFF/JPEG/netCDF), ROI/stats/etc.
**autosave** | settings saved/restored.

Reading images from a URL uses GraphicsMagick (included in the image).

## Quick start

```bash
docker run -d --rm --name iocadurl --net=host \
    -e IOC=adurl -e PREFIX=adurl: \
    prjemian/synapps:latest

caget adurl:cam1:Acquire_RBV
caget adurl:cam1:Manufacturer_RBV      # -> URL Driver
```

Point it at an image URL (set the driver's file name to a URL), then acquire.

> On rootless podman add `--no-hosts`. Use a unique prefix per IOC.

## Using compose

```bash
ADURL_PREFIX=adurl docker compose --profile host  up -d adurl-host
ADURL_PREFIX=adurl docker compose --profile ports up -d adurl-ports
```

## See also

- [area-detector overview](./area_detector.md)
- [adsim](./adsim.md), [adpva](./adpva.md)
