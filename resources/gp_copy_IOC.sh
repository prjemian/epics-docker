#!/bin/bash

echo "# running: $(readlink -f ${0})"
source "${HOME}/.bash_aliases"

echo "# ................................ copy XXX to GP"
"${RESOURCES}/tarcopy.sh" "${XXX}" "${GP}"
cd "${GP}"
/bin/rm -rf ./.git* ./.ci* ./.travis.yml
make -C "${GP}" clean
