# v3 implementation strategy

Status: **DRAFT strategy.** This document records the implementation approach
and the decisions made so far for the v3 rebuild. It builds on:

- `docs/v3.md` — the plan/goals as written by the maintainer.
- `docs/v3_requirements.md` — requirements & goals (audiences, quality goals).
- `docs/v2_build_phases.md` — reconstructed reference for the prior recipe.

It departs freely from v1 and v2 to adopt current best practices.

## 1. Decisions made

| # | Decision | Rationale |
|---|----------|-----------|
| D1 | **Layered hierarchy is a *build* concern; publish few *runtime-selectable* images.** | Serves "easily deployed" + "minimize size" without the v1 image sprawl or the v2 monolith. The {stock/custom} x {8 IOC types} x {arch} matrix is handled by choosing the persona at container start, not by publishing one image per combination. |
| D2 | **IOC process manager: `procServ`.** `screen` is removed entirely. | `screen` failed under rootless podman (no controlling TTY / pts + setuid-helper assumptions; recorded in `docs/v3.md`). procServ is the EPICS-community standard for containerized IOCs: no TTY needed, auto-restart, `console`/telnet attach, clean logs. |
| D3 | **Primary run contract: `compose.yaml` (clean break).** No `iocmgr.sh` shim. | Declarative, no host bash required, works on docker + `podman compose`, across Linux/Mac/Windows/Synology. Existing `iocmgr.sh` consumers migrate (documented). |
| D4 | **v3 recipes live at the repo top level.** v1.0/v1.1/v2.0 remain archived subdirs. | v3 becomes the active project, mirroring how v2 was the active top level. |
| D5 | **Multi-arch via manifest lists.** amd64 now; arm64 (RPi/Apple Silicon) a stretch goal. | Architecture is invisible to the user — one tag resolves to the right arch. Requires eliminating hard-coded `linux-x86_64` paths. |
| D6 | **Single source of truth for versions.** One manifest read by all build stages and docs. | Directly serves "easy to upgrade / easy to maintain"; kills the v2 problem of versions scattered across many scripts and duplicated in docs. |
| D7 | **Customizations as loadable overlays, not in-place `sed` edits.** | The v2 sed-per-tweak model broke on upstream reformatting. Ship our own `.iocsh`/`.substitutions`/plugin config and `iocshLoad` them. "As-supplied vs. customized" becomes "don't load vs. load the overlay." |

## 2. Image architecture

Multi-stage build; the hierarchy below is the *build* dependency chain
(reusable stages), not necessarily one published image per level:

```
base-os            debian-slim; split into build-deps and runtime-deps
  -> epics-runtime    EPICS base; softIoc IOC available
    -> synapps-runtime    synApps support tree + xxx IOC
      -> base-areadetector   ADCore + selected drivers/plugins
        -> (final)     runtime-selectable personas + customizations + screens
```

- **Runtime vs. devel variants.** Publish a small `:runtime` (products only,
  copied `--from` builder stages) and a `:devel` (toolchain + sources + full
  build logs) so "minimize size" and "full toolset to recompile / easy local
  patches / full logs" are both satisfied.
- **How many final images:** to be finalized. Options on the table: a single
  `synapps` image hosting all personas, or a weight-class split (lightweight
  `softIoc`/`xxx` vs. large `areaDetector`). Either way, persona chosen at run
  time (D1).

## 3. IOC personas (run-time selectable)

From `docs/v3.md`:

- `softIoc` — EPICS base softIoc, with command-line options exposed.
- `xxx` — synApps IOC, as-supplied and with customizations.
- area detector drivers (hardware-free): ADSimDetector (as-supplied +
  customized), ADCSimDetector, ADURL, ADUVC, pvaDriver, ffmpegServer.
  - plugins: all.
  - file writers: all **except NeXus** (superseded by HDF; matches v2).

Each persona is started via `compose.yaml` with a user-chosen PV `PREFIX`,
supervised by procServ.

## 4. Runtime / orchestration

