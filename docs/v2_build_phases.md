# v2.0 build phases (reconstructed for reference)

Status: **reference only.** This document reconstructs the sequence of build
phases used by the archived v2.0 recipe (`v2.0/Dockerfile` plus the driver
scripts in `v2.0/resources/`) and, for each phase, infers **what that step
was trying to accomplish**. It is a record of the *existing* design, gleaned
from the recipe; it is not a plan and prescribes nothing for v3.

The original intent is also stated in `v2.0/docs/.initial_plans.md`:

> - image provides the OS (as a sysAdmin would maintain it)
> - All IOCs possible from this one, single image
> - EPICS components built by scripts (base, synApps, area detector, screens,
>   custom IOCs with user-specified prefixes)
> - scripts are copied to the image as each component is built
> - scripts could each be run outside the image to build locally
> - one image to reduce the number of downloads in CI processes

The phases below build, in order, from a bare OS image up to an image that can
run a full synApps + areaDetector IOC.

---

## Phase 0 — Base OS image and shell environment

Source: `v2.0/Dockerfile` (top section).

- Start `FROM debian:stable-slim`, run as `root`, default `CMD ["/bin/bash"]`.
- Define the environment skeleton: `APP_ROOT=/opt`, `RESOURCES=/opt/resources`,
  `LOG_DIR=/opt/logs`, default `PREFIX=ioc:`, `IMAGE_VERSION`.
- Create `~/.bashrc` / `~/.bash_aliases`, `~/bin`, and the log dir; set
  convenience aliases, editor, prompt trimming, and `PATH`.

**Goal:** establish a predictable, slim Debian base with a known directory
layout and a shell environment that every later phase can rely on. The
`.bash_aliases` file becomes the running "build state" — each subsequent
phase appends the variables it defines so later phases (and the eventual
runtime) inherit them.

## Phase 1 — OS packages (sysAdmin layer)

Source: `v2.0/Dockerfile` ("update OS" block).

- `apt-get update/upgrade` and install the toolchain and libraries needed to
  *build* EPICS from source: `build-essential`, `git`, `re2c`, readline,
  libusb, libnet, libpcap, X11/Xext dev headers, plus runtime conveniences
  (`screen`, `vim`, `nano`, `procps`, `wget`, `less`).
- Clean apt lists afterward.

**Goal:** provide everything required to compile EPICS base, synApps, and
areaDetector — "the OS as a sysAdmin would maintain it" — in one OS layer,
then trim caches to limit image growth.

## Phase 2 — Build EPICS base

Source: `v2.0/resources/epics_base.sh`.

- Pin `BASE_VERSION` (7.0.5 in the archived recipe), download the base
  tarball, unpack under `/opt`, symlink `/opt/base`.
- Detect `EPICS_HOST_ARCH`, extend `PATH`, record all of this into
  `.bash_aliases`.
- `make all` (with `-fPIC`), then `make clean`.

**Goal:** produce a working EPICS base toolkit at a known, stable location
(`/opt/base`, arch path `bin/${EPICS_HOST_ARCH}`) that all higher EPICS
software builds against. `make clean` after build is an early size-control
measure (drop intermediate objects, keep products).

## Phase 3 — Install shared script tools

Source: `v2.0/Dockerfile` ("script tools"); copies
`copy_screens.sh`, `modify_adl_in_ui_files.sh`, `tarcopy.sh`.

**Goal:** stage the small, reusable helpers that later phases call — copying
trees (`tarcopy.sh`), gathering operator-interface screens (`copy_screens.sh`),
and rewriting screen references (`modify_adl_in_ui_files.sh`). Placed once so
both the GP and ADSIM phases can reuse them.

## Phase 4 — Build EPICS synApps

Source: `v2.0/resources/epics_synapps.sh` and `edit_assemble_synApps.sh`.

- Pin synApps release (`HASH=R6-2-1`) and module hashes (motor `R7-2-2`,
  caputRecorder `master`); set `SYNAPPS`, `SUPPORT`, `IOCS_DIR`.
- Download upstream `assemble_synApps.sh`, then edit it
  (`edit_assemble_synApps.sh`) to select/deselect modules and apply local
  choices.
- Run the assembler, then build everything: `make release rebuild` across
  `support`; set `TIRPC=YES` for asyn.
- Record discovered module paths (`AD`, `ASYN`, `MOTOR`, `OPTICS`, `XXX`,
  `IOCXXX`) into `.bash_aliases`.
- Collect operator screens into `${SUPPORT}/screens` and normalize them.
- Build the stock `XXX` template IOC.

**Goal:** assemble and compile the full synApps support tree (including
areaDetector and the modules a beamline IOC needs), capturing both the stock
software and the path metadata later phases depend on. This is the heart of
"a full EPICS system in one image."

## Phase 5 — Create the custom GP IOC (general-purpose synApps IOC)

Source: `v2.0/resources/custom_gp_ioc.sh`, which orchestrates these sub-steps:

