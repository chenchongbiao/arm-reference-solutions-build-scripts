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

do_generate_gpt() {
# $1 ... Input FIP file
# $2 ... Output GPT image file

    OUTDIR=$OUTPUT_DIR/tmp_build/flash-image

    BUILD_TYPE=release
    if [[ $TFA_DEBUG -eq 1 ]]; then
        BUILD_TYPE=debug
    fi

    fip_bin="$1"
    gpt_image="$2"
    # the FIP partition type is not standardized, so generate one
    fip_type_uuid=`uuidgen --sha1 --namespace @dns --name "fip_type_uuid"`
    # metadata partition type UUID, specified by the document:
    # Platform Security Firmware Update for the A-profile Arm Architecture
    # version: 1.0BET0
    metadata_type_uuid="8a7a84a0-8387-40f6-ab41-a8b9a5a60d23"
    location_uuid=`uuidgen`
    FIP_A_uuid=`uuidgen`
    FIP_B_uuid=`uuidgen`

    # maximum FIP size 12MiB. This is the current size of the FIP rounded up to an integer number of MiB.
    fip_max_size=12582912
    fip_bin_size=$(stat -c %s $fip_bin)
    if [ $fip_max_size -lt $fip_bin_size ]; then
        bberror "fip.bin ($fip_bin_size bytes) is larger than the GPT partition ($fip_max_size bytes)"
    fi

    # maximum metadata size 512B. This is the current size of the metadata rounded up to an integer number of sectors.
    metadata_max_size=512
    metadata_file="${OUTDIR}/metadata.bin"
    python3 $TFA_FILES/generate_metadata.py --metadata_file $metadata_file \
                                            --img_type_uuids $fip_type_uuid \
                                            --location_uuids $location_uuid \
                                            --img_uuids $FIP_A_uuid $FIP_B_uuid

    # create GPT image. The GPT contains 2 FIP partitions: FIP_A and FIP_B, and 2 metadata partitions: FWU-Metadata and Bkup-FWU-Metadata.
    # the GPT layout is the following:
    # -----------------------
    # Protective MBR
    # -----------------------
    # Primary GPT Header
    # -----------------------
    # FIP_A
    # -----------------------
    # FIP_B
    # -----------------------
    # FWU-Metadata
    # -----------------------
    # Bkup-FWU-Metadata
    # -----------------------
    # Secondary GPT Header
    # -----------------------

    sector_size=512
    gpt_header_size=33 # valid only for 512-byte sectors
    num_sectors_fip=`expr $fip_max_size / $sector_size`
    num_sectors_metadata=`expr $metadata_max_size / $sector_size`
    start_sector_1=`expr 1 + $gpt_header_size` # size of MBR is 1 sector
    start_sector_2=`expr $start_sector_1 + $num_sectors_fip`
    start_sector_3=`expr $start_sector_2 + $num_sectors_fip`
    start_sector_4=`expr $start_sector_3 + $num_sectors_metadata`
    num_sectors_gpt=`expr $start_sector_4 + $num_sectors_metadata + $gpt_header_size`
    gpt_size=`expr $num_sectors_gpt \* $sector_size`

    # create raw image
    dd if=/dev/zero of=$gpt_image bs=$gpt_size count=1

    # create the GPT layout
    sgdisk $gpt_image \
           --set-alignment 16 \
           --disk-guid $location_uuid \
           \
           --new 1:$start_sector_1:+$num_sectors_fip \
           --change-name 1:FIP_A \
           --typecode 1:$fip_type_uuid \
           --partition-guid 1:$FIP_A_uuid \
           \
           --new 2:$start_sector_2:+$num_sectors_fip \
           --change-name 2:FIP_B \
           --typecode 2:$fip_type_uuid \
           --partition-guid 2:$FIP_B_uuid \
           \
           --new 3:$start_sector_3:+$num_sectors_metadata \
           --change-name 3:FWU-Metadata \
           --typecode 3:$metadata_type_uuid \
           \
           --new 4:$start_sector_4:+$num_sectors_metadata \
           --change-name 4:Bkup-FWU-Metadata \
           --typecode 4:$metadata_type_uuid

    # populate the GPT partitions
    dd if=$fip_bin of=$gpt_image bs=$sector_size seek=$(gdisk -l $gpt_image | grep " FIP_A$" | awk '{print $2}') count=$num_sectors_fip conv=notrunc
    dd if=$fip_bin of=$gpt_image bs=$sector_size seek=$(gdisk -l $gpt_image | grep " FIP_B$" | awk '{print $2}') count=$num_sectors_fip conv=notrunc
    dd if=$metadata_file of=$gpt_image bs=$sector_size seek=$(gdisk -l $gpt_image | grep " FWU-Metadata$" | awk '{print $2}') count=$num_sectors_metadata conv=notrunc
    dd if=$metadata_file of=$gpt_image bs=$sector_size seek=$(gdisk -l $gpt_image | grep " Bkup-FWU-Metadata$" | awk '{print $2}') count=$num_sectors_metadata conv=notrunc

    info_echo "Built $gpt_image"
}

