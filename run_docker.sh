#!/bin/bash

# Copyright (c) 2023, Arm Limited. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

DOCKER_IMAGE="tc_image"
TAG=20.04 #Ubuntu version
SCRIPT_DIR="$(realpath --no-symlinks "$(dirname "${BASH_SOURCE[0]}")")"
WORK_DIR="$(dirname "${SCRIPT_DIR}")" #path to the directory into which TC stack is cloned
BUILD_CMD="build_image"
BLUE="\e[94m"
NC="\e[0m"

if [[ "$1" == "$BUILD_CMD" ]]; then

    #To build docker image locally
    echo -e "${BLUE}INFO: BUILDING DOCKER IMAGE ${NC}"
    docker build --build-arg version=$TAG -t $DOCKER_IMAGE:$TAG docker/

else

    env_opts=" -e TERM=$TERM \
               -e PLATFORM=$PLATFORM \
               -e FILESYSTEM=$FILESYSTEM \
               -e AVB=$AVB"

    if [ $PARALLELISM ];then
        env_opts+=" -e PARALLELISM=$PARALLELISM"
    fi

    #Start docker container
    echo -e "${BLUE}INFO: ENTERING DOCKER CONTAINER ${NC}"
    docker run --rm --mount type=bind,source=$WORK_DIR,target=$WORK_DIR \
    $env_opts \
    --workdir /$SCRIPT_DIR \
    --user $(id -u):$(id -g) -it $DOCKER_IMAGE:$TAG $@
    echo -e "${BLUE}INFO: EXITING DOCKER CONTAINER ${NC}"
fi
