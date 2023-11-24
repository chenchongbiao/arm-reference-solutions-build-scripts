#!/usr/bin/env bash

# Copyright (c) 2021-2023 Arm Limited. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

readonly FILESYSTEM_OPTIONS=(
    "buildroot"
    "android-fvp"
    "android-fpga"
    "debian"
    "deepin"
)

readonly PLATFORM_OPTIONS=(
    "tc2"
)

readonly TC_TARGET_FLAVOR_OPTIONS=(
    "fvp"
    "fpga"
)

readonly TC_GPU_OPTIONS=(
    "swr"
    "hwr"
    "hwr-prebuilt"
)

AVB_DEFAULT=false
TC_GPU_DEFAULT=none
TC_TARGET_FLAVOR_DEFAULT=fvp

readonly CMD_DEFAULT=( "build" )
CMD_OPTIONS=("build" "patch" "clean" "deploy" "with_reqs")
if [[ $(basename $0) == "build-all.sh" ]]; then
    CMD_OPTIONS=("build" "package" "clean" "all" "deploy")
fi

print_usage() {
    echo -e "${BOLD}Usage:"
    echo -e "    $0 ${CYAN}-f FILESYSTEM [-p PLATFORM] [-t TC_TARGET_FLAVOR] -g [TC_GPU] [CMD...]$NORMAL"
    echo
    echo "FILESYSTEM:"
    local s
    for s in "${FILESYSTEM_OPTIONS[@]}" ; do
        echo "    $s"
    done
    echo
    echo "TC_GPU:"
    local s
    for s in "${TC_GPU_OPTIONS[@]}" ; do
        echo "    $s"
    done
    echo
    echo "TC_TARGET_FLAVOR:"
    local s
    for s in "${TC_TARGET_FLAVOR_OPTIONS[@]}" ; do
        echo "    $s"
    done
    echo
    echo "PLATFORM (default is \"$PLATFORM_DEFAULT\"):"
    for s in "${PLATFORM_OPTIONS[@]}" ; do
        echo "    $s"
    done
    echo
    echo "CMD (default is \"${CMD_DEFAULT[@]}\"):"
    local s_maxlen="0"
    for s in "${CMD_OPTIONS[@]}" ; do
        local i="${#s}"
        (( i > s_maxlen )) && s_maxlen="$i"
    done
    for s in "${CMD_OPTIONS[@]}" ; do
        if [[ "$s" != "with_reqs" ]];then
            local -n desc="DO_DESC_$s"
            [[ "$s" == "build" ]] && printf "    %- ${s_maxlen}s    %s\n" "$s [with_reqs]" "${desc:+($desc)}" || printf "    %- ${s_maxlen}s    %s\n" "$s" "${desc:+($desc)}"
        fi
    done
}

if [[ -z "${TC_GPU:-}" ]] ; then
    TC_GPU=$TC_GPU_DEFAULT
fi

if [[ -z "${TC_TARGET_FLAVOR:-}" ]] ; then
    TC_TARGET_FLAVOR=$TC_TARGET_FLAVOR_DEFAULT
fi

CMD=( "${CMD_DEFAULT[@]}" )
while getopts "p:f:a:t:g:h" opt; do
    case $opt in
    ("p")
        PLATFORM="$OPTARG"
        ;;
    ("f")
        FILESYSTEM="$OPTARG"
        ;;
    ("a")
        AVB=true
        ;;
    ("t")
        TC_TARGET_FLAVOR="$OPTARG"
	;;
    ("g")
        TC_GPU="$OPTARG"
	;;
    ("?")
        print_usage >&2
        exit 1
        ;;
    ("h")
        print_usage
        exit 0
    esac
done
shift $((OPTIND-1))

if [[ -z "${PLATFORM:-}" ]] ; then
    echo "ERROR: Mandatory -p PLATFORM not given!" >&2
    echo "" >&2
    print_usage >&2
    exit 1
fi
in_haystack "$PLATFORM" "${PLATFORM_OPTIONS[@]}" ||
    die "invalid PLATFORM: $PLATFORM"
readonly PLATFORM

if [[ -z "${FILESYSTEM:-}" ]] ; then
    echo "ERROR: Mandatory -f FILESYSTEM not given!" >&2
    echo "" >&2
    print_usage >&2
    exit 1
fi
in_haystack "$FILESYSTEM" "${FILESYSTEM_OPTIONS[@]}" ||
    die "invalid FILESYSTEM: $FILESYSTEM"
readonly FILESYSTEM

if [[ -z "${TC_TARGET_FLAVOR:-}" ]] ; then
    echo "ERROR: Mandatory -t TC_TARGET_FLAVOR not given!" >&2
    echo "" >&2
    print_usage >&2
    exit 1
fi
in_haystack "$TC_TARGET_FLAVOR" "${TC_TARGET_FLAVOR_OPTIONS[@]}" ||
    die "invalid TC_TARGET_FLAVOR: $TC_TARGET_FLAVOR"
readonly TC_TARGET_FLAVOR

# `TC_GPU` definition is mandatory only for Android builds. It could well be
# defined for other filesystems but we don't enforce the values here but
# instead leave the resposibility to the filesystem-specific script which
# build the GPU related software components.
if [[ "${FILESYSTEM}" =~ "android" ]]; then
    if [[ -z "${TC_GPU:-}" ]] ; then
        echo "ERROR: Mandatory -g TC_GPU not given!" >&2
        echo "" >&2
        print_usage >&2
        exit 1
    fi
    in_haystack "$TC_GPU" "${TC_GPU_OPTIONS[@]}" ||
        die "invalid TC_GPU: $TC_GPU"
    readonly TC_GPU
fi

if [[ -z "${AVB:-}" ]] ; then
    AVB=$AVB_DEFAULT
fi

# Load config for specified platforn
source $SCRIPT_DIR/config/$PLATFORM.config

if [[ "$#" -ne 0 ]] ; then
    CMD=( "$@" )
fi
for cmd in "${CMD[@]}" ; do
    in_haystack "$cmd" "${CMD_OPTIONS[@]}" || die "invalid CMD: $cmd"
done
readonly CMD
