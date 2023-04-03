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

    info_echo "Building TF-A"

    if [[ $TC_TARGET_FLAVOR == "fvp" ]]; then
        # Copy sp_layout.json to TFA_SP_DIR
        cp $TFA_FILES/$PLATFORM/sp_layout.json $TFA_SP_DIR

        pushd $TFA_SRC
        make "${make_opts_tfa[@]}" "${make_opts_tfa_optee[@]}" all fip
        popd
    elif [[ $TC_TARGET_FLAVOR == "fpga" ]]; then
        pushd $TFA_SRC
        make "${make_opts_fpga[@]}" all fip
        popd
    fi
}


do_clean() {
    info_echo "Cleaning TF-A"
    if [[ $TC_TARGET_FLAVOR == "fvp" ]]; then
        pushd $TFA_SRC
        make "${make_opts_tfa[@]}" "${make_opts_tfa_optee[@]}" clean
        popd
        rm -f $TFA_SP_DIR/sp_layout.json
    elif [[ $TC_TARGET_FLAVOR == "fpga" ]]; then
        pushd $TFA_SRC
        make "${make_opts_fpga[@]}" clean
        popd
    fi
}

do_deploy() {
    # Copy binaries to deploy directory
    BUILD_TYPE=release
    if [[ $TFA_DEBUG -eq 1 ]]; then
        BUILD_TYPE=debug
    fi

    ln -s $TFA_OUTDIR/build/$TFA_PLATFORM/$BUILD_TYPE/bl1.bin $DEPLOY_DIR/$PLATFORM/bl1-tc.bin 2>/dev/null || :
    ln -s $TFA_OUTDIR/build/$TFA_PLATFORM/$BUILD_TYPE/bl1/bl1.elf $DEPLOY_DIR/$PLATFORM/bl1-tc.elf 2>/dev/null || :
    if [[ $TC_TARGET_FLAVOR == "fpga" ]]; then
        ln -s $TFA_OUTDIR/build/$TFA_PLATFORM/$BUILD_TYPE/fip.bin $DEPLOY_DIR/$PLATFORM/fip-tc.bin 2>/dev/null || :
    fi
}

do_patch() {
    info_echo "Patching TF-A"
    PATCHES_DIR=$FILES_DIR/tfa/$PLATFORM/
    with_default_shell_opts patching $PATCHES_DIR $TFA_SRC
}

source "$(dirname ${BASH_SOURCE[0]})/framework.sh"
