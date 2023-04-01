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
        mv  "$(basename $1)" "$(basename $2)"
        popd
    fi
}
