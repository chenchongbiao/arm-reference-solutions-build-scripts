#!/bin/bash

# Copyright (c) 2022-2023 Arm Limited. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

for_each_build_script() {
    # Scripts are ordered so that components that depends on others are built last
    local scripts=(
        "build-scp.sh"
        "build-hafnium.sh"
        "build-linux.sh"
        "build-optee-os.sh"
        "build-optee-test.sh"
        "build-u-boot.sh"
        "build-trusted-services.sh"
   )

if [ -d "$SRC_DIR/trusty" ]; then
	scripts+=(
	    "build-trusty.sh"
            "build-tfa-trusty.sh"
            "build-rss-trusty.sh"
    )
fi

    scripts+=(
        "build-tfa.sh"
        "build-rss.sh"
        "build-flash-image.sh"
    )

    case "$FILESYSTEM" in
    ("buildroot")
        scripts+=(
            "build-ml-app.sh"
            "build-buildroot.sh"
        )
        ;;
    ("android-"*)
        scripts+=(
            "build-android.sh"
        )
        ;;
    ("debian")
        scripts+=(
            "build-debian.sh"
        )
        if [ "$TC_GPU" == "hwr" ]; then
            info_echo "Debian will be built with Mali DDK!"
            scripts+=("build-debian-ddk.sh")
        elif [ "$TC_GPU" == "hwr-prebuilt" ]; then
            error_echo "Debian is not supporting hwr-prebuilt"
	    exit 1
        else
            info_echo "Debian will be built without Mali DDK!"
        fi
        ;;
    ("deepin")
        scripts+=(
            "build-deepin.sh"
        )
        ;;
    ("none")
         ;;
    (*) false
    esac

    local script
    for script in "${scripts[@]}" ; do
        echo "Executing command $@ for $script..."
        "$SCRIPT_DIR/$script" -f "$FILESYSTEM" -p "$PLATFORM" -t "$TC_TARGET_FLAVOR"  -g $TC_GPU "$@" || exit 1
    done
}

do_build()
{
    # create a deploy directory
    mkdir -p $DEPLOY_DIR/$PLATFORM
    for_each_build_script build
    for_each_build_script deploy
}

do_all() {
    do_clean
    do_build
}

do_clean() {
    for_each_build_script clean
    # Empty deploy directory
    info_echo "Cleaning deploy directory"
    rm -rf $DEPLOY_DIR/$PLATFORM/*
}


source "$(dirname ${BASH_SOURCE[0]})/framework.sh"
