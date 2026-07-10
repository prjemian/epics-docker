# v2 -> v3 transition strategy (do not break existing tooling)

Status: **strategy.** How to land the v3 rebuild without breaking existing
consumers of the v2.0.1 tooling and image (e.g. `apstools` CI).

Supersedes the approach in **issue #72**. Also supersedes **PR #73**
(`synApps6.3`): v3 delivers what #73 aimed for (synApps 6.3, `assemble_synApps`
upgrades, branch-based development), so #73 should be closed in favor of this
work, and **#64** and **#72** tracked/closed here.

**Current Docker Hub state (fact):** `prjemian/synapps` has two tags,
`latest` and `2.0.1`, pointing at the **same** v2 digest. So `:2.0.1` is
already published and identical to today's `:latest`. Nothing needs to be
"published" for v2 users; the strategy is about what happens to `:latest`
when v3 ships, and keeping `:2.0.1` immutable as the stable v2 anchor.

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

## Consumer tiers

Known uses of `prjemian/synapps:latest` fall into three tiers (see PR #76):

1. **Controlled, active** -- e.g. [apstools](https://github.com/BCDA-APS/apstools)
   (vendored `iocmgr.sh`). We can PR a tag pin or a migration.
2. **Controlled, legacy** -- e.g. `bluesky_training` (planned for replacement).
   We can pin/migrate on our schedule.
3. **Uncontrolled** -- other repos found by code search that reference
   `prjemian/synapps:latest`. **We cannot notify or change these, and will
   miss some.** Their CI pulls whatever `:latest` is, whenever it next runs.

Tier 3 is decisive: since we cannot reach these users, moving `:latest` to v3
would silently break an unknown set of workflows. The strategy below is built
around that constraint.

## Strategy

### 1. `:latest` stays v2 through a long opt-in window; the flip is a release

v3 is a new **major version** (SemVer): its interface breaks v2 invocations.
`:latest` tracks the newest major version, so moving it to v3 is a deliberate,
breaking act -- not a routine update.

- **`:2.0.1` is the immutable v2 anchor.** Never overwrite it. Any consumer can
  pin `prjemian/synapps:2.0.1` (optionally also publish `:2`) to keep exactly
  today's behavior forever. This is the one-line fix for any break.
- **Publish v3 under explicit, opt-in tags** (`:3.0.0`, `:v3`); `:latest`
  **stays v2**. Adoption is always a deliberate tag change by the consumer.
- **Opt-in / deprecation window: 3-6 months.** During this period v3 is
  available by tag, the deprecation is announced (README, release notes,
  Docker Hub, BCDA/tech-talk), and controlled consumers (tiers 1-2) are pinned
  or migrated.
- **The flip (`:latest` -> v3) ships as a release, not a silent tag move** --
  a **post-`3.0.0` patch** (e.g. `:3.0.1`) so the change is dated and
  discoverable. Do it only after the window, accepting that tier-3 consumers
  we could not reach will break at that point.

Because of tier 3, the flip is "accepted breakage," softened (not prevented):
the window + announcement migrate whom we can reach; the immutable `:2.0.1`
anchor + the in-image legacy notice (below) give everyone else a self-service
one-line fix the moment they hit the break.

### 2. Keep a working `iocmgr.sh` at the old path

- Restore a **compatible `iocmgr.sh` at `main/resources/iocmgr.sh`** that
  targets the **v2 image tag** (`prjemian/synapps:2.0.1`), so live-download
  consumers keep working exactly as before.
- Add a deprecation banner (comment + stderr notice) pointing to the compose
  migration guide.
- Rationale: cheap, fully preserves the historic contract, and decouples "old
  tool keeps working" from "new tool is compose."

### 3. The v3 image intercepts v2 usage with a loud notice

For consumers we cannot reach (tier 3), the v3 image itself makes a v2
workflow fail loudly, stating WHAT failed and HOW to proceed (pin `:2.0.1`
or migrate). The three v2 usage vectors are covered:

- **`/root/bin/gp.sh`, `/root/bin/adsim.sh`** -- stubs that print the notice
  and exit non-zero. v2's `iocmgr.sh` runs `bash /root/bin/<IOC>.sh
  start|status`; these are the operative calls (caqtdm/medm depend on a prior
  successful start, so they are covered transitively).
- **shell-login banner** (`/etc/profile.d/`) -- for v2's `docker run ... bash`.
- **breadcrumb `/opt/synApps/DEPRECATED.txt`** -- v2 direct-path invocations
  (old executable + `st.cmd`) already fail file-not-found because v3 paths
  differ (`/opt/epics/synApps/support/...`); the breadcrumb makes that bare
  error self-explanatory.

(See `resources/legacy_notice.sh`, `resources/legacy_stub.sh`.)

### 4. v3 uses compose as the primary contract

- New consumers use `compose.yaml` (docker/podman, Linux/Mac/Win/Synology).
- Old CLI grammar (`iocmgr.sh start GP gp`) is **not** the v3 contract; the
  legacy `iocmgr.sh` above remains only as a v2 compatibility bridge.

### 5. Migration guide for consumers

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

- **PV contract preserved (key reassurance):** v3 migrates the *same* persona
  customizations (from `v2.0/`) against the same synApps/areaDetector sources.
  So **the PVs a v2 persona provided are unchanged in v3 -- except where the
  upstream library itself changed them** between the pinned versions (e.g. the
  EPICS base bump, motor `R7-2-2` -> `R7-3-1`, or areaDetector template
  evolution). A client's expectations therefore carry over: `gp:UPTIME`,
  `gp:gp:float1`, the general-purpose PVs, `cam1:*`, etc. still resolve once
  pointed at the corresponding v3 persona (with the same prefix). This gives
  transitioning users a concrete way to verify: point existing `caget`/ophyd
  checks at a v3 persona and confirm they still connect.

## Cutover checklist

Already in place (this branch):
- [x] Legacy `iocmgr.sh` restored at `main/resources/` pinned to `:2.0.1`.
- [x] In-image legacy interception (stubs + banner + breadcrumb).
- [x] README breaking-change notice; migration guide (`docs/quickstart.md`,
      this doc).

Cutover steps (in order):
1. Publish v3 under opt-in tags (`:3.0.0`, `:v3`); `:latest` stays v2.
2. Ensure `:2.0.1` (and optionally `:2`) is documented as the v2 anchor
   (already on Docker Hub, same digest as today's `:latest`).
3. Announce the deprecation + opt-in window (README, GitHub release notes,
   Docker Hub, BCDA/tech-talk).
4. Pin/migrate the controlled consumers (apstools, bluesky_training) to a v2
   tag or to v3.
5. After the 3-6 month window: cut a **post-`3.0.0` patch release** that
   repoints `:latest` -> v3 (dated, discoverable; accepted tier-3 breakage).
6. Keep legacy `iocmgr.sh` and the in-image notice indefinitely; they cost
   little and help stragglers.

## Open items

- Confirm the exact v3 tag scheme (ties to `docs/v3_strategy.md` §10).
- Whether to also ship a compose-translating shim named `iocmgr.sh` (deferred;
  current plan keeps the legacy script pointing at the v2 image, not a shim).
