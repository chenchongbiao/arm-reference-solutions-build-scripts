#!/bin/bash

# Copyright (c) 2023, Arm Limited. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

SCRIPT_DIR="$(realpath --no-symlinks "$(dirname "${BASH_SOURCE[0]}")")"
source $SCRIPT_DIR/config/common.config
WORK_DIR="$(dirname "${SCRIPT_DIR}")" #path to the directory into which TC stack is cloned
BUILD_CMD="build_image"
PULL_CMD="pull_image"
RUN_MODEL="run_model"
BLUE="\e[94m"
YELLOW="\e[33m"
RED="\e[31m"
NC="\e[0m"

verify_img()
{
    img_digest_reg="4f51a81610f3f9b4c3b6352b1f0757d7e423e66ef539dcc5d95f20049b85fb58"
    img_digest_local=$(docker images --format "{{.Repository}}:{{.Tag}}:{{.Digest}}" | grep "$DOCKER_REGISTRY/$DOCKER_IMAGE:$TAG" | cut -d":" -f4)
    [ $img_digest_reg == $img_digest_local ] && exit 0
    echo -e "${YELLOW}Image verification failed!! ${NC}" && exit 1
}

pull_img()
{
    docker pull "$DOCKER_REGISTRY/$DOCKER_IMAGE:$TAG" && return 0
    echo -e "${YELLOW}Cannot pull Docker image from Container registry!! ${NC}"
    exit 1
}

build_img()
{
  docker build --network=host --no-cache --build-arg version="$U_VER" -t "$DOCKER_REGISTRY/$DOCKER_IMAGE:$TAG" docker/ && return 0
  echo -e "${RED}ERROR:Docker local build failed ${NC}"
  exit 1
}

if [[ "$1" == "$PULL_CMD" ]]; then

    echo -e "${BLUE}INFO: PULLING DOCKER IMAGE FROM REGISTRY ${NC}"
    pull_img ;
    verify_img ;

elif [[ "$1" == "$BUILD_CMD" ]]; then

    #To build docker image locally
    echo -e "${BLUE}INFO: BUILDING DOCKER IMAGE LOCALLY ${NC}"
    build_img ;

elif [[ "$1" == "$RUN_MODEL" ]]; then

    shift;
    if [ -n "$MODEL_PATH" ] ; then

        echo -e "${BLUE}INFO: RUNNING FVP IN DOCKER CONTAINER ${NC}"

        lic_opts=" -e LM_LICENSE_FILE=$LM_LICENSE_FILE \
              -e ARMLMD_LICENSE_FILE=$ARMLMD_LICENSE_FILE"

        docker run --rm --net=host --mount type=bind,source=$WORK_DIR,target=$WORK_DIR \
            $lic_opts \
            --workdir /$WORK_DIR/run-scripts/tc2/ \
            -v $MODEL_PATH:$MODEL_PATH \
            --ipc=host --env="DISPLAY" -e TERM=$TERM \
            --user $(id -u):$(id -g) --volume="$HOME/.Xauthority:/home/.Xauthority:rw" -v /tmp/.X11-unix:/tmp/.X11-unix -it $DOCKER_REGISTRY/$DOCKER_IMAGE:$TAG $WORK_DIR/run-scripts/tc2/run_model.sh $@
    else
        echo -e "${RED}Please provide model parent directory path ${NC}"
    fi

else

    env_opts=" -e TERM=$TERM \
               -e PLATFORM=$PLATFORM \
               -e FILESYSTEM=$FILESYSTEM \
               -e AVB=$AVB \
               -e TC_GPU=$TC_GPU \
	       -e TC_TARGET_FLAVOR=$TC_TARGET_FLAVOR \
	       -e ARMCLANG_TOOL=$ARMCLANG_TOOL \
	       -e USER=$USER \
	       -e HOME=$HOME \
	       -e DEB_DDK_REPO=$DEB_DDK_REPO \
	       -e DEB_DDK_VERSION=$DEB_DDK_VERSION \
	       -e GPU_DDK_REPO=$GPU_DDK_REPO \
	       -e GPU_DDK_VERSION=$GPU_DDK_VERSION \
	       -e LM_LICENSE_FILE=$LM_LICENSE_FILE \
	       -e ARMLMD_LICENSE_FILE=$ARMLMD_LICENSE_FILE \
               -e ARM_PRODUCT_DEF=$ARM_PRODUCT_DEF"

    if [ $PARALLELISM ];then
        env_opts+=" -e PARALLELISM=$PARALLELISM"
    fi

    #netrc file contains artifactory credentials for cloning ddk code and PATH variable has armclang tool path
    if [[ $FILESYSTEM == "debian" ]]; then
         env_opts+=" -e PATH=$PATH \
                     -v $HOME/.netrc:$HOME/.netrc"
    fi
    #Start docker container
    echo -e "${BLUE}INFO: ENTERING DOCKER CONTAINER ${NC}"

    docker run --rm --net=host --mount type=bind,source=$WORK_DIR,target=$WORK_DIR \
      $env_opts \
      -v $HOME:$HOME \
      -v $SSH_AUTH_SOCK:/ssh.socket -e SSH_AUTH_SOCK=/ssh.socket \
      --workdir /$SCRIPT_DIR \
      --user $(id -u):$(id -g) -it $DOCKER_REGISTRY/$DOCKER_IMAGE:$TAG ${PWD}/$@

    echo -e "${BLUE}INFO: EXITING DOCKER CONTAINER ${NC}"
fi
