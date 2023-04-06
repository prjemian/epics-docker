#!/bin/bash

echo "# running: $(readlink -f ${0})"
source "${HOME}/.bash_aliases"

echo "# ................................ (re)compile" 2>&1 | tee -a "${LOG_FILE}"
make -C "${GP}"
