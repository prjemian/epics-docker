# Area-detector (camera) personas

The image provides several hardware-free
[areaDetector](https://areadetector.github.io/areaDetector/) IOC personas,
selected at container start with `-e IOC=<persona>` and a runtime `PREFIX`.
All are built from a shared `adcam` framework and share the same plugin chain
(image, ROI, statistics, HDF5/TIFF/JPEG/netCDF writers, PVA server; NeXus
omitted) and autosave.

## Which detector? (read this first)

Two of the personas have **subtly similar names but are completely different
detector types** — do not confuse them:

persona | driver | detector type | data | key PVs
--- | --- | --- | --- | ---
[`adsim`](./adsim.md) | ADSim**Detector** | **2D area / image camera** | image frames | `$(PREFIX)cam1:`, `image1:`
[`adcsim`](./adcsim.md) | AD**C**SimDetector | **ADC / waveform digitizer** | 1D signal channels | `$(PREFIX)det1:`, `det1:1:` .. `det1:8:`

- **ADSimDetector** simulates a **camera** (CCD/CMOS): it produces 2D images.
  Use it to simulate imaging detectors and the image pipeline. PV suffix
  `cam1:` (e.g. `cam1:Acquire`, `cam1:Manufacturer_RBV = "Simulated detector"`).
- **ADCSimDetector** (note the **C**) simulates a **multi-channel ADC /
  waveform digitizer**: eight 1D channels of simulated signals (sine, square,
  sawtooth, random, ...). It has **no `cam1:` camera**. PV suffix `det1:`
  with channels `det1:1:` .. `det1:8:`.

The single letter `C` is the only difference in the name but the detectors are
unrelated: **image camera** vs **waveform digitizer**.

## All camera personas

persona | driver | what it simulates | needs
--- | --- | --- | ---
[`adsim`](./adsim.md) | ADSimDetector | 2D image camera | nothing (fully simulated)
[`adcsim`](./adcsim.md) | ADCSimDetector | 8-channel waveform digitizer | nothing (fully simulated)
[`adurl`](./adurl.md) | ADURL | area camera fed images from a URL | nothing (fetches from a URL)
[`adpva`](./adpva.md) | pvaDriver | area camera fed images over pvAccess | a PVA image source (e.g. another AD IOC's `Pva1:`)

All use a **runtime-settable PV prefix** (no recompile) and are supervised by
procServ. See each persona's page for details and how to run it.

## Not included

- **ffmpegServer** (MJPEG/stream plugin) and **ADUVC** (USB Video Class
  camera) are intentionally not built: they do not fit the simulation + CI
  objectives (heavy vendored ffmpeg build; real USB hardware). They can be
  added individually later if a specific need arises.

## See also

- [gp](./gp.md) — customized synApps IOC
- [v2 -> v3 transition](./v3_transition.md)