| Sub-step (`v2.0/resources/...`) | Goal of the sub-step |
|---|---|
| `gp_copy_IOC.sh` | Clone the stock `XXX` template into a new `iocgp`, strip VCS/CI cruft, clean — start a custom IOC from the standard template. |
| `gp_prefix.sh` | Re-key the IOC from `xxx` to `gp`, and make the runtime PV `PREFIX` overridable at container start (default `gp:`). Enables user-chosen prefixes. |
| `gp_iocStats.sh` | Fix an iocStats DB detail (`EPICS_TIMEZONE` -> `EPICS_TZ`) so IOC-admin records work. |
| `gp_make.sh` | Compile the freshly customized IOC. |
| `gp_motors.sh` | Configure simulated soft motors (e.g. 56 axes, wide limits) instead of real hardware — beamline-like motion without hardware. |
| `gp_optics.sh` | Add optics support: monochromator, slit pairs wired to the simulated motors. |
| `gp_std.sh` | Add "std" support: soft scalers with pre-assigned channel names. |
| `gp_add_general_purpose.sh` | Load the `general_purpose.db` set of free/scratch PVs (the `gp:gp:*` PVs used as test signals). |
| `gp_alive.sh` | Disable ALIVE heartbeat support (not wanted in this context). |
| `gp_build_gp_sh.sh` | Generate the in-container `~/bin/gp.sh` starter and a screen-publishing helper. |
| `gp_install_screens.sh` | Gather, normalize, and re-prefix operator screens (adl/ui) for the GP IOC. |

**Goal of the phase:** turn the stock XXX template into a ready-to-run,
hardware-free "general purpose" beamline IOC with simulated motors, optics,
scalers, and a pool of scratch PVs — the persona consumers start as `GP`.

## Phase 6 — Create the custom ADSimDetector IOC

Source: `v2.0/resources/custom_adsim_ioc.sh`, orchestrating:

| Sub-step (`v2.0/resources/...`) | Goal of the sub-step |
|---|---|
| `adsim_copy_IOC.sh` | Copy the stock `simDetectorIOC` into a custom `iocadsim`. |
| `adsim_IOC_run_script.sh` | Provide the IOC boot/run script. |
| `adsim_prefix.sh` | Make the PV `PREFIX` user-overridable at container start. |
| `adsim_build_adsim_sh.sh` | Generate the in-container `adsim.sh` starter. |
| `adsim_st_base.sh` | Establish the base `st.cmd` startup for the sim detector. |
| `adsim_plugins.sh` | Enable areaDetector plugins (image/stats/file, etc.). |
| `adsim_autosave.sh` | Configure autosave of detector settings. |
| `adsim_install_screens.sh` | Install and normalize the detector operator screens. |

**Goal of the phase:** produce a ready-to-run simulated area-detector IOC
(no camera hardware) with the common plugins, autosave, and screens — the
persona consumers start as `ADSIM`.

## Phase 7 — (Planned, not shipped) additional area-detector IOCs

Source: commented-out blocks at the bottom of `v2.0/Dockerfile`.

- `custom_adpva_ioc.sh` (pvaDriver) and `custom_adurl_ioc.sh` (ADURL) were
  scaffolded but **commented out** — never built into the v2.0 image.

**Goal (intended):** broaden the set of hardware-free detector IOCs beyond
ADSimDetector. This intent is carried forward as a v3 goal (see
`docs/v3_requirements.md`, G4).

## Phase 8 — (TODO) in-container IOC lifecycle

Source: trailing `# TODO: add support to start/stop IOCs in containers` in
`v2.0/Dockerfile`.

In practice, lifecycle management lived **outside** the image, in the
host-side `v2.0/resources/iocmgr.sh` (start/stop/restart/console/status,
caqtdm/medm), which runs one IOC per container, passes the prefix at boot,
names the container `ioc${PRE}`, uses host networking, and shares the
container `/tmp` to the host.

**Goal:** give operators a single command to run and manage the IOC personas
the image provides. The intent to also handle lifecycle *inside* the image was
noted but not completed.

---

## Cross-cutting goals visible across the phases

- **One image, all IOCs** — every phase adds to a single image so CI pulls
  once (initial plans, explicit).
- **Build by scripts, copied as each component is built** — each phase is a
  script staged into `${RESOURCES}`, intended to also be runnable outside the
  image for local builds/debugging.
- **`.bash_aliases` as accumulating build/runtime state** — phases append the
  variables they define so later phases and the running container inherit a
  consistent environment.
- **Stock first, then customize** — base and synApps are built stock; the GP
  and ADSIM phases layer local customizations on top of the stock templates.
- **User-chosen PV prefix** — both custom IOCs are made prefix-overridable at
  container start.
- **Incidental size control** — `make clean` and apt-cache cleanup appear, but
  size reduction was not a structuring principle of the phases (a v3 goal).
