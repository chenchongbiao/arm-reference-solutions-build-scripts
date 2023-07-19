#!/usr/bin/env bash
#
# Copyright (c) 2023 Arm Limited. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause
#

# Script to provide required functionality for Machine Learning (ML) applications
# for the target platforms.

# Should the ML applications be built or not.
ML_APP_BUILD_IS_VALID=false

# Target applications we want to build by default.
ML_APP_TARGET_LIST=("benchmark_model")

# Function to validate whether the build combination is valid.
function is_build_valid() {
    ML_APP_BUILD_IS_VALID=false
    # Filesystems that ML applications support.
    declare -r VALID_FILESYSTEMS=("buildroot" "debian")
    local VALID_FS
    for VALID_FS in "${VALID_FILESYSTEMS[@]}"; do
        if [[ "${FILESYSTEM}" =~ ${VALID_FS} ]]; then
            ML_APP_BUILD_IS_VALID=true
            return 0
        fi
    done

    error_echo "ML applications unavailable to be built for ${FILESYSTEM}."
    info_echo "Valid filesystems are:"
    for VALID_FS in "${VALID_FILESYSTEMS[@]}"; do
        info_echo "   * ${VALID_FS}"
    done
    return 1
}

# Download the sample model (tflite) files.
# @param[in]  install-prefix    Location where the models should be
#                               downloaded to.
# @param[in]  target            Expected to be either "clean" or "install"
function sample_tflite_model_files() {

    if [[ $# -ne 2 ]]; then
        error_echo "Usage: sample_tflite_model_files \"/path/prefix\" \"clean|install\""
        return
    fi
    local DIR_PREFIX=${1}
    local MODEL_FILES_COMMAND=${2}

    # Validate prefix
    if [[ -z "${DIR_PREFIX// }" ]]; then
        error_echo "Path prefix cannot be empty."
        return
    fi

    # Make sure the config is sensible
    local NUM_URLS=${#ML_APP_SAMPLE_MODEL_URL_LIST[@]}
    local NUM_NAMES=${#ML_APP_SAMPLE_MODEL_NAME_LIST[@]}

    if [[ ${NUM_NAMES} != "${NUM_URLS}" ]]; then
        error_echo "Invalid configuration for ML model URLs."
        return
    fi

    info_echo "${NUM_URLS} models to ${MODEL_FILES_COMMAND}." \
              "Path prefix: ${DIR_PREFIX}"

    if [[ ! -d ${DIR_PREFIX} ]]; then
        mkdir -p "${DIR_PREFIX}"
    fi

    # Iterate over the lists and clean/download-to the required prefix path
    local I
    for I in $(seq 0 "$(( "${NUM_URLS}" - 1 ))"); do
        local MODEL_URL=${ML_APP_SAMPLE_MODEL_URL_LIST[$I]}
        local MODEL_NAME=${ML_APP_SAMPLE_MODEL_NAME_LIST[$I]}

        if [[ "${MODEL_FILES_COMMAND}" =~ "install" ]]; then
            info_echo "Checking for ${MODEL_NAME}..."
            local WGET_ARGS=(
                "${MODEL_URL}"
                "--show-progress"
                "--no-clobber"
                "--output-document ${DIR_PREFIX}/${MODEL_NAME}"
            )
            info_echo "wget ${WGET_ARGS[*]}"
            if [[ $(eval wget "${WGET_ARGS[*]}") -ne 0 ]]; then
                warn_echo "${MODEL_NAME} not downloaded."
            fi
        elif [[ "${MODEL_FILES_COMMAND}" =~ "clean" ]]; then
            if [[ -f "${DIR_PREFIX}/${MODEL_NAME}" ]]; then
                rm "${DIR_PREFIX}/${MODEL_NAME}"
            fi
        else
            error_echo "Invalid command ${MODEL_FILES_COMMAND}"
        fi
    done
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

            # Build.
            info_echo "Building ${ML_APP_TARGET}"
            ${CMAKE} --build "${ML_APP_BUILD_DIR}"          \
                     --target "${ML_APP_TARGET}"            \
                     --parallel "${PARALLELISM}"

            # Install.
            # NOTE: the prefix does not need to mention
            #       the `bin` or `lib` subdirectories, it
            #       is picked by CMake based on the target
            #       type.
            info_echo "Installing ${ML_APP_TARGET} to ${ML_APP_INSTALL_PREFIX}."
            ${CMAKE} --install "${ML_APP_BUILD_DIR}"        \
                     --component "ml-apps-tensorflow"       \
                     --prefix "${ML_APP_INSTALL_PREFIX}"
        done

        sample_tflite_model_files "${ML_APP_SAMPLE_MODEL_INSTALL_PATH}" "install"
    fi
}

# Clean the build/cache
function do_clean() {

    local ML_APP_TARGET
    local ML_APP_BIN_PATH
    local BIN_FILES_FOUND

    # Clean files from install location.
    info_echo "Removing applications from ${ML_APP_INSTALL_PREFIX}."
    for ML_APP_TARGET in "${ML_APP_TARGET_LIST[@]}"; do
        BIN_FILES_FOUND=$(find "${ML_APP_INSTALL_PREFIX}" -name "${ML_APP_TARGET}" -type f)
        for ML_APP_BIN_PATH in ${BIN_FILES_FOUND}; do
            if [[ -f "${ML_APP_BIN_PATH}" ]]; then
                rm "${ML_APP_BIN_PATH}"
            fi
        done
    done

    # Remove the complete CMake cache.
    info_echo "Cleaning build cache at ${ML_APP_BUILD_DIR}."
    if [ -d "${ML_APP_BUILD_DIR}" ]; then
        rm -rf "${ML_APP_BUILD_DIR}"
    fi

    # Remove the downloaded tflite model files.
    sample_tflite_model_files "${ML_APP_SAMPLE_MODEL_INSTALL_PATH}" "clean"
    sample_tflite_model_files "${DEPLOY_DIR}/${PLATFORM}" "clean"
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

    # Install to the deployment directory.
    sample_tflite_model_files "${DEPLOY_DIR}/${PLATFORM}" "install"
}

# Plug into the main framework for the above functions to be called.
source "$(dirname "${BASH_SOURCE[0]}")/framework.sh"