- **procServ** supervises the IOC (auto-restart, console attach).
- **`compose.yaml`** is the deployment contract; env vars set PREFIX and
  select the persona; volumes and ports are declared there.
- **Networking:** provide two profiles —
  - `host` (Linux/CI fast path; preserves host-visible PVs used by CI),
  - `ports` (mapped CA `5064-5065` + PVA `5075-5076`; works on Docker
    Desktop / Synology where host networking is unavailable), with the
    required `EPICS_CA_*` env vars documented.
- **Multi-IOC-per-container** (ref issue #65, "one IOC per container is too
  resource demanding") is enabled naturally by procServ (one instance per
  IOC, distinct console ports) if/when desired — an option, not the default.

## 5. Display (screen) files

- Collect operator-interface files by format into stable directories
  (e.g. `/opt/screens/adl` for MEDM, `/opt/screens/ui` for caQtDM), with
  reference-normalization done once at build (successor to v2's
  `copy_screens.sh` + `modify_adl_in_ui_files.sh`).
- Consider publishing screens as a small separate artifact, since clients
  (not the server image) consume them.

## 6. Documentation (Q7)

- Versioned in-repo, generated from the version manifest where possible so
  "what versions are inside" never drifts.
- Per-audience quick-starts (workstation, CI, client-dev, simulation), a
  maintainer/upgrade guide, a contract reference (personas, PVs, paths,
  ports), and a changelog + migration guide (compose replaces iocmgr).

## 7. Phased build-out plan

Sequenced to reach a runnable artifact early, then expand:

1. **Foundations:** top-level v3 skeleton, version manifest, BuildKit/`buildx`
   + manifest-list setup, CI that builds and smoke-tests.
2. **base-os + epics-runtime:** softIoc runnable under procServ with prefix
   override; prove multi-stage size split. *First runnable milestone.*
3. **synapps-runtime + xxx IOC:** stock first, then customization overlays
   (motors/optics/std/general_purpose) as loadable files.
4. **base-areadetector + ADSim:** ADCore + ADSimDetector; all plugins; all
   file writers except NeXus; overlay-based customization.
5. **Additional drivers:** ADCSimDetector, ADURL, ADUVC, pvaDriver,
   ffmpegServer (the unfinished v2 TODO) — added incrementally via manifest.
6. **Screens collation + orchestration:** compose, networking profiles.
7. **Multi-arch (arm64) + documentation + changelog/migration.**

## 8. Base OS choice

- **`debian:12-slim`** for both builder and runtime stages (was full Debian in
  v2). glibc-based, so areaDetector drivers and prebuilt deps "just work".
- Not the absolute smallest, but the smaller options cost more than they save
  for a compiled C++/areaDetector stack: **Alpine (musl)** breaks some AD
  drivers and changes `EpicsHostArch` to a `-musl` target — a large
  maintenance/compatibility tax for ~65 MB.
- Because builds are multi-stage, the *builder* base size is irrelevant to the
  shipped image; only the **runtime** stage's base and its copied products
  matter. The dominant size lever is what lands in the runtime stage (we copy
  products only, no toolchain/sources).
- **Stretch optimization (later):** a distroless / minimal runtime base once
  the full stack builds, to shave the runtime image further without the musl
  risk.

### Image-size trim (one pass, after all AD content)

Measured the full footprint and pruned non-runtime cruft from the built
support tree in the BUILDER stage (so the slim result is what the runtime
image copies; deletions never persist in a shipped layer). See
`resources/prune_support.sh`.

- Removed (verified all 7 personas still boot): `.git` dirs (177 MB), `*.a`
  static libs (411 MB), `*.o` objects (203 MB), `O.*` build-output dirs
  (567 MB, overlaps objects).
- Support tree: **1.6 GB -> 624 MB**. Full image: **2.16 GB -> 1.18 GB**
  (~45% smaller).
- Kept: `bin/`, `lib/*.so`, `dbd/`, `db/` (+ templates/.req/.substitutions),
  `iocBoot`, `op/` screens, and the customized `ioc*` boot dirs.
