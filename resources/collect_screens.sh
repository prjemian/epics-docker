#!/bin/bash
# collect_screens.sh -- gather operator-interface (display) files by format
# into one directory per format (v3 goal: "gather all in one directory for
# each format"), WITHOUT modifying the files in their module locations.
#
# Copies to the all-in-one directories first, then applies the gp display
# fixes to the COPIES only (the as-supplied module screens stay pristine).
# Screens use the $(P) macro so a host-side client launches with the runtime
# prefix, e.g.:
#   medm   -x -macro "P=gp:" gp.adl
#   caqtdm -macro "P=gp:"     gp.ui
#
# Handles multiple display formats and the GRAPHICS assets they reference
# (.gif/.png/... ) -- images are copied into each format dir so screens render.
#
# Layout:
#   ${SCREENS_ROOT}/adl/   MEDM
#   ${SCREENS_ROOT}/ui/    caQtDM
#   ${SCREENS_ROOT}/opi/   CSS BOY
#   ${SCREENS_ROOT}/bob/   Phoebus
#   ${SCREENS_ROOT}/edl/   EDM
#   (graphics copied into each of the above)
#
# Usage: collect_screens.sh SCREENS_ROOT SEARCH_DIR [SEARCH_DIR ...]

set -euo pipefail
SCREENS_ROOT="${1:?}"; shift
SEARCH_DIRS=("$@")

# Display-file formats to collect (override with SCREEN_FORMATS env).
SCREEN_FORMATS="${SCREEN_FORMATS:-adl ui opi bob edl}"
# Graphics/assets referenced by screens (override with SCREEN_GRAPHICS env).
SCREEN_GRAPHICS="${SCREEN_GRAPHICS:-gif png jpg jpeg bmp svg xpm}"

# skip these non-screen files by basename
skip_name() {
    case "$1" in Makefile|README|README.md|LICENSE) return 0 ;; *) return 1 ;; esac
}

copy_ext() {  # ext  destdir
    local ext="$1" dest="$2" src f
    mkdir -p "${dest}"
    for src in "${SEARCH_DIRS[@]}"; do
        [ -d "${src}" ] || continue
        while IFS= read -r -d '' f; do
            skip_name "$(basename "${f}")" && continue
            cp -f "${f}" "${dest}/" 2>/dev/null || true
        done < <(find "${src}" -type f -name "*.${ext}" -not -path '*/all_*' -print0 2>/dev/null)
    done
}

# 1) collect each screen format into its own dir
for ext in ${SCREEN_FORMATS}; do
    copy_ext "${ext}" "${SCREENS_ROOT}/${ext}"
done

# 2) graphics: store ONCE in a shared dir, then symlink each image into every
#    format dir. Screens reference images by bare filename (same-dir), so each
#    format dir needs the name present -- but the bytes are stored only once
#    (deduplicated). Recovers the ~4x graphics duplication.
graphics_dir="${SCREENS_ROOT}/graphics"
mkdir -p "${graphics_dir}"
for gext in ${SCREEN_GRAPHICS}; do
    for src in "${SEARCH_DIRS[@]}"; do
        [ -d "${src}" ] || continue
        find "${src}" -type f -name "*.${gext}" -not -path '*/all_*' \
            -exec cp -f {} "${graphics_dir}/" \; 2>/dev/null || true
    done
done
# link the shared graphics into each format dir (relative symlinks)
for ext in ${SCREEN_FORMATS}; do
    dest="${SCREENS_ROOT}/${ext}"
    [ -d "${dest}" ] || continue
    for img in "${graphics_dir}"/*; do
        [ -f "${img}" ] || continue
        ln -sfn "../graphics/$(basename "${img}")" "${dest}/$(basename "${img}")"
    done
done

# 3) fixes applied to the COLLECTED COPIES only
#    #68 replaceable prefix: literal xxx: -> $(P)
#    #59 orient9 related-display entry missing O= macro
#    #69 mybusy1 related-display points at "mybusy" -> "mybusy1"
for ext in ${SCREEN_FORMATS}; do
    for f in "${SCREENS_ROOT}/${ext}"/*; do
        [ -f "${f}" ] || continue
        case "${f}" in *.gif|*.png|*.jpg|*.jpeg|*.bmp|*.svg|*.xpm) continue ;; esac
        sed -i 's/xxx:/$(P)/g; s/ioc=xxx/ioc=$(P)/g' "${f}"
        sed -i 's/PM=$(P),mTTH=SM1,mTH=SM2,mCHI=SM3,mPHI=SM4/PM=$(P),O=_0,mTTH=SM1,mTH=SM2,mCHI=SM3,mPHI=SM4/g' "${f}"
        sed -i 's/R=mybusy\([^0-9]\)/R=mybusy1\1/g' "${f}"
    done
done

# summary
echo "# collect_screens -> ${SCREENS_ROOT}"
for ext in ${SCREEN_FORMATS}; do
    n="$(find "${SCREENS_ROOT}/${ext}" -type f 2>/dev/null | wc -l)"
    echo "#   ${ext}: ${n} files (incl. graphics)"
done
