#!/usr/bin/env bash

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

clone_gpu_ddk() {
            info_echo "Clone GPU DDK source"
            pushd $ANDROID_SRC
            if [ ! -d "$ANDROID_SRC/vendor/arm" ]; then
                    mkdir -p vendor/arm
                    pushd vendor/arm/
                    git clone ssh://eu-gerrit-1.euhpc.arm.com:29418/GPU-SW/midgard_sw/driver mali
                    pushd mali
                    git checkout r40p0_01eac0
                    git submodule update --init --recursive
                    popd
                    git clone ssh://gerrit.oss.arm.com/android/vendor/arm/examples
                    popd
            fi
            popd
}

build_gpu_ddk() {
            info_echo "Build GPU DDK source"
            export PATH=$SCRIPT_DIR/../tools/armclang/bin:$PATH
	    export ARM_PRODUCT_DEF=$SCRIPT_DIR/../tools/armclang/sw/mappings/platinum.elmap
            export LM_LICENSE_FILE=1661@euhpc-lic05.euhpc.arm.com
            export ARMLMD_LICENSE_FILE=7010@euhpc-lic03.euhpc.arm.com:7010@euhpc-lic04.euhpc.arm.com:7010@euhpc-lic05.euhpc.arm.com:7010@euhpc-lic07.euhpc.arm.com:8224@blr-lic03.blr.arm.com:8224@blr-lic04.blr.arm.com:8224@blr-lic05.blr.arm.com:7010@nahpc-lic06.nahpc.arm.com:7010@nahpc-lic09.nahpc.arm.com:7010@cam-lic3.cambridge.arm.com:7010@cam-lic4.cambridge.arm.com:7010@euhpc-lic-armlmd.euhpc.arm.com
            pushd $ANDROID_SRC/vendor/arm/mali/product
            mkdir -p build_cfw
	    export BUILDDIR=$PWD/build_cfw
	    pushd kernel/drivers/gpu/arm/midgard
            make KDIR=$LINUX_OUTDIR ARCH=arm64 CROSS_COMPILE=$LINUX_COMPILER- BUILD_DIR=$PWD CONFIG_MALI_BASE_MODULES=y CONFIG_DMA_SHARED_BUFFER_TEST_EXPORTER=y CONFIG_MALI_MEMORY_GROUP_MANAGER=y CONFIG_MALI_PROTECTED_MEMORY_ALLOCATOR=y CONFIG_MALI_CINSTR_CPU_PROBES=y CONFIG_MALI_FPGA_SYSCTL=y CONFIG_MALI_MIDGARD=m CONFIG_MALI_PLATFORM_NAME="devicetree" CONFIG_MALI_REAL_HW=y CONFIG_MALI_CSF_SUPPORT=y CONFIG_MALI_DEVFREQ=y CONFIG_MALI_GATOR_SUPPORT=y CONFIG_MALI_DMA_FENCE=y CONFIG_MALI_DMA_BUF_MAP_ON_DEMAND=y CONFIG_MALI_EXPERT=y CONFIG_MALI_DEBUG=y CONFIG_MALI_FENCE_DEBUG=y CONFIG_MALI_SYSTEM_TRACE=y CONFIG_GPU_HAS_CSF=y
	    popd
            bldsys/bootstrap_linux.bash
            # build CSF firmware
            build_cfw/config LINUX=y CSFFW=y EGL=y GPU_TTIX=y RELEASE=y DEBUG=n SYMBOLS=n GLES=y CL=n VULKAN=y TARGET_GNU_PREFIX=$LINUX_COMPILER- KERNEL_DIR=$LINUX_OUTDIR
            build_cfw/buildme csffw
            mkdir -p firmware_prebuilt/ttix
            cp build_cfw/install/bin/mali_csffw.bin firmware_prebuilt/ttix
            ./setup_android ANDROID=y CSFFW=n EGL=y GPU_TTIX=y RELEASE=y DEBUG=n SYMBOLS=n GLES=y CL=n VULKAN=y INSTRUMENTATION_GFX=y KERNEL_CC=$ANDROID_SRC/prebuilts/clang/host/linux-x86/clang-r450784d/bin/clang USES_REFERENCE_GRALLOC=y REFERENCE_GRALLOC_XML=y KERNEL_COMPILER=$LINUX_COMPILER-
            ./android/gralloc/configure
            mmm android/gralloc
            mm
            popd
            pushd vendor/arm/examples
            m mte-unit-tests
            m bti-unit-tests
            m pauth-unit-tests
            m userdataimage-nodeps
            popd
            pushd $ANDROID_SRC/vendor/arm/mali/product
	    pushd kernel/drivers/gpu/arm/midgard
	    cp  -rf mali_kbase.ko $ANDROID_SRC/out/target/product/$TARGET_PRODUCT/vendor/etc
	    popd
	    popd
}

