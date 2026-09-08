# EPICS-in-containers (v3): Requirements & Goals

Status: **DRAFT** — requirements and goals only. This document deliberately
contains **no implementation** decisions (no choices about base OS, image
layering, build tooling, networking mechanism, orchestration format, etc.).
Those follow *after* the goals are agreed, so that an early implementation
idea does not silently become a requirement.

## 1. Purpose (mission)

Provide container image(s) that deliver a working EPICS system — EPICS base,
synApps, and areaDetector — both **as supplied upstream** and **with selected
local customizations**, for use on local workstations, in online continuous
integration, for development of EPICS *client* software, and for **simulation
of APS beamlines**.

The image(s) provide EPICS **servers (IOCs)**. EPICS **client** software is
explicitly out of scope (see Non-Goals).

## 2. Background / motivation

- The project has languished: the last edits were ~1 year ago, on an
  in-progress branch; the prior released line is older still.
- During that time the upstream EPICS base, synApps, and areaDetector code
  bases have advanced substantially.
- The existing recipes (archived in `v2.0/`, with earlier lines in `v1.0/`
  and `v1.1/`) are difficult to maintain and upgrade: versions are scattered
  across many recipe scripts, several planned features were never shipped,
  and the design assumes one specific runtime environment.
- Image **size has grown across versions** and is a recurring concern.
- It is time to rebuild — beginning by stating goals, not by writing recipes.

## 3. Audiences (customers) and what each needs

| # | Audience | Core need |
|---|----------|-----------|
| 1 | Local workstations | Run EPICS IOCs locally for hands-on, interactive use. |
| 2 | Online CI | Fast, repeatable, isolated IOCs to test EPICS client software. |
| 3 | Client-software development | A known, reachable EPICS server to develop and debug clients against. |
| 4 | Beamline simulation | Stand up much of an APS beamline (or representative parts) without hardware. |

### Audience-specific notes

- **CI** pulls and starts IOCs many times per run (e.g. a test matrix across
  several Python versions, run in parallel). Pull cost and startup time are
  measured, real costs.
- **Simulation** has proven valuable for emulating much of the APS beamlines.
  There is demand to expand the set of hardware-free devices available
  (see §4, expanded areaDetector cameras).

## 4. Functional goals (the "WHAT")

> These describe required capabilities/outputs, **not** how they are built.

- **G1 — Full EPICS stack.** Provide EPICS base, synApps, and areaDetector.
- **G2 — Stock and customized.** Support EPICS as-supplied upstream, and also
  apply selected local modifications/customizations.
- **G3 — IOC personas.** Provide ready-to-run IOC personas. Proven in real
  use today: a general-purpose synApps IOC ("GP") and an ADSimDetector IOC
  ("ADSIM"). (Which additional personas are *required* vs. *future* is an
  open question — see §9.)
- **G4 — Expanded hardware-free simulation devices.** Broaden the simulation
  offering beyond ADSimDetector to include additional areaDetector cameras
  that need no hardware — e.g. ADURL, pvaCam/pvaDriver, and a few other
  no-hardware CAMs. (Exact set is an open question — see §9.)
- **G5 — User-chosen PV prefix.** Allow the operator to choose the PV prefix
  for an IOC, so multiple independent IOCs can coexist.
- **G6 — Reachable PVs.** PVs served by an IOC must be reachable by the
  intended clients. (The *guarantee level per platform* is an open question
  — see §6/§9.)

## 5. Quality / non-functional goals

- **Q1 — Smaller images.** Image size is an explicit design concern. The new
  design must actively consider options to reduce image size **without
  compromising desired features**. Size is subordinate to features but is a
  first-class goal, not an afterthought. Applies to download volume and to
  stored size.
- **Q2 — Easier to maintain.** The recipe(s) must be materially easier to
  maintain and to upgrade as upstream EPICS/synApps/AD advance. The
  difficulty of upgrading was a primary cause of the project languishing.
- **Q3 — Single source of truth for versions.** Component versions should be
  defined in one authoritative place, not duplicated across many recipe
  scripts and docs. (Stated as a goal; mechanism deferred.)
