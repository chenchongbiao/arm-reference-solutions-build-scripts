#!/usr/bin/env bash

# Copyright (c) 2019, ARM Limited and Contributors. All rights reserved.
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

#List of supported
declare -A sgi_platforms
sgi_platforms[sgi575]=1

__print_supported_sgi_platforms()
{
	echo "Supported platforms are -"
	for plat in "${!sgi_platforms[@]}" ;
		do
			printf "\t $plat \n"
	  	done
	echo
}

__print_usage()
{
	echo "Usage: ./build-scripts/build-secureboot.sh -p <platform> <command>"
	__print_supported_sgi_platforms
	echo "Supported build commands are - clean/build/package/all"
	echo
	exit
}

#callback from build-all.sh to override any build configs
__do_override_build_configs()
{
        echo "build-secureboot.sh: adding UEFI_EXTRA_BUILD_PARAMS build configuration"
        export UEFI_EXTRA_BUILD_PARAMS="-D SMM_RUNTIME=TRUE -D SECURE_BOOT_ENABLE=TRUE"
        echo $UEFI_EXTRA_BUILD_PARAMS
}

parse_params() {
	#Parse the named parameters
	while getopts "p:" opt; do
		case $opt in
			p)
				SGI_PLATFORM="$OPTARG"
				;;
		esac
	done

	#The clean/build/package/all should be after the other options
	#So grab the parameters after the named param option index
	BUILD_CMD=${@:$OPTIND:1}

	#Ensure that the platform is supported
	if [ -z "$SGI_PLATFORM" ] ; then
		__print_usage
	fi
	if [ -z "${sgi_platforms[$SGI_PLATFORM]}" ] ; then
		echo "[ERROR] Could not deduce which platform to build."
		__print_supported_sgi_platforms
		exit
	fi

	#Ensure a build command is specified
	if [ -z "$BUILD_CMD" ] ; then
		__print_usage
	fi
}

#parse the command line parameters
parse_params $@

#override the command line parameters for build-all.sh
set -- "-p $SGI_PLATFORM -f busybox $BUILD_CMD"
source ./build-scripts/build-all.sh

#------------------------------------------
# Generate the disk image for secure boot
#------------------------------------------

#variables for image generation
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
TOP_DIR=`pwd`
PLATDIR=${TOP_DIR}/output/$SGI_PLATFORM
OUTDIR=${PLATDIR}/components
GRUB_FS_CONFIG_FILE=${TOP_DIR}/build-scripts/configs/$SGI_PLATFORM/grub_config/busybox.cfg
GRUB_FS_VALIDATION_CONFIG_FILE=${TOP_DIR}/build-scripts/configs/$SGI_PLATFORM/grub_config/busybox-dhcp.cfg

create_cfgfiles ()
{
	local fatpart_name="$1"

	if [ "$VALIDATION_LVL" == 1 ]; then
		mcopy -i  $fatpart_name -o ${GRUB_FS_CONFIG_FILE} ::/grub/grub.cfg
	else
		mcopy -i $fatpart_name -o ${GRUB_FS_VALIDATION_CONFIG_FILE} ::/grub/grub.cfg
	fi
}

create_fatpart ()
{
	local fatpart="$1"

	dd if=/dev/zero of=$fatpart bs=$BLOCK_SIZE count=$FAT_SIZE
	mkfs.vfat $fatpart
	mmd -i $fatpart ::/EFI
	mmd -i $fatpart ::/EFI/BOOT
	mmd -i $fatpart ::/grub
	mcopy -i $fatpart bootaa64.efi ::/EFI/BOOT

	#Load PK,KEK,DB and DBX into fatpart
	mcopy -i $fatpart $TOP_DIR/tools/efitools/PK.der ::/EFI/BOOT
	mcopy -i $fatpart $TOP_DIR/tools/efitools/KEK.der ::/EFI/BOOT
	mcopy -i $fatpart $TOP_DIR/tools/efitools/DB.der ::/EFI/BOOT
	mcopy -i $fatpart $TOP_DIR/tools/efitools/DBX.der ::/EFI/BOOT
}

create_imagepart ()
{
	local image_name="$1"
	local image_size="$2"
	local ext3part_name="$3"

	cat fat_part >> $image_name
	cat $ext3part_name >> $image_name
	(echo n; echo p; echo 1; echo $PART_START; echo +$((FAT_SIZE-1)); echo t; echo 6; echo n; echo p; echo 2; echo $((PART_START+FAT_SIZE)); echo +$(($image_size-1)); echo w) | fdisk $image_name
	cp $image_name $PLATDIR
}

create_ext3part ()
{
	local ext3part_name="$1"
	local ext3size=$2
	local rootfs_file=$3

	#Sign the kernel image and copy back the Signed image
	cp $OUTDIR/linux/Image $TOP_DIR/tools/efitools/Image
	pushd $TOP_DIR/tools/efitools
	sbsign --key DB.key --cert DB.crt --output Image_signed Image
	cp Image_signed $OUTDIR/linux/Image
	popd

	echo "create_ext3part: ext3part_name = $ext3part_name ext3size = $ext3size rootfs_file = $rootfs_file"
	dd if=/dev/zero of=$ext3part_name bs=$BLOCK_SIZE count=$ext3size
	mkdir -p mnt
	#umount if it has been mounted
	if [[ $(findmnt -M "mnt") ]]; then
		fusermount -u mnt
	fi
	mkfs.ext3 -F $ext3part_name
	fuse-ext2 $ext3part_name mnt -o rw+
	cp $OUTDIR/linux/Image ./mnt
	cp $PLATDIR/ramdisk-busybox.img ./mnt
	sync
	fusermount -u mnt
	rm -rf mnt
}

