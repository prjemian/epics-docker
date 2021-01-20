#!/bin/bash

CONTAINER=$1
INFO=`docker ps -a | grep " ${CONTAINER}$"`

if [ "" != "${INFO}" ]; then
    echo -n "stopping container ${CONTAINER} ... "
    docker stop ${CONTAINER}
    echo -n "removing container ${CONTAINER} ... "
    docker rm ${CONTAINER}
fi
