#!/bin/bash
# legacy_notice.sh -- print the v2->v3 deprecation / breaking-change notice.
#
# Installed in the v3 image and invoked by the legacy interception points
# (the /root/bin/*.sh stubs and the shell-login banner) so a v2-era caller
# sees WHAT failed and HOW to proceed. Also used to generate the breadcrumb
# left at the old v2 paths.

cat <<'EOF'
############################################################################
#  prjemian/synapps -- v2 -> v3 BREAKING CHANGE
#
#  WHAT: This image is v3. The v2 workflow does not work here:
#        - v2 IOC scripts (/root/bin/gp.sh, /root/bin/adsim.sh) are gone
#        - v2 IOC paths (/opt/synApps/iocs/...) have moved
#        v3 supervises IOCs with procServ and is driven by compose;
#        personas are selected with `-e IOC=<persona>`.
#
#  HOW:
#    * Keep the v2 behavior (no changes): pin the old image tag
#          prjemian/synapps:2.0.1
#    * Migrate to v3: see
#          https://github.com/prjemian/epics-docker
#          (docs/v3_transition.md, docs/quickstart.md)
############################################################################
EOF
