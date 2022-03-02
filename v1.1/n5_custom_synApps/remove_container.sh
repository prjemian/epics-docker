#!/bin/bash

# stop and remove docker container named by supplied argument

CONTAINER=$1

if [ "" != "$(which docker ps -a | grep ' ${CONTAINER}$' )" ]; then
    echo -n "stopping container ${CONTAINER} ... "
    docker stop ${CONTAINER}
    if [ "" != "$(which docker ps -a | grep ' ${CONTAINER}$' )" ]; then
        echo -n "removing container ${CONTAINER} ... "
        docker rm ${CONTAINER}
    fi
fi
