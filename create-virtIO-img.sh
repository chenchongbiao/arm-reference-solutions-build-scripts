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
    info_echo "Creating an empty disk image..."

    if [ ! -d $DEB_VIRTIO_IMAGE_PATH ]; then
        mkdir -p $DEB_VIRTIO_IMAGE_PATH
        dd if=/dev/zero of=$DEB_VIRTIO_IMAGE_PATH/$DEB_VIRTIO_IMAGE_NAME bs=$DEB_VIRTIO_RW_BYTES_SIZE count=$DEB_VIRTIO_BLOCK_COUNT

        info_echo "Formatting the disk image (ext4) ..."
        mkfs.ext4 $DEB_VIRTIO_IMAGE_PATH/$DEB_VIRTIO_IMAGE_NAME
    else
        info_echo "disk already exists!"
    fi
}

do_clean() {
    info_echo "Destroying the disk image..."
    rm -rf $DEB_VIRTIO_IMAGE_PATH
    rm -f $DEPLOY_DIR/$PLATFORM/$DEB_VIRTIO_IMAGE_NAME
}

do_deploy() {
    info_echo "Deploying the disk image"
    if [ ! -f $DEPLOY_DIR/$PLATFORM/debian_disk_image ]; then
	ln -s $DEB_VIRTIO_IMAGE_PATH/$DEB_VIRTIO_IMAGE_NAME $DEPLOY_DIR/$PLATFORM/debian_disk_image
    fi
    info_echo "Please follow $DEBIAN_README to mount debian filesystem to virtIO disk image."
}

source "$(dirname ${BASH_SOURCE[0]})/framework.sh"