- **Q4 — Portability.** The design should support use beyond a single Linux
  + Docker environment, including:
  - additional container runtimes (e.g. podman),
  - additional host operating systems,
  - additional CPU architectures (e.g. Apple Silicon, Raspberry Pi,
    Synology NAS), in addition to x86-64.
  (The *strength* of this commitment — "must support" vs. "must not
  preclude" — is an open question; see §6/§9.)
- **Q5 — Simpler to use.** Reduce reliance on host-side shell (bash) scripting
  to start and manage containers, to ease use on systems where a bash startup
  workflow is awkward or unavailable.
- **Q6 — Reproducible / auditable builds.** Builds should be reproducible and
  the contained component versions auditable. (Note potential tension with Q2's
  desire to track latest upstream easily — see §6.)
- **Q7 — Documentation.** Documentation is a first-class deliverable of the
  rebuild, not an afterthought. It must serve each audience (§3) and cover, at
  minimum:
  - **What is provided:** the image(s), the IOC personas, the PVs/contract a
    consumer can rely on, and the component versions contained.
  - **How to use it:** quick-start and worked examples for each audience —
    local workstation, CI, client-software development, and simulation —
    across the supported runtimes/host OSes (per Q4).
  - **How to maintain/rebuild it:** how the recipe is structured, how to
    upgrade component versions (tied to Q3's single source of truth), and how
    to build locally.
  - **What changed and why:** a changelog / version history, and migration
    guidance where the contract changes (ties to C1).
  Documentation should stay close to and versioned with the code it
  describes, so it does not drift (a recurring failure mode in v1.x/v2.0,
  where docs duplicated and outlived the recipes). Keeping it accurate and
  discoverable is part of "easier to maintain" (Q2).

## 6. Constraints and known tensions

These are not yet decisions; they are forces the goals must reconcile.

- **C1 — Existing consumers depend on a runtime contract.** Downstream repos
  consume the current image by relying on specific PV names, IOC personas
  (GP, ADSIM), container/path/mount conventions, and host-visible PV access.
  Whether the rebuild must preserve this contract, version it, or break it
  with a migration path is an open question (§9).
- **C2 — Portability vs. host-visible PVs.** The current approach to making
  PVs visible to host clients does not translate cleanly to all runtimes,
  host OSes, and architectures. Broad portability (Q4) and "host can always
  see the PVs" (G6) may not both be fully achievable on every platform.
- **C3 — Size vs. features vs. simulation breadth.** Expanding simulation
  devices (G4) and providing a full stack (G1) push image size up, in
  tension with Q1. The design must find size reductions that do not sacrifice
  these features.
- **C4 — Track-latest vs. reproducible.** Easy upgrades (Q2/Q3) and
  reproducible/pinned builds (Q6) pull in opposite directions and must be
  balanced.
- **C5 — Simplicity vs. compatibility.** Reducing host-side bash (Q5) may
  conflict with preserving an existing bash-based consumer contract (C1).

## 7. Non-goals (explicitly out of scope)

> To be confirmed; listed here so scope creep is visible.

- Providing EPICS **client** software / GUIs as the product. (Clients are
  consumers of these images, not deliverables of them.)
- Production / live-beamline deployment and operations.
- Long-term data persistence / retention guarantees for IOC-generated data.
- Security hardening for untrusted, hostile multi-tenant operation.

## 8. Definition of success

> Draft criteria; refine as goals firm up.

- A maintainer can upgrade to a new upstream EPICS/synApps/AD release by
  editing a small, single, well-defined place (Q2/Q3).
- The proven CI usage (GP + ADSIM, prefix-isolated, PVs reachable) continues
  to work, or a clear migration path exists (C1).
- Image size is reduced relative to the v2.0 line, with no loss of required
  features (Q1).
- The simulation offering covers ADSimDetector plus the agreed additional
  hardware-free cameras (G4).
- The image(s) are usable across the agreed set of runtimes, host OSes, and
  architectures (Q4), at the agreed guarantee level.
- Documentation exists for each audience, is versioned with the code, and a
  new user can get an IOC running and reach its PVs by following it (Q7).

## 9. Open questions (to resolve before/while finalizing goals)

1. **Granularity of offering:** one all-in-one deliverable, or a family of
   deliverables of differing completeness/size?
2. **Required IOC personas:** which personas are *required* outputs vs.
   *future*? (GP, ADSIM are proven; ADURL, pvaCam/pvaDriver, others?)
3. **Simulation camera set:** exact list of hardware-free areaDetector CAMs
   to include under G4.
4. **Stock-only deliverable:** is "unmodified upstream EPICS" a first-class
   deliverable on its own, or always "stock + customizations"?
5. **Primary audience on conflict:** if audiences' needs conflict, which is
   optimized first?
6. **Portability guarantee level:** "must run on" vs. "must not preclude" —
   per runtime, per host OS, per architecture.
7. **Host-visible PVs guarantee:** required on all platforms, or only where
   the platform permits?
8. **Compatibility commitment:** preserve the existing consumer contract,
   version it, or clean break + migration guide?
9. **"No bash to start":** hard requirement or strong preference?
10. **Reproducible vs. track-latest:** where to land on the C4 spectrum.
11. **Documentation scope/format:** what doc set is required (quick-start,
    per-audience guides, maintainer/upgrade guide, contract reference,
    changelog/migration), and where it lives so it stays versioned with the
    code (Q7).
12. **Confirm non-goals** in §7.

## 10. Out of scope for *this document*

Any statement of *how* the above will be achieved — base image choice, image
layering/multi-stage, build orchestration, networking mechanism, the
start/manage-IOC interface format, multi-arch build method, registry/tagging
scheme, etc. Those belong in a later design document, after these goals are
agreed.
