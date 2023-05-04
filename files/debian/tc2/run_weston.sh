#!/bin/bash

# Copyright (c) 2023 Arm Limited. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

echo "Inserting mali module"
insmod /lib/aarch64-linux-gnu/mali/wayland/mali_kbase.ko

mkdir -p /tmp/wayland && chmod 700 /tmp/wayland
export XDG_RUNTIME_DIR=/tmp/wayland/
export LD_LIBRARY_PATH=/usr/lib/aarch64-linux-gnu/mali/wayland/
export WAYLAND_DISPLAY=wayland-0

echo "Launching weston..."
LD_LIBRARY_PATH=/usr/lib/aarch64-linux-gnu/mali/wayland/ XDG_RUNTIME_DIR=/tmp/wayland weston --backend=drm-backend.so --tty=1 --idle-time=0 --drm-device=card0&




