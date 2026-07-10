# Announcement: prjemian/synapps v3 (breaking change for v2 users)

*A ready-to-post notice for known consumers of the `prjemian/synapps` image.*

## Summary

A new major version, **v3**, of the `prjemian/synapps` EPICS container image
is being released. **v3 is not backward compatible with the v2 workflow.**

If you use this image, please read the "What you need to do" section below.
Most users need to change **one line**: pin the image tag.

## What changed (and why)

v3 is a from-scratch rebuild that is smaller, easier to maintain, portable
across container runtimes (docker/podman) and host OSes, and driven by a
declarative `compose.yaml`. As part of that:

- IOCs are supervised by **procServ** (not `screen`).
- IOCs are selected as **personas** at container start: `-e IOC=<persona>`
  (e.g. `gp`, `adsim`) with a runtime PV prefix `-e PREFIX=<prefix:>`.
- v3 expands the set of personas: `softioc`, `xxx`, `gp`, `adsim`, `adcsim`,
  `adurl`, `adpva`.

Because the command interface changed, the **v2 workflow does not work against
a v3 image**:

- `iocmgr.sh`, `gp.sh`/`adsim.sh`, and the old in-image paths
  (`/opt/synApps/iocs/...`) are gone or moved.
- A v3 image detects v2-style usage and prints a notice telling you what
  happened and how to proceed.

## Timeline

- **Now -> for the next 3-6 months:** `prjemian/synapps:latest` continues to
  point at **v2**. Nothing breaks yet. v3 is available under opt-in tags
  (`:3.0.0`, `:v3`) so you can try and adopt it on your own schedule.
- **After that window:** a patch release will repoint `:latest` to **v3**.
  From that point, anything still using the v2 workflow via `:latest` will
  break.

## What you need to do

### To stay on v2 (no other changes)

Pin the immutable v2 tag wherever you reference the image:

```
prjemian/synapps:2.0.1
```

Do **not** rely on `:latest` (it will move to v3). `:2.0.1` will never be
overwritten. If you pull from an internal registry, pin the `2.0.1` tag there
(e.g. `<your-registry>/synapps:2.0.1`).

**If you vendored `iocmgr.sh`** (a copy committed in your repo), it hard-codes
`prjemian/synapps:latest`. Change that to `:2.0.1` (or migrate to v3).

### To migrate to v3

1. Switch your image reference to a v3 tag (`:3.0.0` or `:v3`).
2. Replace the `iocmgr.sh` workflow with `compose.yaml` or `docker run`:

   | v2 | v3 |
   | --- | --- |
   | `iocmgr.sh start GP gp` | `docker run -d --rm --name iocgp --net=host -e IOC=gp -e PREFIX=gp: <image>:3.0.0` |
   | `iocmgr.sh start ADSIM ad` | `docker run -d --rm --name iocad --net=host -e IOC=adsim -e PREFIX=ad: <image>:3.0.0` |

   or with compose:

   ```
   GP_PREFIX=gp docker compose --profile host up -d gp-host
   ```

3. Your **PVs are preserved**: v3 provides the same persona PVs as v2, except
   where an upstream library changed them. Point your existing
   `caget`/PyEpics/ophyd checks at the v3 persona (same prefix) to confirm
   they still connect -- e.g. `gp:UPTIME`, `gp:gp:float1`, `ad:cam1:Acquire_RBV`.

See the [migration guide](./v3_transition.md) and
[quick start](./quickstart.md) for details.

## Questions / problems

Open an issue at https://github.com/prjemian/epics-docker/issues .

---

Contributed by opencode(claudeopus48)
