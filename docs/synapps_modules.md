# synApps module selection (v3)

The v3 image assembles synApps with the standard
[`assemble_synApps.sh`](https://github.com/EPICS-synApps/support) installer
(pinned to `SYNAPPS_VERSION` in [`versions.env`](../versions.env)), then
**excludes** the modules listed below. Excluded modules have their tag
assignment emptied by [`resources/synapps_prepare.sh`](../resources/synapps_prepare.sh),
which the assembler treats as "skip this module".

**Selection principle:** exclude modules that are **hardware-specific**
(drivers for physical devices we cannot exercise in a container) or
**OS/platform-specific** in ways that do not apply to our Linux build.
Everything else is kept at the release's own module tags (we do not re-pin
kept modules; upgrading synApps is a one-line `SYNAPPS_VERSION` bump).

This exclusion set matches the selection used by the v1.1 and v2.0 images.

## Excluded modules

module | reason
--- | ---
`ALLENBRADLEY` | Hardware: Allen-Bradley PLC I/O.
`CAMAC` | Hardware: CAMAC crate/serial-highway I/O.
`DAC128V` | Hardware: IP-DAC128V industry-pack DAC.
`DELAYGEN` | Hardware: delay/pulse generators (e.g. DG535).
`DXP` | Hardware: XIA DXP multichannel analyzers.
`DXPSITORO` | Hardware: XIA SITORO/FalconX digital pulse processors.
`ETHERIP` | Hardware: EtherNet/IP to Allen-Bradley PLCs.
`GALIL` | Hardware: Galil motion controllers.
`IP330` | Hardware: IP330 industry-pack ADC.
`IPUNIDIG` | Hardware: IP-Unidig industry-pack digital I/O.
`LOVE` | Hardware: Love controllers (serial).
`MEASCOMP` | Hardware: Measurement Computing DAQ (also pulls the uldaq library).
`OPCUA` | Hardware/integration: OPC-UA servers; also needs an external SDK.
`QUADEM` | Hardware: quad electrometers / beam-position monitors.
`SOFTGLUE` | Hardware: FPGA "soft glue" digital logic (industry-pack).
`SOFTGLUEZYNQ` | Hardware: soft glue on Zynq FPGA carriers.
`ULDAQ` | Hardware support library for MEASCOMP (excluded with it).
`VAC` | Hardware: vacuum gauge/pump controllers (serial).
`VME` | Hardware/OS: VME bus support (not applicable to a container host).
`YOKOGAWA_DAS` | Hardware: Yokogawa data-acquisition units.
`XSPRESS3` | Hardware: Quantum Detectors Xspress3 readout.

## Kept modules

Kept at the release's default tags (no re-pinning):

`asyn`, `autosave`, `busy`, `calc`, `caputRecorder`, `iocStats` (DEVIOCSTATS),
`ip`, `ipac`, `lua`, `mca`, `modbus`, `motor`, `optics`, `scaler`, `sscan`,
`std`, `StreamDevice`, `sequencer` (SNCSEQ), `xxx`, and `areaDetector`.

Notes:
- `mca`, `modbus`, `ip`, `ipac`, `lua` are kept (as in v1.1/v2.0): they are
  lightweight and useful for simulation/soft records even though some can also
  drive hardware.
- `areaDetector` is included (as in v2.0) to provide the simulated detector
  personas. v1.1 excluded it because AD was a separate image in that layered
  line.
- The `SUPPORT` meta-module tag is left at whatever the chosen release ships
  (the R6-3 assembler defaults it to `R6-2-1`); we do not override it, so the
  build framework matches what upstream tested.

## Adding hardware modules for a specific need

To include an excluded module (e.g. for a hardware-connected use case), remove
it from `EXCLUDE_MODULES` in `resources/synapps_prepare.sh`. It will then build
at the release's default tag. Additional build/runtime dependencies may be
required.