do_build() {
    true
}

do_clean() {
    info_echo "Cleaning Flash Images"
    OUTDIR=$OUTPUT_DIR/tmp_build/flash-image

    rm -rf $OUTDIR
}

do_patch() {
    true
}

assemble_fip() {
# $1 ... Input FIP file
# $2 ... Output FIP file

    cp $1 $2

    FIPTOOL=$TFA_SRC/tools/fiptool/fiptool

    BINDIR=$RSS_BINDIR
    if [[ $2 == *"trusty"* ]]; then
	    BINDIR=$RSS_BINDIR_TRUSTY
    fi

    $FIPTOOL update --align 8192 --rss-bl2 $BINDIR/bl2_signed.bin $2
    $FIPTOOL update --align 8192 --rss-scp-bl1 $RSS_BINDIR/signed_$RSS_SIGN_SCP_BL1_NAME $2
    $FIPTOOL update --align 8192 --rss-ap-bl1 $RSS_BINDIR/signed_$RSS_SIGN_AP_BL1_NAME $2

    if [[ -e ${BINDIR}/tfm_s_sic_tables_signed.bin ]]; then
        $FIPTOOL update --align 8192 --rss-ns $BINDIR/tfm_ns.bin $2
        $FIPTOOL update --align 8192 --rss-s $BINDIR/tfm_s.bin $2
        $FIPTOOL update --align 8192 --rss-sic-tables-ns $BINDIR/tfm_ns_sic_tables_signed.bin $2
        $FIPTOOL update --align 8192 --rss-sic-tables-s $BINDIR/tfm_s_sic_tables_signed.bin $2
    else
        $FIPTOOL update --align 8192 --rss-ns $BINDIR/tfm_ns_signed.bin $2
        $FIPTOOL update --align 8192 --rss-s $BINDIR/tfm_s_signed.bin $2
    fi

    info_echo "Built $2"
}

do_deploy() {
    BUILD_TYPE=release
    if [[ $TFA_DEBUG -eq 1 ]]; then
        BUILD_TYPE=debug
    fi

    OUTDIR=$OUTPUT_DIR/tmp_build/flash-image
    mkdir -p $OUTDIR

    BUILD_TYPE=release
    if [[ $TFA_DEBUG -eq 1 ]]; then
        BUILD_TYPE=debug
    fi

    RSS_SIGN_AP_BL1_NAME=$RSS_SIGN_AP_BL1_NAME_BUILDROOT
    if [[ $FILESYSTEM == "android-swr" ]]; then
        RSS_SIGN_AP_BL1_NAME=$RSS_SIGN_AP_BL1_NAME_ANDROID
    fi

    export LD_LIBRARY_PATH=$TFA_OPENSSL_DIR/lib:$LD_LIBRARY_PATH
    assemble_fip $TFA_OUTDIR/build/$TFA_PLATFORM/$BUILD_TYPE/fip.bin \
                 ${OUTDIR}/fip_combined.bin

    ln -sf $OUTDIR/fip_combined.bin $DEPLOY_DIR/$PLATFORM/fip-tc.bin 2>/dev/null || :
    if [[ $TC_FWU_SUPPORT -eq 1 ]]; then
        do_generate_gpt $OUTDIR/fip_combined.bin $OUTDIR/fip_gpt.bin
        ln -sf $OUTDIR/fip_gpt.bin $DEPLOY_DIR/$PLATFORM/fip_gpt-tc.bin 2>/dev/null || :
    fi

    if [[ -e $TRUSTY_OUTDIR/build/tc/debug/fip.bin ]]; then
        assemble_fip $TRUSTY_OUTDIR/build/tc/debug/fip.bin \
                     ${OUTDIR}/fip_combined_trusty.bin

        ln -sf $OUTDIR/fip_combined_trusty.bin $DEPLOY_DIR/$PLATFORM/fip-trusty-tc.bin 2>/dev/null || :
# Currently not supporting FWU for trusty
#        if [[ $TC_FWU_SUPPORT -eq 1 ]]; then
#            do_generate_gpt $OUTDIR/fip_combined_trusty.bin $OUTDIR/fip_gpt_trusty.bin
#            ln -sf $OUTDIR/fip_gpt_trusty.bin $DEPLOY_DIR/$PLATFORM/fip_gpt-trusty-tc.bin 2>/dev/null || :
#        fi
    fi
}

source "$(dirname ${BASH_SOURCE[0]})/framework.sh"
