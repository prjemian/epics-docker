# Persona architecture (v3)

A **persona** is a named, ready-to-run IOC, selected at container start with
`-e IOC=<name>`. This page is the single at-rest reference for what personas
exist and how each is built, launched, and prefixed.

This repo's tools build **one** container image. A *persona* is a runtime
selection (`-e IOC=<name>`) of which IOC — already baked into that single image
— starts. The persona provides the features; it does not build anything at run
time.

## The branch-point model (start here)

The personas are best understood as a base IOC at a **branch point**, from
which two build branches progress:

```
                          softioc            <- branch point:
                   (EPICS base softIoc;         an IOC from EPICS base
                    no features provided)        with NO features provided
                          /       \
                         /         \
           synApps branch           areaDetector branch
                  |                        |
             xxx  (as-supplied)       adsim   (2D image camera)
             gp   (customized)        adcsim  (waveform digitizer)
                                      adurl   (images from a URL)
                                      adpva   (images over pvAccess)
```

- **`softioc` is the branch point.** It is a `softIoc` from EPICS base with
  **no features provided**: records, database, prefix, and startup are all the
  caller's to supply. It sits *before* the fork (it exists in the
  `epics-runtime` build stage, upstream of both branches).
- **synApps branch** — `xxx` (as-supplied) and `gp` (customized): EPICS base +
  the synApps support tree, adding synApps records/features.
- **areaDetector branch** — `adsim`, `adcsim`, `adurl`, `adpva`: EPICS base +
  the areaDetector stack; each is a software-defined (hardware-free) camera
  IOC.

The two branches share only (1) some common EPICS modules underneath and
(2) the *persona* feature (a runtime selection) — chiefly `PREFIX`. Their build and
boot mechanics are legitimately different; the fork is real, not incidental.

For end users the story is short: *start from a bare EPICS-base IOC
(`softioc`) with nothing configured; add synApps to get `xxx`/`gp`; or add
areaDetector to get a simulated camera (`adsim`, …). One image; pick the
persona at start.*

## The one hard contract

`entrypoint.sh` runs `/usr/local/bin/${IOC}.sh` under procServ. That launcher
script is the *only* required contract; everything else about how a persona
finds and starts its IOC is currently defined per persona.

```
docker run -e IOC=<name> -e PREFIX=<prefix:>  ->  procServ  ->  /usr/local/bin/<name>.sh
```

## Persona catalog (current)

The `branch` column ties each persona to the branch-point model above.

| persona | branch | built by | launcher | prefix policy | probe PV (smoke) |
|---|---|---|---|---|---|
| `softioc` | branch point (EPICS base) | nothing (base only) | `softioc.sh` execs `softIoc ${IOC_ARGS}` | **ignored**; user supplies records/prefix via `IOC_ARGS` | user-supplied (`smoke.db`) |
| `xxx` | synApps, as-supplied | synApps assembler | `xxx.sh` execs `st.cmd.Linux` | **baked** `xxx:` (ignores PREFIX, by design) | `xxx:UPTIME` |
| `gp` | synApps, customized | `gp_build.sh` + 6 overlay scripts + `sed` | `gp.sh` execs `st.cmd.Linux` | **macro default** `$(PREFIX=gp:)` (honors PREFIX) | `<prefix>gp:float1` |
| `adsim` | areaDetector (ADSimDetector), customized | `adcam_build.sh` + `profiles/adsim.env` | shared `adcam.sh` via `.adcam` metadata | **macro default** `$(PREFIX=adsim:)` | `cam1:Acquire_RBV` |
| `adcsim` | areaDetector (ADCSimDetector) | `adcam_build.sh` + `profiles/adcsim.env` | shared `adcam.sh` | macro default `$(PREFIX=adcsim:)` | `det1:TimeStamp_RBV` |
| `adurl` | areaDetector (ADURL) | `adcam_build.sh` + `profiles/adurl.env` | shared `adcam.sh` | macro default `$(PREFIX=adurl:)` | `cam1:Acquire_RBV` |
| `adpva` | areaDetector (pvaDriver) | `adcam_build.sh` + `profiles/adpva.env` | shared `adcam.sh` | macro default `$(PREFIX=adpva:)` | `cam1:Acquire_RBV` |

## The four launch patterns (why this is hard to hold in mind)

1. **Inline exec** -- `softioc.sh`: no build, records are the caller's.
2. **Stock boot dir** -- `xxx.sh`: run upstream `st.cmd.Linux` unmodified;
   discovery by `ls xxx-*/...` glob.
3. **Copy + overlay + sed** -- `gp`: copy the xxx template, apply overlay files
   and `sed` edits at build (`gp_build.sh`), run the result; glob `iocgp/...`.
4. **Framework + profile + metadata** -- the adcam cameras: one build script
   (`adcam_build.sh`) driven by a per-camera `profiles/<name>.env`, writing a
   `.adcam` file that one shared launcher (`adcam.sh`) reads at run time.

Pattern 4 is the good one (data-driven, one launcher, one schema). Patterns
1-3 each invented their own build + launch + discovery + prefix behavior.

## Where the persona set is actually defined (today)

There is no single manifest. The set is spread across:

- `Dockerfile` (`for cam in adsim adcsim adurl adpva`) -- creates the
  `adcam.sh` symlinks.
- presence of `resources/<name>.sh` launcher scripts.
- `resources/adcam/profiles/*.env` -- camera definitions.
- `.adcam` files that exist only **after a build**.
- prefix policy -- discoverable only by reading each launcher.
- probe PVs -- encoded in `resources/smoke-test.sh`.

Consequence: neither a person nor an LLM can answer "what personas exist and
how does each behave" by reading committed files; some truth appears only at
build time.

## Prefix policy, stated plainly

- `softioc`, `xxx`: PREFIX is **not** applied (base-only / as-supplied).
- `gp`, all adcam cameras: PREFIX is honored via an EPICS macro default
  `$(PREFIX=<default>)`; no recompile to change it.

## Target: one unified persona contract (proposed; not yet built)

> This section describes a proposed repair direction. It is **not** implemented
> yet; the catalog and patterns above describe the current state.

Generalize pattern 4 to all personas:

- **One persona = one declarative spec** (name, branch, source IOC or "none",
  prefix policy, launch command, probe PV) in one directory.
- **One launcher** reads the spec/metadata (generalized `adcam.sh`); retire
  the bespoke `softioc.sh`/`xxx.sh`/`gp.sh` as *launchers* while keeping their
  *build* logic.
- **One committed manifest** listing every persona and its properties,
  generated at build and readable at rest -- the file that answers the question
  above without a build.

This is additive to the working build (low risk) and turns "four architectures
you must memorize" into "one schema you read."

### Unify along the branch, not across it

The branch-point model sets the scope boundary for this target. The two
branches (synApps, areaDetector) fork legitimately after EPICS base; their
overlap is only the common EPICS modules and the *persona* feature (a runtime
selection, mainly `PREFIX`). So:

- **Low risk — unify the overlap.** The persona feature (PREFIX, the
  launcher contract) and a readable persona manifest live *at the single-image
  / runtime level*, which already unifies the branches. Working here does not
  span the fork.
- **Inherent scope-creep risk — unify across the fork.** Trying to make one
  *build* abstraction span the synApps and areaDetector branches works against
  the real fork and inherits the cost of reconciling both. The single image
  already merges the branch products; the branch *builds* are legitimately two
  (plus the pre-fork base). Do not draw the abstraction across the fork.

In short: unify the runtime contract and the inventory (along the branch);
leave each branch's build path as-is unless a change is scoped and justified on
its own.