- Further opportunities (not done): the aggregated `/opt/epics/screens`
  display files (~245 MB, dominated by verbose `.ui`/`.opi`); a distroless
  runtime base; ADSupport bundled sources.

## 9. Progress (Phase 1-2 done)

First runnable milestone complete and smoke-tested:

- `versions.env` — single source of truth (EPICS base `7.0.10`, Debian
  `12-slim`).
- Multi-stage `Dockerfile`: `os-runtime` -> `os-build` -> `epics-build` ->
  `epics-runtime`. Runtime image ~202 MB; toolchain/sources excluded.
- Host arch resolved in the builder (perl-free runtime) via a stable
  `binln -> bin/<arch>` symlink, so consumers need not hard-code
  `linux-x86_64`.
- `procServ` supervises the IOC; output to container stdout; console via
  telnet on `IOC_CONSOLE_PORT`.
- `softioc` persona with a demo DB (`${PREFIX}UPTIME`, `${PREFIX}IOC_NAME`,
  `${PREFIX}float1`); prefix overridable at run time.
- `Makefile` (build/build-devel/run/console/shell/test/clean) + `compose.yaml`
  (host and ports profiles) + `resources/smoke-test.sh`.
- Rootless-podman support via `BUILD_FLAGS`/`RUN_FLAGS` (`--no-hosts`).

## 9a. Progress (Phase 3: synApps + xxx IOC)

`synapps-runtime` stage builds synApps and the `xxx` IOC:

