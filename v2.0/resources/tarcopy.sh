#!/bin/bash

# tarcopy source_dir target_dir
#
# Copy the source_dir to the target_dir using tar

function tarcopy {
    if [ "$#" != "2" ]; then
        echo "usage: tarcopy source_dir target_dir"
    else
        pushd "$1/.."
        parent="$(readlink -m $2/..)"
        tar cf - "$(basename $1)" | (cd "${parent}" && tar xf -)
        cd "${parent}"
        if [ "$(basename $1)" != "$(basename $2)" ]; then
            mv  "$(basename $1)" "$(basename $2)"
        fi
        popd
    fi
}

if [ "${#}" -gt "0" ]; then
    # If arguments supplied, call the function.
    # When NO arguments supplied, just loads the function.
    tarcopy $@
fi
