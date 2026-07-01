# v2 -> v3 transition strategy (do not break existing tooling)

Status: **strategy (draft).** How to land the v3 rebuild without breaking
existing consumers of the v2.0.1 tooling and image (e.g. `apstools` CI).

Supersedes the approach in **issue #72**. Also supersedes **PR #73**
(`synApps6.3`): v3 delivers what #73 aimed for (synApps 6.3, `assemble_synApps`
upgrades, branch-based development), so #73 should be closed in favor of this
work, and **#64** and **#72** tracked/closed here.

## What existing consumers depend on

Two independent breakage surfaces:

1. **`iocmgr.sh` fetched from `main` at run time.** The v2 README instructs
   users to `wget https://raw.githubusercontent.com/prjemian/epics-docker/main/resources/iocmgr.sh`.
   - The v3 archive move relocated it to `v2.0/resources/iocmgr.sh`, so once v3
     becomes `main`, the old URL **404s** and live-download users break.
   - Consumers who *vendored* the script at a pinned commit (e.g. apstools'
     `.github/scripts/iocmgr.sh`) are unaffected by URL changes -- but see #2.

2. **The `prjemian/synapps:latest` image.** Both `iocmgr.sh` and apstools use
   `:latest`. v3 changes the image's internal contract:
   - IOC supervision is now **procServ**, not `screen`.
   - The run model is **compose-first**; `iocmgr.sh`'s `docker run ... bash` +
     `docker exec ... gp.sh start` assumptions no longer hold.
   So even a vendored `iocmgr.sh` would break against a v3 `:latest`.

Because v3 makes a clean break to compose (decision D3), we must actively
preserve compatibility rather than assume it.

## Strategy

### 1. Freeze `:latest` at v2 during the transition

- **`prjemian/synapps:latest` keeps pointing at the v2 image** until an
  announced cutover.
- Publish v3 under **explicit, opt-in tags** first, e.g. `:3.0.0`, `:v3`, and
  version-descriptive tags. Early adopters choose v3 deliberately.
- Pin the current image so it never disappears: publish/keep
  **`prjemian/synapps:2.0.1`** (and `:2`), matching the v2 recipe.
- Move `:latest` -> v3 **only after** a deprecation window and a published
  migration guide.

### 2. Keep a working `iocmgr.sh` at the old path

- Restore a **compatible `iocmgr.sh` at `main/resources/iocmgr.sh`** that
  targets the **v2 image tag** (`prjemian/synapps:2.0.1`), so live-download
  consumers keep working exactly as before.
- Add a deprecation banner (comment + stderr notice) pointing to the compose
  migration guide.
- Rationale: cheap, fully preserves the historic contract, and decouples "old
  tool keeps working" from "new tool is compose."

### 3. v3 uses compose as the primary contract

- New consumers use `compose.yaml` (docker/podman, Linux/Mac/Win/Synology).
- Old CLI grammar (`iocmgr.sh start GP gp`) is **not** the v3 contract; the
  legacy `iocmgr.sh` above remains only as a v2 compatibility bridge.

### 4. Migration guide for consumers

Provide a short guide covering, per consumer type:

- **Live-download users:** no change required short-term (old `iocmgr.sh` +
  `:latest`=v2 still work); recommended path = pin to `:2.0.1` or migrate to
  compose.
- **Vendored-`iocmgr.sh` users (e.g. apstools):** pin their image to
  `prjemian/synapps:2.0.1` to stay on v2, OR adopt v3 via compose. Map the old
  CLI to compose:

  | v2 command | v3 (compose) equivalent |
  | --- | --- |
  | `iocmgr.sh start GP gp` | `GP_PREFIX=gp docker compose --profile host up -d gp-host` |
  | `iocmgr.sh start ADSIM ad` | `ADSIM_PREFIX=ad docker compose --profile host up -d adsim-host` |
  | `docker exec iocgp caget gp:UPTIME` | unchanged (same PV contract) |

- **Naming change for the sim detector (small hurdle):** v2 exposed the
  detector as persona `ADSIM` (container `iocad`, prefix `ad:`). v3 names the
  persona **`adsim`** with default prefix `adsim:`. Because the prefix is a
  run-time choice, a v2-style consumer simply sets `PREFIX=ad:` (or
  `ADSIM_PREFIX=ad`) to reproduce the old `ad:` names. The **PV suffix
  contract is preserved**: one camera named `cam1:`, so `ad:cam1:Acquire_RBV`
  still resolves. Vendored `iocmgr.sh` (pinned to the v2 image) keeps the old
  `ADSIM`/`iocad`/`ad:` flow unchanged.

- **PV contract preserved:** v3 gp keeps `gp:UPTIME`, `gp:gp:float1`, the
  general-purpose PVs, and runtime prefix -- so client-side test assertions
  continue to pass once pointed at a v3 gp IOC.

## Cutover checklist (when v3 is ready to become default)

1. v3 images published and validated under opt-in tags.
2. Migration guide published; deprecation notices live in legacy `iocmgr.sh`.
3. `prjemian/synapps:2.0.1` (and `:2`) pinned and documented.
4. Announce the cutover window to known consumers (apstools, bluesky_training).
5. Repoint `:latest` -> v3.
6. Keep legacy `iocmgr.sh` at `main/resources/` (targeting `:2.0.1`) for a
   further grace period; only then consider removing.

## Open items

- Confirm the exact v3 tag scheme (ties to `docs/v3_strategy.md` §10).
- Decide the deprecation window length.
- Whether to also ship a compose-translating shim named `iocmgr.sh` (deferred;
  current plan keeps the legacy script pointing at the v2 image, not a shim).
