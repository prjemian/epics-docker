#!/bin/bash
# legacy_stub.sh -- installed as /root/bin/gp.sh and /root/bin/adsim.sh in the
# v3 image. v2's iocmgr.sh runs `bash /root/bin/<IOC>.sh start|status`; those
# paths do not exist in v3. These stubs intercept that call, print the
# deprecation notice (WHAT/HOW), and exit non-zero so the failure is loud.

/usr/local/bin/legacy_notice.sh >&2
echo "" >&2
echo "ERROR: '$0 $*' is a v2 workflow; not supported by this v3 image." >&2
exit 70   # EX_SOFTWARE
