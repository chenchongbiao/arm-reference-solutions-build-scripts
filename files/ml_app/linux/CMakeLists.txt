# Copyright © 2023 Arm Ltd. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause

cmake_minimum_required(VERSION 3.21)

# Include project default settings.
include(${CMAKE_CURRENT_SOURCE_DIR}/scripts/cmake/ProjectDefaults.cmake)

# Project definition
project(ml-apps-tensorflow
        VERSION     0.0.1
        DESCRIPTION "Machine Learning Applications from TensorFlow"
        LANGUAGES   CXX)

# Log project configuration options:
message(STATUS "Using CMAKE_TOOLCHAIN_FILE: ${CMAKE_TOOLCHAIN_FILE}")
message(STATUS "TFLITE_ENABLE_XNNPACK:      ${TFLITE_ENABLE_XNNPACK}")
message(STATUS "TARGET_PLATFORM:            ${TARGET_PLATFORM}")

# Target specific definitions/options
if (TARGET_PLATFORM STREQUAL TC22)
    # @TODO: TC22 Custom march/mcpu flags
else ()
    message(WARNING "Currently, TC22 is the only tested build target.")
endif ()

# CMake policy statements that we want to set explicitly.
include(${CMAKE_CURRENT_SOURCE_DIR}/scripts/cmake/CMakePolicies.cmake)

# Check the requirements for this scripts.
if (NOT DEFINED TENSORFLOW_SRC)
    message(FATAL_ERROR "TENSORFLOW_SRC needs to be defined to the"
                        " location where the tree should be cloned"
                        " if it doesn't exist.")
endif ()

# We need to build the project in this subdirectory:
set(TFLITE_SUB "tensorflow/lite")
set(TFLITE_SRC "${TENSORFLOW_SRC}/${TFLITE_SUB}")

if (NOT EXISTS ${TFLITE_SRC})
    message(FATAL_ERROR
            "Could not find tensorFlow Lite source at: ${TFLITE_SRC}. "
            "Make sure the location of sources is set "
            "using -DTENSORFLOW_SRC=/path/to/tensorflow.")
endif ()

add_subdirectory(${TFLITE_SRC} ${CMAKE_BINARY_DIR}/tensorflow-lite)

# At this stage we expect the tensorflow-lite target to be defined, if not
# there is something wrong!
if (NOT TARGET tensorflow-lite)
    message(FATAL_ERROR "tensorflow-lite TARGET should be available")
endif ()

# Add additional XNNPack definitions
if (TFLITE_ENABLE_XNNPACK)
    target_compile_definitions(tensorflow-lite PUBLIC
        XNNPACK_DELEGATE_ENABLE_QS8
        XNNPACK_DELEGATE_ENABLE_DYNAMIC_FULLY_CONNECTED
        XNNPACK_DELEGATE_ENABLE_QU8)
endif()

# By default, the benchmark application is not built unless specified as a target. We can
# change that behaviour here to make it build by default.
if (NOT TARGET benchmark_model)
    message(FATAL_ERROR "benchmark_model TARGET has not been defined.")
else ()
    set_target_properties(benchmark_model PROPERTIES EXCLUDE_FROM_ALL OFF)

    # Set a simple installation rule to ease copying of binaries if required.
    install(TARGETS benchmark_model
            RUNTIME
            COMPONENT ${CMAKE_PROJECT_NAME})
endif ()
