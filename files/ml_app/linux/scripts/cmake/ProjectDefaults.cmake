# Copyright © 2023 Arm Ltd. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause

# Declare project configuration options here:
option(TFLITE_ENABLE_XNNPACK "Build with XNNPack support" ON)
set(TARGET_PLATFORM "TC22" CACHE STRING "Target platform to build for")

# Declare default directories here:
set(CMAKE_TOOLCHAIN_DIR ${CMAKE_CURRENT_LIST_DIR}/toolchains)

list(APPEND TARGET_LIST_AARCH64 "TC21;TC22")

# Where should the resources be downloaded:
set(TENSORFLOW_SRC ${CMAKE_SOURCE_DIR}/dependencies/tensorflow CACHE STRING
    "Location of TensorFlow sources")

# Define default toolchain if it has not been supplied by the user.
if(NOT DEFINED CMAKE_TOOLCHAIN_FILE AND ${TARGET_PLATFORM} IN_LIST TARGET_LIST_AARCH64)
    set(CMAKE_TOOLCHAIN_FILE "${CMAKE_TOOLCHAIN_DIR}/aarch64-gnu.cmake")
endif ()

# Build in release mode by default
if (NOT CMAKE_BUILD_TYPE STREQUAL Debug)
    set(CMAKE_BUILD_TYPE Release CACHE INTERNAL "Build type (Release/Debug)")
endif ()
