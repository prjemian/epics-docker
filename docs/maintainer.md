# Maintainer guide

How to build, upgrade, and extend the image.

## Single source of truth: versions.env

All externally-pinned versions live in [`versions.env`](../versions.env).
Upgrading a component is a one-file edit; the `Makefile` passes each value to
the build as a `--build-arg`.

key | what it pins
--- | ---
`IMAGE_VERSION` | this project's image recipe version
`DEBIAN_TAG` | base OS image tag
`EPICS_BASE_VERSION` | EPICS base release
`SYNAPPS_VERSION` | the `EPICS-synApps/support` assembler release
`SYNAPPS_OVERRIDE_MOTOR` | a documented per-module version exception (see below)
`AD_DRIVERS` | extra areaDetector drivers to enable + build
`MOTOR_SREV` | steps/revolution for the gp simulated motors
`PROCSERV_VERSION` | reference for the procServ package

## Build & test

```bash
make build                      # build the runtime image
make test                       # build + smoke-test all personas
make vars                       # show resolved versions / build args
```

Rootless podman (e.g. the APS build host) needs `--no-hosts` to avoid
`failed to create new hosts file: /etc/hosts: permission denied`. The Makefile
**auto-detects podman** (including the `podman-docker` wrapper, where `docker`
is really podman) and adds `--no-hosts` to build/run automatically, so the
plain commands above work. Override with `BUILD_FLAGS=`/`RUN_FLAGS=` if needed;
`make vars` shows the detected engine and flags.

Targets: `build`, `build-devel` (keeps toolchain/sources), `run`, `console`,
`shell`, `test`, `clean`.

## How component versions flow

- **EPICS base:** `EPICS_BASE_VERSION` -> downloaded + built in `epics-build`.
- **synApps:** `SYNAPPS_VERSION` selects which `assemble_synApps.sh` is
  downloaded. We do **not** re-pin individual module tags — kept modules
  inherit the release's tested tag set. Upgrading synApps is a one-line bump.
  See [synApps modules](./synapps_modules.md).
- **Module exceptions:** list `SYNAPPS_OVERRIDE_<MODULE>=<TAG>` only with a
  documented reason. The current one:
  - `SYNAPPS_OVERRIDE_MOTOR=R7-3-1` — synApps R6-3 pins motor R7-2-2, which
    fails to compile on modern base + GCC 12 (`epicsShareFunc` /
    missing `<shareLib.h>`). Remove this override when a synApps release ships
    a fixed motor.

## Upgrading

1. Edit the relevant value(s) in `versions.env`.
2. `make build BUILD_FLAGS=--no-hosts` (on rootless podman).
3. `make test RUN_FLAGS=--no-hosts` — all personas must pass.
4. Review `/opt/build-logs/*.log` in the image if anything fails.
5. Update version references in docs where stated.

> When bumping `SYNAPPS_VERSION`, re-check whether the `MOTOR` override is
> still needed (it may become unnecessary once upstream ships a fixed motor),
> and whether the excluded/kept module set in `synapps_prepare.sh` is still
> right.

## Build architecture (multi-stage)

```
os-runtime  -> os-build -> epics-build -> base-epics
                        \-> synapps-build -> gp-build -> adcam-build
                                                              |
                                          base-synapps <------/  (copies the
                                          slim, pruned support tree)
```

- Builder stages compile; the **runtime** image copies only products.
- The support tree is **pruned** (`.git`, `*.a`, `*.o`, `O.*`) in the builder
  before the runtime copy, so the image ships slim (see
  `resources/prune_support.sh` and `docs/v3_strategy.md`).
- **Build logs are retained** in `/opt/build-logs` for diagnostics.

## Adding a synApps feature to the gp IOC

gp customizations are shipped overlay files under `resources/gp/`, applied by
`gp_build.sh` (no in-place editing of upstream files). Add a sub-step script
and call it from `gp_build.sh`.

## Adding an areaDetector camera

Cameras use the `resources/adcam/` framework:

1. Add the driver to `AD_DRIVERS` in `versions.env` (enables it in AD
   `RELEASE.local`, fetches its submodule, builds it).
2. Add a profile `resources/adcam/profiles/<name>.env` (name, default prefix,
   the example IOC boot dir, stock prefix, app binary).
3. Add the persona symlink in the `Dockerfile` (`<name>.sh -> adcam.sh`) and
   the smoke-test entry.

`adcam_build.sh` copies the driver's example IOC and customizes a copy
(runtime prefix, one camera, plugins), leaving upstream files pristine.

> Not every driver fits: **ffmpegServer** (heavy vendored ffmpeg build) and
> **ADUVC** (needs real USB hardware) are intentionally excluded — they do not
> serve the simulation + CI goals.

## Documentation

Docs live in `docs/` and are versioned with the code. Keep component versions
in prose to a minimum; prefer pointing at `versions.env`.

## See also

- [implementation strategy](./v3_strategy.md)
- [synApps modules](./synapps_modules.md)
- [configuration](./configuration.md)
