# Copyright © 2023 Arm Ltd. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause

# If the environment has a prefix defined for us to use
if (DEFINED ENV{ML_APP_COMPILER_PREFIX})
    set(DEFAULT_PREFIX      $ENV{ML_APP_COMPILER_PREFIX})

# Else use the default and expect the toolchain is available
# in environment's PATH.
else ()
    set(DEFAULT_PREFIX      "aarch64-none-linux-gnu-")
endif ()

# specify the cross compiler
set(CROSS_PREFIX            ${DEFAULT_PREFIX})
set(CMAKE_C_COMPILER        ${CROSS_PREFIX}gcc)
set(CMAKE_CXX_COMPILER      ${CROSS_PREFIX}g++)
set(CMAKE_AR                ${CROSS_PREFIX}ar)
set(CMAKE_STRIP             ${CROSS_PREFIX}strip)
set(CMAKE_LINKER            ${CROSS_PREFIX}ld)
set(CMAKE_SYSTEM_NAME       Linux)
set(CMAKE_SYSTEM_PROCESSOR  aarch64)

message(STATUS "CROSS_PREFIX: ${CROSS_PREFIX}")

if (CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL x86_64)
    message(STATUS "Cross-compilation set to true")
    set(CMAKE_CROSSCOMPILING true)
endif ()
