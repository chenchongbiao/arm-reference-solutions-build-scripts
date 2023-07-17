# Copyright © 2023 Arm Ltd. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause

# Policies go here
cmake_policy(SET CMP0012 NEW) # https://cmake.org/cmake/help/latest/policy/CMP0012.html

if (POLICY CMP0135)
    # See https://cmake.org/cmake/help/latest/policy/CMP0135.html
    cmake_policy(SET CMP0135 NEW)
endif ()
