#!/bin/bash

# Copyright (c) 2023, Arm Limited. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

DOCKER_IMAGE="tc_image"
TAG=20.04 #Ubuntu version
SCRIPT_DIR="$(realpath --no-symlinks "$(dirname "${BASH_SOURCE[0]}")")"
WORK_DIR="$(dirname "${SCRIPT_DIR}")" #path to the directory into which TC stack is cloned
BUILD_CMD="build_image"
RUN_MODEL="run_model"
BLUE="\e[94m"
NC="\e[0m"

if [[ "$1" == "$BUILD_CMD" ]]; then

    #To build docker image locally
    echo -e "${BLUE}INFO: BUILDING DOCKER IMAGE ${NC}"
    docker build --build-arg version=$TAG --no-cache -t $DOCKER_IMAGE:$TAG docker/

elif [[ "$1" == "$RUN_MODEL" ]];then

   shift;
   echo -e "${BLUE}INFO: RUNNING FVP IN DOCKER CONTAINER ${NC}"

   lic_opts=" -e LM_LICENSE_FILE=$LM_LICENSE_FILE \
              -e ARMLMD_LICENSE_FILE=$ARMLMD_LICENSE_FILE"

   docker run --rm --net=host --mount type=bind,source=$WORK_DIR,target=$WORK_DIR \
   $lic_opts \
   --workdir /$WORK_DIR/run-scripts/tc2/ \
   --ipc=host --env="DISPLAY" -e TERM=$TERM \
   --user $(id -u):$(id -g) --volume="$HOME/.Xauthority:/home/.Xauthority:rw" -v /tmp/.X11-unix:/tmp/.X11-unix -it $DOCKER_IMAGE:$TAG $WORK_DIR/run-scripts/tc2/run_model.sh $@

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
    --user $(id -u):$(id -g) -it $DOCKER_IMAGE:$TAG $PWD/$@

    echo -e "${BLUE}INFO: EXITING DOCKER CONTAINER ${NC}"
fi
