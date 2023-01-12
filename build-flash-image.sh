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
    true
}

do_patch() {
    true
}

do_clean() {
    info_echo "Cleaning Flash Images"
    OUTDIR=$OUTPUT_DIR/tmp_build/flash-image

    rm -rf $OUTDIR
}

assemble_combined_flash() {
# $1 ... FIP input file
# $2 ... RSS flash input file
# $3 ... combined flash output file

    FIP_MAX_SIZE=35651584 #34 MiB
    FIP_SIZE=$(wc -c $1 | awk '{print $1}')

    if [ $FIP_SIZE -gt $FIP_MAX_SIZE ]
    then
        die "Error: $1 size ($FIP_SIZE) is more than supported($FIP_MAX_SIZE)"
    fi

    srec_cat \
        $1 -Binary -offset 0x0 \
        $2 -Binary -offset 0x2200000 \
        -o $3 -Binary

    info_echo "Created $3"
}

do_deploy() {
    BUILD_TYPE=release
    if [[ $TFA_DEBUG -eq 1 ]]; then
        BUILD_TYPE=debug
    fi

    OUTDIR=$OUTPUT_DIR/tmp_build/flash-image
    mkdir -p $OUTDIR

    RSS_SIGN_AP_BL1_NAME=$RSS_SIGN_AP_BL1_NAME_BUILDROOT
    if [[ $FILESYSTEM == "android-swr" ]]; then
        RSS_SIGN_AP_BL1_NAME=$RSS_SIGN_AP_BL1_NAME_ANDROID
    fi

    srec_cat \
        $RSS_BINDIR/bl2_signed.bin -Binary -offset 0x0 \
        $RSS_BINDIR/bl2_signed.bin -Binary -offset 0x10000 \
        $RSS_BINDIR/tfm_s_ns_signed.bin -Binary -offset 0x20000 \
        $RSS_BINDIR/tfm_s_ns_signed.bin -Binary -offset 0xE0000 \
        $RSS_BINDIR/signed_${RSS_SIGN_AP_BL1_NAME} -Binary -offset 0x1A0000 \
        $RSS_BINDIR/signed_${RSS_SIGN_SCP_BL1_NAME} -Binary -offset 0x220000 \
        $RSS_BINDIR/signed_${RSS_SIGN_AP_BL1_NAME} -Binary -offset 0x2A0000 \
        $RSS_BINDIR/signed_${RSS_SIGN_SCP_BL1_NAME} -Binary -offset 0x320000 \
        -o $OUTDIR/rss_flash.bin -Binary

    assemble_combined_flash \
        $TFA_OUTDIR/build/$TFA_PLATFORM/$BUILD_TYPE/fip.bin \
        $OUTDIR/rss_flash.bin \
        $OUTDIR/combined_flash.bin

    ln -sf $OUTDIR/combined_flash.bin $DEPLOY_DIR/$PLATFORM/combined_flash.bin

    if [[ -e $TRUSTY_OUTDIR/build/tc/debug/fip.bin ]]; then
        assemble_combined_flash \
            $TRUSTY_OUTDIR/build/tc/debug/fip.bin \
            $OUTDIR/rss_flash.bin \
            $OUTDIR/combined_flash_trusty.bin

        ln -sf $OUTDIR/combined_flash_trusty.bin \
               $DEPLOY_DIR/$PLATFORM/combined_flash_trusty.bin
    fi
}

source "$(dirname ${BASH_SOURCE[0]})/framework.sh"