- Uses the standard `assemble_synApps.sh` at `SYNAPPS_VERSION=R6-3`.
- `resources/synapps_prepare.sh` makes two minimal edits (no sourced config,
  so kept modules keep the release's tags): set `EPICS_BASE`, and empty the
  excluded hardware modules (see `docs/synapps_modules.md`). It also applies
  documented per-module version overrides from `SYNAPPS_OVERRIDE_*`.
- Build logs retained in `/opt/build-logs/` (proved essential for diagnosis).
- Runtime `synapps-runtime` image ~1.84 GB (the copied support tree still carries
  sources/.git/objects -- size trimming is an open task).

### Troubleshooting record (WHAT / WHY / resolution)

- **WHAT:** synApps R6-3 would not compile against modern EPICS base + GCC 12
  (Debian 12): `motor-R7-2-2` failed with `'epicsShareFunc' does not name a
  type` in `motorApp/MotorSrc/motordrvCom.h`.
- **WHY:** that header uses the `epicsShareFunc` macro but does not itself
  `#include <shareLib.h>`; it relied on a transitive include no longer present
  in this base/compiler context. motor R7-2-2 (pinned by R6-3) predates the
  fix.
- **Resolution:** documented per-module override `SYNAPPS_OVERRIDE_MOTOR=R7-3-1`
  in `versions.env` (motor R7-3-1 includes the fix). Base stays at 7.0.10. To
  retire: remove the override when a synApps release ships a fixed motor.
- **Dead end (recorded):** pinning base down to 7.0.6.1 did NOT fix it (same
  compiler behavior); the fix had to come from a newer motor, not an older
  base.
- **Secondary bug fixed:** piped build steps (`make ... | tee`) were masking
  `make` failures. The `SHELL ["/bin/bash","-o","pipefail","-c"]` directive is
  **ignored under podman's default OCI image format** ("SHELL is not supported
  for OCI image format"). Fixed engine-agnostically by invoking
  `bash -o pipefail -c '...'` explicitly in the piped RUN steps. Also note
  `SHELL` does not inherit across `FROM` regardless.
- **Red herring (recorded):** `epicsShareFunc`/`invertArray` lines in the
  motor R7-3-1 build were `warning:`/`note:` (`-Wstringop-overflow`), not
  errors; the build succeeded. Grepping for `epicsShareFunc` matched benign
  notes -- verify with `grep -E '\] Error [0-9]'` instead.

## 10. Tag & registry scheme

**Registries.** Docker Hub `prjemian/synapps` is primary; an internal registry
(e.g. GitLab) mirrors the same tags for network-restricted users. The recipes
are registry-agnostic (`compose.yaml` uses `${IMAGE:-prjemian/synapps}`; the
legacy notice names tags without a fixed registry).

**Tags published for a release `X.Y.Z`** (SemVer; `IMAGE_VERSION` in
`versions.env` is the single source of truth):

| tag | meaning | mutable |
| --- | --- | --- |
| `X.Y.Z` (e.g. `3.0.0`) | exact release | no |
| `X.Y` (e.g. `3.0`) | newest patch of that minor | moves within minor |
| `X` (e.g. `3`) | newest release of that major | moves within major |
| `latest` | newest **major** (v2 today; v3 after the flip) | moves |

- The full ladder `X.Y.Z` + `X.Y` + `X` (+ `latest`) is published so consumers
  choose their pin granularity.
- The **major alias is `:3`** (not `:v3`).
- **`:2.0.1`** is the immutable v2 anchor (never overwritten; no `:2` alias --
  there is a single v2.x release). See `docs/v3_transition.md`.
- The **`-devel`** variant (toolchain + sources) is **not published** for now;
  build it locally with `make build-devel`.

**Multi-arch (prepare-only for now).** Every published tag is a **manifest
list** so the architecture is invisible to the user (one tag resolves to the
right arch). Push manifest lists with `buildx --push` / `skopeo copy --all`
(not `docker save`/`load`).

- The recipe is **architecture-agnostic** already (no hard-coded arch; the
  `binln -> bin/<arch>` symlink and `EpicsHostArch` handle it).
- **`linux/amd64` is the only platform currently BUILT and VERIFIED.**
- **`linux/arm64` is designed-for but UNVERIFIED.** Building the full
  base + synApps + areaDetector stack for aarch64 may surface real issues and
  **must be verified** on arm64 hardware or a runner with working qemu
  emulation before it is published. Do not claim arm64 support until an arm64
  image has actually built and passed the smoke test.
- **Single switch:** the target platform(s) live in `versions.env`
  (`PLATFORMS`, default `linux/amd64`). Adding arm64 is a one-line change
  (`linux/amd64,linux/arm64`) *in an environment that can build and test it* --
  the build/publish pipelines read `PLATFORMS`, so no other edits are needed.
- **Build mechanism:** for the podman environment, build/push manifest lists
  with `podman build --platform ${PLATFORMS} --manifest <img>` +
  `podman manifest push` (the podman-native equivalent of `buildx --push`).
- **Why arm64 is unverified on the current host:** cross-building aarch64 needs
  qemu-user-static binfmt handlers. On the maintainer's rootless-podman host
  these are absent (no `qemu-user-static` package/binary) and cannot be
  registered from a container (`/proc/sys/fs/binfmt_misc` mount is denied to
  rootless). Enabling arm64 verification requires host admin action
  (`sudo dnf install qemu-user-static`, which registers the handlers) or a
  native-arm64 / emulation-capable CI runner.
- **Apple Silicon = native arm64.** An Apple Silicon Mac (M1/M2/M3/...) is
  itself a native `linux/arm64` build+test environment (via Docker/Podman
  Desktop, no qemu needed) -- a concrete, low-friction path to move arm64 from
  prepare-only to verified. Apple Silicon is also a common developer laptop in
  our audience, which strengthens the case for shipping a verified arm64.

**The `:latest` flip** (v2 -> v3) is a deliberate, dated event shipped as a
**post-`3.0.0` patch release**, after the opt-in window -- see
`docs/v3_transition.md`.

## 11. Still open (to finalize as build-out proceeds)

- Exact number/shape of published final images (single vs. weight-class split).
- Networking default profile and the documented `EPICS_CA_*` guidance.
- Whether/where to publish screens as a separate artifact.
- Distroless/minimal runtime base as a size optimization (see §8).
