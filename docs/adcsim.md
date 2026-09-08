# adcsim: custom ADCSimDetector IOC

The **`adcsim`** persona is a customized
[ADCSimDetector](https://github.com/areaDetector/ADCSimDetector) IOC — a
simulated **multi-channel ADC / waveform digitizer** (no hardware).

> **Not the same as [`adsim`](./adsim.md).** Despite the one-letter name
> difference, `adcsim` (AD**C**SimDetector) is a **waveform/ADC digitizer**
> (eight 1D signal channels, `det1:`), **not** a 2D image camera. `adsim`
> (ADSimDetector) is the image camera (`cam1:`). See the
> [area-detector overview](./area_detector.md).

Like the other cameras, `adcsim` uses a **runtime-settable PV prefix**
(default `adcsim:`) — no recompilation to change it.

## Features

~8400 PVs under your chosen prefix (`$(PREFIX)`):

feature | what you get
--- | ---
**Waveform digitizer** | `$(PREFIX)det1:` with **8 channels** `det1:1:` .. `det1:8:`, each simulating a 1D signal (sine, cosine, square, sawtooth, random, ...). Per-channel controls (`Frequency`, `Amplitude`, `Offset`, `Noise`, ...).
**Acquisition** | `det1:Acquire`, `det1:AcquireTime`, `det1:TimeStep`, elapsed-time readbacks.
**Plugins** | the standard ADCore plugin chain (ROI, stats, file writers, PVA server) operating on the digitized waveforms.
**autosave** | settings saved/restored.

There is **no `cam1:`** — this is a digitizer, not a camera.

## Quick start

```bash
docker run -d --rm --name iocadcsim --net=host \
    -e IOC=adcsim -e PREFIX=adcsim: \
    prjemian/synapps:latest
```

Check it:

```bash
caget adcsim:det1:TimeStamp_RBV
caget adcsim:det1:1:Frequency
caput adcsim:det1:Acquire 1
```

> On rootless podman add `--no-hosts`. Give each IOC a unique prefix to avoid
> duplicate PVs on the network.

## Using compose

```bash
ADCSIM_PREFIX=adcsim docker compose --profile host  up -d adcsim-host
ADCSIM_PREFIX=adcsim docker compose --profile ports up -d adcsim-ports
```

## See also

- [area-detector overview](./area_detector.md) — the camera family, and the
  adsim vs adcsim distinction
- [adsim](./adsim.md) — the 2D image camera