do_build() {

    info_echo "Building Android"
    pushd $ANDROID_SRC

    # Source the main envsetup script.
    if [[ ! -f "build/envsetup.sh" ]]; then
        error_echo "Could not find build/envsetup.sh. Please call this file from root of android directory."
    fi

    # check if file exists and exit if it doesnt
    check_file_exists_and_exit () {
        if [ ! -f $1 ]
        then
            error_echo "$1 does not exist"
            exit 1
        fi
    }

    make_ramdisk_android_image () {
        $SCRIPT_DIR/add_uboot_header.sh
        $SCRIPT_DIR/create_android_image.sh -a $AVB
    }

    TC_MICRODROID_DEMO_SRC="packages/modules/Virtualization/tc_microdroid_demo"
    make_tc_microdroid_demo_app () {
        # If the demo app exists, then build else return 0
        if [ ! -d ${TC_MICRODROID_DEMO_SRC} ]
        then
            return 0
        fi

        info_echo "Building TC Microdroid Demo App"
        UNBUNDLED_BUILD_SDKS_FROM_SOURCE=true   \
        TARGET_BUILD_APPS=TCMicrodroidDemoApp   \
        m apps_only dist

        return $?
    }

    DISTRO=$FILESYSTEM

    [ -z "$DISTRO" ] && incorrect_script_use || echo "DISTRO=$DISTRO"
    echo "AVB=$AVB"
    echo "PLATFORM=$PLATFORM"
    echo "TC_TARGET_FLAVOR=$TC_TARGET_FLAVOR"

    KERNEL_IMAGE=$LINUX_OUTDIR/arch/arm64/boot/Image
    . build/envsetup.sh || true
    case $DISTRO in
        android-fvp | android-fpga)
            if [ "$AVB" == true ]
            then
                check_file_exists_and_exit $KERNEL_IMAGE
                info_echo "Using $KERNEL_IMAGE for kernel"
                cp $KERNEL_IMAGE device/arm/tc
		if [ "$TC_GPU" == true ]; then
		    clone_gpu_ddk
                    lunch tc_$TC_TARGET_FLAVOR-userdebug;
		    build_gpu_ddk
	        else
                    lunch tc_$TC_TARGET_FLAVOR-userdebug;
                fi
            else
		if [ $TC_GPU == true ]; then
		    clone_gpu_ddk
                    lunch tc_$TC_TARGET_FLAVOR-eng;
		    build_gpu_ddk
	        else
                    lunch tc_$TC_TARGET_FLAVOR-eng;
		fi
            fi
            ;;
        *) error_echo "bad option for distro $3"; incorrect_script_use
            ;;
    esac

    # Build microdroid_demo_app before building tc_fvp stack. This makes the demo
    # app to be included in the system image
    make_tc_microdroid_demo_app
    if [[ $? != 0 ]]; then
        error_echo "Building Microdroid demo App failed"
        exit 1
    fi

    if make -j "$PARALLELISM";
    then
        make_ramdisk_android_image
    else
        error_echo "Errors when building - will not create file system images"
    fi
    popd
}

do_deploy() {
      ln -sf $ANDROID_SRC/out/target/product/tc_$TC_TARGET_FLAVOR/android.img $DEPLOY_DIR/$PLATFORM
      ln -sf $ANDROID_SRC/out/target/product/tc_$TC_TARGET_FLAVOR/ramdisk_uboot.img $DEPLOY_DIR/$PLATFORM
      ln -sf $ANDROID_SRC/out/target/product/tc_$TC_TARGET_FLAVOR/system.img $DEPLOY_DIR/$PLATFORM
      ln -sf $ANDROID_SRC/out/target/product/tc_$TC_TARGET_FLAVOR/userdata.img $DEPLOY_DIR/$PLATFORM

      if [[ $AVB == "true" ]]; then
          ln -sf $ANDROID_SRC/out/target/product/tc_$TC_TARGET_FLAVOR/boot.img $DEPLOY_DIR/$PLATFORM
          ln -sf $ANDROID_SRC/out/target/product/tc_$TC_TARGET_FLAVOR/vbmeta.img $DEPLOY_DIR/$PLATFORM
      fi
      if [ $TC_GPU == "true" ]; then
          ln -sf $ANDROID_SRC/out/target/product/tc_$TC_TARGET_FLAVOR/vendor.img $DEPLOY_DIR/$PLATFORM
      fi
}

do_clean() {
    info_echo "Cleaning Android"
    rm -rf $ANDROID_SRC/out
}

source "$(dirname ${BASH_SOURCE[0]})/framework.sh"
