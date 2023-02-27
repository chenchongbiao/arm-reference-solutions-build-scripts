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
    info_echo "Building RSS-Trusty"
    mkdir -p "$RSS_OUTDIR_TRUSTY"

    local makeopts=(
        -S $RSS_SRC
        -B $RSS_OUTDIR_TRUSTY/build
        -DTFM_PLATFORM=$RSS_PLATFORM
        -DTFM_TOOLCHAIN_FILE=$RSS_TOOLCHAIN_FILE
        -DCMAKE_BUILD_TYPE=$RSS_BUILD_TYPE
        -DMCUBOOT_IMAGE_NUMBER=$RSS_IMAGE_NUMBER
	-DRSS_GPT_SUPPORT=$RSS_GPT_SUPPORT_TRUSTY
    )

    if [[ $RSS_TOOLCHAIN_FILE == *"GNUARM"* ]]; then
    makeopts+=( "-DCROSS_COMPILE=$RSS_COMPILER" )
    fi

    $CMAKE "${makeopts[@]}"
    # Check for any missing dependencies with external components.
    # These are only available after the build command downloads external components.
    pip3 freeze -r $RSS_OUTDIR/build/lib/ext/mbedcrypto-src/scripts/driver.requirements.txt > $RSS_OUTDIR/pip_freeze.txt 2>&1
    if [[ $(grep "not installed" $RSS_OUTDIR/pip_freeze.txt) ]]; then
	    warn_echo $(grep "not installed" $RSS_OUTDIR/pip_freeze.txt)
	    die "Python dependencies are not installed. Add missing dependencies to the setup file"
    fi
}

do_clean() {
    info_echo "Cleaning $RSS_OUTDIR_TRUSTY"
    rm -rf $RSS_OUTDIR_TRUSTY
}

do_patch() {
    info_echo "Patching RSS-Trusty"
    PATCHES_DIR=$FILES_DIR/rss/${PLATFORM}
    with_default_shell_opts patching $PATCHES_DIR $RSS_SRC
}

do_deploy() {
    #create rss_trusty_rom.bin
    srec_cat \
    $RSS_BINDIR_TRUSTY/bl1_1.bin -Binary -offset 0x0 \
    $RSS_BINDIR_TRUSTY/bl1_provisioning_bundle.bin -Binary -offset 0xE000 \
    -o $DEPLOY_DIR/$PLATFORM/rss_trusty_rom.bin -Binary

    info_echo "Created rss_trusty_rom.bin"
}

source "$(dirname ${BASH_SOURCE[0]})/framework.sh"