prepare_disk_image ()
{
	pushd $TOP_DIR/$GRUB_PATH/output
	local IMG_BB=grub-busybox.img
	local BLOCK_SIZE=512
	local SEC_PER_MB=$((1024*2))

	#FAT Partition size of 20MB and EXT3 Partition size 200MB
	local FAT_SIZE_MB=20
	local EXT3_SIZE_MB=200
	local PART_START=$((1*SEC_PER_MB))
	local FAT_SIZE=$((FAT_SIZE_MB*SEC_PER_MB-(PART_START)))
	local EXT3_SIZE=$((EXT3_SIZE_MB*SEC_PER_MB-(PART_START)))

	#Check if PK, KEK, DB and DBX are available at "tools/efitools". If not, and if these
        #are availble as prebuilts, then copy these from the prebuilts to "tools/efitools".
	if [ ! -f $TOP_DIR/tools/efitools/PK.der ] ||
	   [ ! -f $TOP_DIR/tools/efitools/KEK.der ] ||
	   [ ! -f $TOP_DIR/tools/efitools/DB.der ] ||
	   [ ! -f $TOP_DIR/tools/efitools/DBX.der ]; then
		if [ ! -f $TOP_DIR/prebuilts/sgi/secure_boot/sgi_secure_keys/PK.der ] ||
		   [ ! -f $TOP_DIR/prebuilts/sgi/secure_boot/sgi_secure_keys/KEK.der ] ||
		   [ ! -f $TOP_DIR/prebuilts/sgi/secure_boot/sgi_secure_keys/DB.der ] ||
                   [ ! -f $TOP_DIR/prebuilts/sgi/secure_boot/sgi_secure_keys/DB.crt ] ||
                   [ ! -f $TOP_DIR/prebuilts/sgi/secure_boot/sgi_secure_keys/DB.key ] ||
                   [ ! -f $TOP_DIR/prebuilts/sgi/secure_boot/sgi_secure_keys/DBX.der ] ||
                   [ ! -f $TOP_DIR/prebuilts/sgi/secure_boot/sgi_secure_keys/nor2_flash.img ]; then
			echo "[ERROR] pre-built sercure keys and/or NOR flash image not found!"
			exit 1;
		fi
		echo "[INFO] Using PK, KEK, DB and DBX from prebuilts..."
		cp $TOP_DIR/prebuilts/sgi/secure_boot/sgi_secure_keys/PK.der $TOP_DIR/tools/efitools/PK.der
		cp $TOP_DIR/prebuilts/sgi/secure_boot/sgi_secure_keys/KEK.der $TOP_DIR/tools/efitools/KEK.der
		cp $TOP_DIR/prebuilts/sgi/secure_boot/sgi_secure_keys/DB.der $TOP_DIR/tools/efitools/DB.der
		cp $TOP_DIR/prebuilts/sgi/secure_boot/sgi_secure_keys/DB.crt $TOP_DIR/tools/efitools/DB.crt
		cp $TOP_DIR/prebuilts/sgi/secure_boot/sgi_secure_keys/DB.key $TOP_DIR/tools/efitools/DB.key
		cp $TOP_DIR/prebuilts/sgi/secure_boot/sgi_secure_keys/DBX.der $TOP_DIR/tools/efitools/DBX.der
		cp $TOP_DIR/prebuilts/sgi/secure_boot/sgi_secure_keys/nor2_flash.img ${TOP_DIR}/model-scripts/sgi/configs/$SGI_PLATFORM/nor2_flash.img
	fi

	#Sign the grub image and copy back the Signed image
	cp grubaa64.efi bootaa64.efi
	cp bootaa64.efi $TOP_DIR/tools/efitools/bootaa64.efi
	pushd $TOP_DIR/tools/efitools
	sbsign --key DB.key --cert DB.crt --output bootaa64_signed.efi bootaa64.efi
	cp bootaa64_signed.efi $TOP_DIR/$GRUB_PATH/output/bootaa64.efi
	popd

	grep -q -F 'mtools_skip_check=1' ~/.mtoolsrc || echo "mtools_skip_check=1" >> ~/.mtoolsrc
	#Create fat partition
	create_fatpart "fat_part"

	#Package images for Busybox
	rm -f $IMG_BB
	dd if=/dev/zero of=$IMG_BB bs=$BLOCK_SIZE count=$PART_START
	create_cfgfiles "fat_part" "busybox"
	#Create ext3 partition
	create_ext3part "ext3_part" $EXT3_SIZE ""
	# create image and copy into output folder
	create_imagepart $IMG_BB $EXT3_SIZE "ext3_part"

	#remove intermediate files
	rm -f fat_part
	rm -f ext3_part
}

if [ "$CMD" == "all" ] || [ "$CMD" == "package" ]; then
	#prepare the disk image
	prepare_disk_image
fi
