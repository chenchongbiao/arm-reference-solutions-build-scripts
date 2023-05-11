#!/bin/bash

# Copyright (c) 2023, Arm Limited. All rights reserved.
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
    if [ -z "$DEB_DDK_REPO" ]; then
	info_echo "{RED}DDK REPO URL is missing...exiting!"
        exit 1
    fi

    if [ -z "$DEB_DDK_VERSION" ]; then
	info_echo "{RED}DDK VERSION is missing...exiting!"
        exit 1
    fi

    info_echo "Cloning DDK..."

    if [ ! -d $SRC_DIR/mali ]; then
        git clone $DEB_DDK_REPO $SRC_DIR/mali
        cd $SRC_DIR/mali
        git checkout $DEB_DDK_VERSION
        git submodule update --init --recursive
    else
	info_echo "Mali source already exists, cloning skipped!"
	info_echo "For fresh source, clean it first."
    fi

    cd $SRC_DIR/mali
    export KERNEL_DIR=$LINUX_OUTDIR
    export TARGET_GNU_PREFIX=$DEB_DDK_GNU_PREFIX

    if [[ -z $ARM_PRODUCT_DEF || -z $LM_LICENSE_FILE || -z $ARMLMD_LICENSE_FILE ]]; then
            info_echo "Please export ARM_PRODUCT_DEF, LM_LICENSE_FILE and ARMLMD_LICENSE_FILE variabless to build GPU DDK"
            exit 1
    fi
    export PATH=$SCRIPT_DIR/../tools/armclang/bin:$PATH
    export ARM_PRODUCT_DEF=$ARM_PRODUCT_DEF
    export LM_LICENSE_FILE=$LM_LICENSE_FILE
    export ARMLMD_LICENSE_FILE=$ARMLMD_LICENSE_FILE

    # Build DDK modules
    cd product && bldsys/git_binaries.py -u
    info_echo "Building modules within DDK..."
    pushd kernel/drivers/gpu/arm/midgard
    make KDIR=$LINUX_OUTDIR ARCH=arm64 CROSS_COMPILE=$LINUX_COMPILER- BUILD_DIR=$PWD CONFIG_MALI_BASE_MODULES=y \
	    CONFIG_DMA_SHARED_BUFFER_TEST_EXPORTER=y CONFIG_MALI_MEMORY_GROUP_MANAGER=y CONFIG_MALI_PROTECTED_MEMORY_ALLOCATOR=y \
	    CONFIG_MALI_CINSTR_CPU_PROBES=y CONFIG_MALI_FPGA_SYSCTL=y CONFIG_MALI_MIDGARD=m CONFIG_MALI_PLATFORM_NAME="devicetree" \
	    CONFIG_MALI_REAL_HW=y CONFIG_MALI_CSF_SUPPORT=y CONFIG_MALI_DEVFREQ=y CONFIG_MALI_GATOR_SUPPORT=y CONFIG_MALI_DMA_FENCE=y CONFIG_FW_LOADER=y \
	    CONFIG_MALI_DMA_BUF_MAP_ON_DEMAND=y CONFIG_MALI_EXPERT=y CONFIG_MALI_DEBUG=y CONFIG_MALI_FENCE_DEBUG=y CONFIG_MALI_SYSTEM_TRACE=y
    popd

    info_echo "Configuring DDK for Linux..."
    BUILDDIR=$DEB_DDK_BUILD_DIR $PWD/bldsys/bootstrap_linux.bash
    $DEB_DDK_BUILD_DIR/config WSIALLOC_ALLOCATOR_NAME="dma_buf_heaps" LINUX=y CSFFW=y EGL=y GPU_TTIX=y RELEASE=n DEBUG=y SYMBOLS=y \
	    GLES=y CL=n VULKAN=n KERNEL_DIR=$KERNEL_DIR TARGET_GNU_PREFIX=$TARGET_GNU_PREFIX WINSYS_WAYLAND_PRIMARY=y \
	    TPI_WAYLAND_BACKEND_DRM=y WINSYS_GBM=y KERNEL_COMPILER=$LINUX_COMPILER- BUILD_KERNEL_MODULES=n WERROR=n \
	    KERNEL_HEADER_DIR=$LINUX_OUTDIR/usr/include

    info_echo "Building DDK..."
    $DEB_DDK_BUILD_DIR/buildme
}

do_clean() {

    if [ -z $DEB_DDK_REPO ]; then
        info_echo "Nothing to clean!"
    else
	info_echo "Cleaning DDK..."
        $DEB_DDK_BUILD_DIR/buildme -t clean
        # rm -rf $DEB_DDK_BUILD_DIR
        # rm -rf $SRC_DIR/mali
    fi
}

do_deploy() {
	info_echo "deploying DDK..."
	mkdir -p $DEB_DDK_WAYLAND_DIR
	cp -r $DEB_DDK_INSTALL_DIR/lib/* $DEB_DDK_WAYLAND_DIR
	cp -r $DEB_DDK_INSTALL_DIR/bin $DEB_DDK_WAYLAND_DIR
	cp $DEB_DDK_MALI_KBASE_MODULE/mali_kbase.ko $DEB_DDK_WAYLAND_DIR 
	chmod 777 $DEBIAN_WESTON_RUNSCRIPT/run_weston.sh
	cp $DEBIAN_WESTON_RUNSCRIPT/run_weston.sh $DEB_DDK_WAYLAND_DIR
	pushd $DEB_DDK_MALI_DIR/../
	tar -zcvf mali.tar.xz mali
	popd
}

source "$(dirname ${BASH_SOURCE[0]})/framework.sh"
