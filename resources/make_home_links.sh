#!/bin/bash
# make_home_links.sh -- create convenience symlinks in the container's default
# working directory (/home), the first place a user lands when they exec into
# the container. Continues the v1/v2 UX where useful trees/scripts are one hop
# from the prompt.
#
# Links are created only for targets that exist, so this script is safe to run
# in epics-runtime (base only) or synapps-runtime (base + synApps) images. It resolves
# real (versioned) paths at build time, so the links survive version bumps.

set -euo pipefail

HOME_DIR="${1:-/home}"
mkdir -p "${HOME_DIR}"
cd "${HOME_DIR}"

# link NAME TARGET -- symlink NAME -> TARGET if TARGET exists.
link() {
    local name="$1" target="$2"
    if [ -e "${target}" ]; then
        ln -sfn "${target}" "${name}"
        echo "# home link: ${name} -> ${target}"
    fi
}

# --- EPICS base ---
link base       "${EPICS_ROOT}/base"
link build-logs "${LOG_DIR}"

# --- aggregated display files (if collected) ---
[ -n "${SCREENS_ROOT:-}" ] && link screens "${SCREENS_ROOT}"

# --- persona launch scripts (whichever the image provides) ---
for p in /usr/local/bin/*.sh; do
    [ -e "${p}" ] || continue
    case "$(basename "${p}")" in
        entrypoint.sh|smoke-test.sh|make_home_links.sh|synapps_prepare.sh) continue ;;
    esac
    link "$(basename "${p}")" "${p}"
done

# --- synApps (only present in synapps-runtime and up) ---
if [ -n "${SUPPORT:-}" ] && [ -d "${SUPPORT}" ]; then
    link support "${SUPPORT}"

    # xxx template: link both the IOC boot dir (holds st.cmd.*) and the module.
    xxx_mod="$(ls -d "${SUPPORT}"/xxx-* 2>/dev/null | head -n1 || true)"
    if [ -n "${xxx_mod}" ]; then
        link xxx      "${xxx_mod}"
        link iocxxx   "${xxx_mod}/iocBoot/iocxxx"
    fi

    # gp customized IOC (if built): link module + its boot dir.
    if [ -d "${SUPPORT}/iocgp" ]; then
        link iocgp_ioc "${SUPPORT}/iocgp"
        gp_boot="$(ls -d "${SUPPORT}"/iocgp/iocBoot/ioc* 2>/dev/null | head -n1 || true)"
        [ -n "${gp_boot}" ] && link iocgp "${gp_boot}"
    fi

    # adsim (custom ADSimDetector) IOC boot dir, if built.
    [ -d "${SUPPORT}/iocadsim" ] && link iocadsim "${SUPPORT}/iocadsim"
fi

echo "# make_home_links: done"
