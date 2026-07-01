# GP: general-purpose synApps IOC

The **`gp`** persona is a customized [synApps](https://www.aps.anl.gov/BCDA/synApps)
IOC built from the standard `xxx` template with a set of ready-to-use,
hardware-free features. It is the workhorse IOC for **simulation, testing,
training, and EPICS client development** — the same "GP" IOC used by APS
Bluesky/ophyd test suites (e.g. `apstools`).

Unlike the [as-supplied `xxx`](./xxx.md) persona, `gp` uses a **runtime-settable
PV prefix** (default `gp:`) — no recompilation needed to change it.

## Features

The `gp` IOC serves ~2000 PVs, all under your chosen prefix (`$(PREFIX)`):

feature | what you get
--- | ---
**General-purpose PVs** | 20 each of scratch records under `$(PREFIX)gp:` — `float1..20`, `int1..20`, `bit1..20`, `text1..20`, `longtext1..20`, `array1..20`. Handy signals for tests and demos.
**Bluesky scan_id** | `$(PREFIX)bluesky_scan_id` — a dedicated `longout` for the Bluesky RunEngine's `scan_id` (so it need not consume a general-purpose integer).
**56 simulated motors** | `$(PREFIX)m1` .. `$(PREFIX)m56` (soft/sim, no hardware). Wide travel limits; `SREV=8000` (5-digit precision, good for crystallography/mono simulation). Many carry descriptive names — see [motor assignments](#motor-assignments). Includes `allstop`.
**Optics** | Kohzu monochromator, two slit pairs (`Slit1V/1H` via `2slit.db`, `Slit2V/2H` via `2slit_soft.vdb`), an optical table, a coarse/fine stage, and 4-circle diffractometer orientation-matrix support with a crystal-lattice database.
**Scanning (sscan)** | `scan1..scan4`, `scanH`, `saveData`, and `scanProgress` — the synApps step-scan engine used by many acquisition/testing workflows (e.g. Bluesky/ophyd tests).
**userCalcs & friends** | 20 channels each of `userCalc`, `userCalcOut`, `userStringCalc`, `userArrayCalc`, `userAve`, `userStringSeq` — general computation/soft-record building blocks.
**Counting / std** | Three soft scalers (`scaler1..3`, 64 channels each) with named channels — see [scaler channels](#scaler-channels); fb_epid feedback; 4-step database; ramp/tweak; software timer; PV history.
**Automation** | `caputRecorder` (record/replay caput sequences), `sseq` (string sequence), `busy` records (2), `configMenu`, autosave & restore, interpolation.
**Soft MCA** | Two simulated multichannel analyzers, `$(PREFIX)mca1` and `$(PREFIX)mca2` (2048 channels each, no hardware) — for spectroscopy/acquisition simulation.
**lua** | lua interpreter PVs (`$(PREFIX)interp`) and lua-script support from the synApps lua module.
**IOC admin** | iocStats / iocAdminSoft records (uptime, load, ...); `$(PREFIX)UPTIME` for a quick liveness check.

The PV **prefix is chosen at run time** — the same image serves `gp:`,
`ioc1:`, `mytest:`, etc., by setting one environment variable.

## Quick start

Start a GP IOC with prefix `gp:`:

```bash
docker run -d --rm --name iocgp --net=host \
    -e IOC=gp -e PREFIX=gp: \
    prjemian/synapps:latest
```

Check it (with any EPICS client on the same host):

```bash
caget gp:UPTIME
caget gp:gp:float1
caget gp:m1.RBV
```

> Use **podman** the same way; on rootless podman add `--no-hosts`.

## Choosing the PV prefix (no rebuild)

The prefix is a run-time choice. Run several independent GP IOCs at once by
giving each a different prefix (and container name):

```bash
docker run -d --rm --name iococean --net=host -e IOC=gp -e PREFIX=ocean: prjemian/synapps:latest
docker run -d --rm --name iocsky   --net=host -e IOC=gp -e PREFIX=sky:   prjemian/synapps:latest
```

Each serves the full GP PV set under its own prefix. No recompilation.

> **Avoid duplicate PVs on the network.** Two IOCs serving the *same* prefix
> on the same subnet will conflict (Channel Access "duplicate PV"). Give each
> IOC a unique prefix.

## Using compose (docker or podman)

[`compose.yaml`](../compose.yaml) provides `gp` services in two networking
profiles. Pick one:

```bash
# Linux / CI: host networking, host clients see PVs directly
GP_PREFIX=gp docker compose --profile host up -d gp-host

# Docker Desktop / Windows / macOS / Synology: ports mapped
GP_PREFIX=gp docker compose --profile ports up -d gp-ports
```

Set `GP_PREFIX` (without the trailing colon) to choose the prefix; the
container is named `ioc<GP_PREFIX>` (e.g. `iocgp`).

Stop it:

```bash
docker compose --profile host down     # or --profile ports
```

## Networking profiles

profile | when to use | how clients reach PVs
--- | --- | ---
`host` | Linux workstations and CI | container shares the host network; clients on the host see PVs directly (fast).
`ports` | Docker Desktop, Windows, macOS, Synology | Channel Access (`5064-5065`) and pvAccess (`5075-5076`) are published; set your client's `EPICS_CA_ADDR_LIST` to the container host if needed.

## Attach to the IOC console

The IOC runs under [`procServ`](https://github.com/ralphlange/procServ).
Attach to its shell over the console (telnet) port (default `2048`):

```bash
telnet localhost 2048     # Ctrl-] then 'quit' to detach (do NOT Ctrl-C)
```

Or run an EPICS client tool inside the container:

```bash
docker exec iocgp caget gp:UPTIME
```

## Inside the container

When you `docker exec` into the container you land in `/home`, with
convenience links:

link | points to
--- | ---
`iocgp` | the GP IOC boot directory (`st.cmd.Linux`, substitutions, ...)
`support` | the synApps support tree
`build-logs` | compilation logs (`build-gp.log`, ...)
`gp.sh` | the GP persona launcher

## Display screens (MEDM, caQtDM, ...)

Operator-interface files are gathered by format under `/opt/epics/screens`
(also linked as `/home/screens`), one directory per format, with referenced
graphics (`.gif`, `.png`, ...) copied alongside:

format | directory | tool
--- | --- | ---
MEDM | `/opt/epics/screens/adl` | `medm`
caQtDM | `/opt/epics/screens/ui` | `caqtdm`
CSS BOY | `/opt/epics/screens/opi` | CS-Studio
Phoebus | `/opt/epics/screens/bob` | Phoebus
EDM | `/opt/epics/screens/edl` | `edm`

Referenced graphics (`.gif`, `.png`, ...) are stored once in
`/opt/epics/screens/graphics` and symlinked into each format directory (so
images are not duplicated per format).

The screens use a **replaceable prefix macro `$(P)`** (not a baked-in prefix),
so the same screen works for any runtime prefix. Display tools are **not**
included in this server image (clients live elsewhere); copy or mount the
screens to a host with the tool installed and pass the prefix:

```bash
# on a host that has MEDM / caQtDM:
medm   -x -macro "P=gp:" gp.adl
caqtdm -macro "P=gp:"    gp.ui
```

The main GP screen is `xxx.adl` / `xxx.ui`.

## Tuning

env / build-arg | effect
--- | ---
`PREFIX` | PV prefix at run time (default `gp:`).
`IOC_CONSOLE_PORT` | procServ console (telnet) port (default `2048`).
`MOTOR_SREV` | steps/revolution for the 56 sim motors at **build** time (default `8000`).

## Motor assignments

56 simulated motors (`$(PREFIX)m1`..`$(PREFIX)m56`). `m1`-`m16` are free for
general use; others are wired to the optics/diffractometer features:

motor | assignment
--- | ---
m1-m16 | general purpose (free for users/tests)
m17-m28 | reserved
m29 | TTH 4-circle *(free; for client software, e.g. SPEC, hklpy2, ...)*
m30 | TH 4-circle *(free; for client software)*
m31 | CHI 4-circle *(free; for client software)*
m32 | PHI 4-circle *(free; for client software)*
m33 | CM coarse/fine
m34 | FM coarse/fine
m35 | M0X table
m36 | M0Y table
m37 | M1Y table
m38 | M2X table
m39 | M2Y table
m40 | M2Z table
m41-m44 | reserved
m45 | THETA monochromator
m46 | Y monochromator
m47 | Z monochromator
m48 | reserved
m49 | Slit1V:mXp
m50 | Slit1V:mXn
m51 | Slit1H:mXp
m52 | Slit1H:mXn
m53 | Slit2V:mXp
m54 | Slit2V:mXn
m55 | Slit2H:mXp
m56 | Slit2H:mXn

### 4-circle diffractometer motors

The IOC's built-in 4-circle orientation support (`$(PREFIX)orient_0:H/K/L`,
...) runs on **SoftMotor records `SM1`-`SM4`** (descriptions prefixed `SM_`).

This deliberately leaves the real sim motors **`m29`-`m32` free** to be driven
by client software (for example, Bluesky's `hklpy2` diffractometer package).
Their descriptions still read `TTH/TH/CHI/PHI 4-circle` as a hint of their
intended client use.

SoftMotor | role
--- | ---
SM1 | SM_TTH 4-circle (IOC orient support)
SM2 | SM_TH 4-circle
SM3 | SM_CHI 4-circle
SM4 | SM_PHI 4-circle
SM5-SM10 | spare SoftMotor records

## Scaler channels

Three soft scalers (`scaler1`-`scaler3`), 64 channels each. `scaler1` has
pre-assigned channel names:

channel | name
--- | ---
1 | timebase
2 | I0
3 | scint
4 | diode
5 | I000
6 | I00

## See also

- [xxx](./xxx.md) — the as-supplied synApps template IOC
- [synApps module selection](./synapps_modules.md)
- [`compose.yaml`](../compose.yaml)
