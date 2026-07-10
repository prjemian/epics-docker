# Agent notes for the epics-docker (v3) rebuild

Project-specific guidance for AI agents working in **this repository**. It is
intentionally scoped to this rebuild; do not generalize it to other projects.

## Fidelity: migrate, do not substitute

This project rebuilds the `prjemian/synapps` image. Its features are migrated
from established sources -- EPICS base, synApps, areaDetector, and the
maintainer's own v2.0.1 customizations (archived under `v2.0/`).

- **Standard personas** (e.g. `softioc`, `xxx`, the stock camera IOCs): provide
  only what the standard EPICS/synApps/areaDetector sources supply. Do **not**
  add record instances, `.db`/`st.cmd` files, or behavior that the standard
  source does not provide.
- **Customized personas** (e.g. `gp`, `adsim`): use the maintainer's v2.0.1
  customizations. Reproduce them faithfully from their real source (the `v2.0/`
  recipes), not from memory or approximation.
- **No substitutions.** Never invent a look-alike for a feature you cannot
  migrate faithfully (a fabricated PV, a homemade counter standing in for a
  real record, etc.). A substitution that "passes a test" is worse than an
  honest gap, because it hides the gap.
- **When you do not know, stop and ask.** If a feature cannot be migrated
  faithfully at a given step, flag it explicitly as a gap (TODO / open
  question) and ask the maintainer. Do not paper over it.

## Conventions require explicit agreement

- Introduce **no naming, structural, or behavioral convention of your own**
  without the maintainer's explicit verification. Propositions are welcome, but
  must be agreed before implementation.
- Verify claims about v2.0.1 against the archived `v2.0/` sources before acting
  on them (do not assert what v2 did from memory).

## Working style

- **Do not commit or push until the maintainer approves.** Present changes for
  review first.
- **Sign contributions** -- commits and PR/issue comments -- with a trailing
  line `Contributed by <AGENT>(<MODEL>)`, e.g.
  `Contributed by opencode(claudeopus48)`; disclosure, not disguise.
- Keep `docs/v3.md` read-only: it is the maintainer's plan.
- Rootless podman on the maintainer's host needs `--no-hosts` (the Makefile
  auto-detects podman and adds it).
