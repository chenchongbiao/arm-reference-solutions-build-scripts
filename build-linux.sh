#!/bin/bash

# Copyright (c) 2022-2023, Arm Limited. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# Neither the name of ARM nor the names of its contributors may be used
# to endorse or promote products derived from this software without specific
# prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

do_build() {
    info_echo "Building Linux kernel"
    local lconfig=LINUX_defconfig[config]

    CFG_DIR=$FILES_DIR/kernel/$PLATFORM
    mkdir -p $LINUX_OUTDIR
    info_echo "Building using config fragments"
    CONFIG=""
    for config in ${!lconfig}; do
        CONFIG=$CONFIG"$CFG_DIR/$config "
    done
    if [ "$TC_TARGET_FLAVOR" == "fpga" ]; then
        CONFIG=$CONFIG"$CFG_DIR/fpga.cfg "
    fi
    CONFIG="$LINUX_SRC/arch/arm64/configs/gki_defconfig "$CONFIG
    pushd $LINUX_SRC
    scripts/kconfig/merge_config.sh -O $LINUX_OUTDIR -m $CONFIG
    make O=$LINUX_OUTDIR ARCH=arm64 CROSS_COMPILE=$LINUX_COMPILER- olddefconfig
    make O=$LINUX_OUTDIR ARCH=arm64 CROSS_COMPILE=$LINUX_COMPILER- -j $PARALLELISM $LINUX_IMAGE_TYPE
    make O=$LINUX_OUTDIR ARCH=arm64 CROSS_COMPILE=$LINUX_COMPILER- -j $PARALLELISM $LINUX_IMAGE_TYPE modules
    # GCC12.2 patch: specify EXTRA_CFLAGS to disable Werror=format-truncation for 'util/machine.c'.
    # Note: re-evaluate the need for this patch if GCC version changes or Werror is removed.
    EXTRA_CFLAGS="${EXTRA_CFLAGS} -Wno-error=format-truncation"
    make EXTRA_CFLAGS="${EXTRA_CFLAGS}" O=$LINUX_OUTDIR ARCH=arm64 CROSS_COMPILE=$LINUX_COMPILER- -j $PARALLELISM tools/perf
    install -D $LINUX_OUTDIR/tools/perf/perf $BUILDROOT_ROOTFS_OVERLAY/bin/perf

    info_echo "Building kernel selftest"
    make O=$LINUX_OUTDIR ARCH=arm64 KBUILD_OUTPUT=$LINUX_OUTDIR CROSS_COMPILE=$LINUX_COMPILER- -C $KSELFTEST_SRC TARGETS=arm64 ARM64_SUBTARGETS="$KSELFTEST_LIST" INSTALL_PATH=$LINUX_OUTDIR/selftest install
    mkdir -p $KSELFTEST_ROOTFS_OVERLAY
    cp -r $LINUX_OUTDIR/selftest $KSELFTEST_ROOTFS_OVERLAY/
    popd

    pushd $ARM_FFA_TEE_SRC
    make KDIR=$LINUX_OUTDIR CROSS_COMPILE=$LINUX_COMPILER- BUILD_DIR=$ARM_FFA_TEE_OUTDIR module
    # signing the module
    $LINUX_OUTDIR/scripts/sign-file sha1 $LINUX_OUTDIR/certs/signing_key.pem $LINUX_OUTDIR/certs/signing_key.x509 $ARM_FFA_TEE_OUTDIR/arm-ffa-tee.ko
    install -D $ARM_FFA_TEE_OUTDIR/arm-ffa-tee.ko $BUILDROOT_ROOTFS_OVERLAY/root/arm-ffa-tee.ko
    popd
}

do_clean() {
    info_echo "Cleaning Linux kernel"
    rm -rf $LINUX_OUTDIR
    rm -rf $ARM_FFA_TEE_OUTDIR
    rm -rf $KSELFTEST_ROOTFS_OVERLAY/selftest
    rm -f $BUILDROOT_ROOTFS_OVERLAY/root/arm-ffa-tee.ko
    rm -f $BUILDROOT_ROOTFS_OVERLAY/bin/perf
}

do_deploy() {
    # Copy final image to deploy directory
    ln -sf $LINUX_OUTDIR/arch/arm64/boot/Image $DEPLOY_DIR/$PLATFORM/Image
}

do_patch() {
    info_echo "Patching Linux kernel"
    PATCHES_DIR=$FILES_DIR/kernel/$PLATFORM/
    with_default_shell_opts patching $PATCHES_DIR $LINUX_SRC
}

source "$(dirname ${BASH_SOURCE[0]})/framework.sh"
