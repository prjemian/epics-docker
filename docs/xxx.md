# xxx: as-supplied synApps template IOC

The **`xxx`** persona runs the standard [synApps](https://www.aps.anl.gov/BCDA/synApps)
`xxx` beamline IOC **template exactly as supplied upstream** — no local
customizations. It exists to provide the "stock EPICS" reference; for a
ready-to-use simulation IOC with customizations, use the [`gp`](./gp.md)
persona instead.

## Features

- The unmodified synApps `xxx` template IOC (motors, optics, scalers, scan
  records, autosave, iocStats, lua, ...), as shipped by the synApps release.
- `$(PREFIX)UPTIME` and the full template PV set.

## As-supplied prefix (not runtime-settable)

Upstream hard-codes the template's PV prefix (`xxx:`) in `settings.iocsh` and
expects it to be changed at build time via synApps' `changePrefix`. To keep
this persona faithful to "as-supplied," **`xxx` ignores the container
`PREFIX`** and serves PVs under `xxx:`.

If you need a runtime-settable prefix (to run several IOCs, or a custom
prefix), use the [`gp`](./gp.md) persona, which is built for that.

## Quick start

```bash
docker run -d --rm --name iocxxx --net=host -e IOC=xxx prjemian/synapps:latest
caget xxx:UPTIME
```

> On rootless podman add `--no-hosts`.

## Note on completeness

The upstream template's `st.cmd` is meant to be edited for a specific
beamline/hardware. In this generic container it starts with the template's
soft/sim examples and may log warnings for site-specific items it cannot
initialize. That is the honest "as-supplied" behavior — use [`gp`](./gp.md)
for a fully wired simulation IOC.

## See also

- [gp](./gp.md) — customized, runtime-prefix synApps IOC (recommended)
- [synApps module selection](./synapps_modules.md)
