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

set -e

echo "Creating MMC bootable deepin image"

# MMC Bootable image
OUT_IMG=${OUT_IMG:-deepin_fs.img}

size_in_mb() {
        local size_in_bytes
        size_in_bytes=$(wc -c $1)
        size_in_bytes=${size_in_bytes%% *}
        echo $((size_in_bytes / 1024 / 1024 + 1))
}

# deepin Raw filesystem
DEEPIN_IMG=${DEEPIN_IMG:-deepin.img}
DEEPIN_SIZE=$(size_in_mb ${DEEPIN_IMG})
IMAGE_LEN=$((DEEPIN_SIZE + 2 ))

# measured in MBytes
PART1_START=1
PART1_END=$((PART1_START + DEEPIN_SIZE))

PARTED="parted -a min "

# Create an empty disk image file
dd if=/dev/zero of=$OUT_IMG bs=1M count=3K

# Create a partition table
$PARTED $OUT_IMG unit s mktable gpt

# Create partitions
SEC_PER_MB=$((1024*2))
$PARTED $OUT_IMG unit s mkpart deepin ext4 $((PART1_START * SEC_PER_MB)) $((PART1_END * SEC_PER_MB - 1))

# Assemble all the images into one final image (There is one deepin image as of Today)
dd if=$DEEPIN_IMG of=$OUT_IMG bs=1M seek=${PART1_START} conv=notrunc
