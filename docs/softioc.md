# softioc: EPICS base softIoc

The **`softioc`** persona is the simplest IOC — EPICS base
[`softIoc`](https://epics.controls.anl.gov/) with a tiny demo database. It is
the **default persona** and needs only EPICS base (it runs from the
`epics-runtime` image layer as well as the full image).

Use it for a minimal, fast EPICS server: a quick connectivity/liveness target
for client development and CI, with no synApps or areaDetector overhead.

Runtime-settable PV prefix (default `ioc:`); no recompilation to change it.

## Features

A small demo database under your chosen prefix (`$(PREFIX)`):

PV | type | purpose
--- | --- | ---
`$(PREFIX)UPTIME` | calc | seconds since IOC start (1 Hz) — quick liveness check
`$(PREFIX)IOC_NAME` | stringout | persona name (`softioc`)
`$(PREFIX)float1` | ao | a scratch analog value

`softIoc`'s command-line options can be passed via `IOC_ARGS`.

## Quick start

```bash
docker run -d --rm --name iocsoft --net=host \
    -e IOC=softioc -e PREFIX=demo: \
    prjemian/synapps:latest

caget demo:UPTIME
```

> On rootless podman add `--no-hosts`. Use a unique prefix per IOC.

## Using compose

```bash
PREFIX=demo docker compose --profile host  up -d softioc-host    # or
PREFIX=demo docker compose --profile ports up -d softioc-ports
```

## See also

- [configuration](./configuration.md) — environment variables, networking
- [gp](./gp.md) — a full synApps IOC when you need more than base
