#!/bin/bash
# prune_support.sh -- remove non-runtime cruft from the built synApps support
# tree, so the runtime image copies only what an IOC needs at run time.
#
# Removed (verified not needed to boot any persona):
#   .git dirs        - VCS metadata
#   *.a              - static libraries (already linked into .so/binaries)
#   *.o              - intermediate object files
#   O.* dirs         - per-arch build-output directories (objects, temporaries)
#
# Kept: bin/, lib/*.so, dbd/, db/ (+ templates/.req/.substitutions), iocBoot,
#       op/ screens, and the customized ioc* boot dirs.
#
# Run this in the BUILDER stage, before the runtime image COPYs the tree, so
# the removed files never persist in a shipped layer.
#
# Usage: prune_support.sh SUPPORT

set -euo pipefail
SUPPORT="${1:?usage: prune_support.sh SUPPORT}"

before="$(du -sh "${SUPPORT}" 2>/dev/null | cut -f1)"

find "${SUPPORT}" -name .git -type d -prune -exec rm -rf {} + 2>/dev/null || true
find "${SUPPORT}" -name "*.a" -delete 2>/dev/null || true
find "${SUPPORT}" -name "*.o" -delete 2>/dev/null || true
find "${SUPPORT}" -type d -name "O.*" -prune -exec rm -rf {} + 2>/dev/null || true

after="$(du -sh "${SUPPORT}" 2>/dev/null | cut -f1)"
echo "# prune_support: ${SUPPORT} ${before} -> ${after}"
