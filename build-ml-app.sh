#!/usr/bin/env bash
#
# Copyright (c) 2023 Arm Limited. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause
#

# Script to provide required functionality for Machine Learning (ML) applications
# for the target platforms.

ML_APP_BUILD_IS_VALID=false
ML_APP_TARGET_LIST=("benchmark_model")

# Function to validate whether the build combination is valid
function is_build_valid() {
    ML_APP_BUILD_IS_VALID=false
    local VALID_FS
    local VALID_FILESYSTEMS=("buildroot" "debian")

    for VALID_FS in "${VALID_FILESYSTEMS[@]}"; do
        if [[ "${FILESYSTEM}" =~ ${VALID_FS} ]]; then
            ML_APP_BUILD_IS_VALID=true
            return 0
        fi
    done

    error_echo "ML applications are currently not available for ${FILESYSTEM}."
    info_echo "Build supported only for:"
    for VALID_FS in "${VALID_FILESYSTEMS[@]}"; do
        info_echo "   * ${VALID_FS}"
    done
    return 1
}

# Function to configure and build the ML applications
function do_build() {

    is_build_valid

    local ML_APP_TARGET
    local CMAKE_SOURCE_DIR

    if [[ ${ML_APP_BUILD_IS_VALID} == true ]]; then

        CMAKE_SOURCE_DIR="$(dirname "${BASH_SOURCE[0]}")/files/ml_app/linux"

        # Some information about the config:
        info_echo "Building Machine Learning Application for ${TARGET}"
        info_echo "CMAKE_SOURCE_DIR:       ${CMAKE_SOURCE_DIR}"
        info_echo "CMAKE:                  ${CMAKE}"
        info_echo "ML_APP_BUILD_DIR:       ${ML_APP_BUILD_DIR}"
        info_echo "ML_APP_COMPILER_PREFIX: ${ML_APP_COMPILER_PREFIX}"

        # CMake configuration, specifying location of the sources
        info_echo "Configuring project ${CMAKE_SOURCE_DIR}"

        ML_APP_COMPILER_PREFIX="${ML_APP_COMPILER_PREFIX}"  \
        ${CMAKE} -DTENSORFLOW_SRC="${ML_APP_TFL_SRC}"       \
                 -B"${ML_APP_BUILD_DIR}"                    \
                 -S"${CMAKE_SOURCE_DIR}"

        # Build each target from the list
        for ML_APP_TARGET in "${ML_APP_TARGET_LIST[@]}"; do
            info_echo "Building ${ML_APP_TARGET}"

            ${CMAKE} --build "${ML_APP_BUILD_DIR}"          \
                     --target "${ML_APP_TARGET}"            \
                     --parallel "${PARALLELISM}"
        done
    fi
}

# Clean the build/cache
function do_clean() {
    info_echo "Cleaning build cache at ${ML_APP_BUILD_DIR}."
    if [ -d "${ML_APP_BUILD_DIR}" ]; then
        rm -rf "${ML_APP_BUILD_DIR}"
    fi
}

# Deployment
function do_deploy() {
    info_echo "Copying applications to deployment directory ${DEPLOY_DIR}/${PLATFORM}."
    local ML_APP_TARGET
    local ML_APP_BIN_PATH_LIST
    local ML_APP_BIN_PATH
    for ML_APP_TARGET in "${ML_APP_TARGET_LIST[@]}"; do
        ML_APP_BIN_PATH_LIST="$(realpath $(find "${ML_APP_BUILD_DIR}" -name "${ML_APP_TARGET}" -type f))"
        for ML_APP_BIN_PATH in ${ML_APP_BIN_PATH_LIST}; do
            if [[ -f ${ML_APP_BIN_PATH} ]]; then
                ln -svf "${ML_APP_BIN_PATH}" "$DEPLOY_DIR/$PLATFORM"
            else
                error_echo "Failed to find ${ML_APP_TARGET} in ${ML_APP_BUILD_DIR}"
            fi
        done
    done
}

# Plug into the main framework for the above functions to be called.
source "$(dirname "${BASH_SOURCE[0]}")/framework.sh"
