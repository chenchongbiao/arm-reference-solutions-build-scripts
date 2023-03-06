#!/bin/sh

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

echo "Testing the number of partitions supported.  It should be 0-63"
if [ -d "/sys/fs/mpam/partitions/63" ] && ! [ -d "/sys/fs/mpam/partitions/64" ];
then
	echo -e "Pass\n"
else
	echo -e "Fail\n"
fi

echo "Partition 0 is the default partition to which all tasks will be assigned.  Checking if task 5 is assigned to partition 0"
if grep -Fxq "5" /sys/fs/mpam/partitions/0/tasks
then
    echo -e "Pass\n"
else
    echo -e "Fail\n"
fi

echo "Testing the number of bits required to set the cache portion bitmap. It should be 8"
if grep -Fxq "8" /sys/devices/platform/100010000.msc0/mpam/cpbm_nbits
then
    echo -e "Pass\n"
else
    echo -e "Fail\n"
fi

echo "Testing the default cpbm configured in the DSU for all the partitions.  It should be 0-7 for all the partitions"
if grep -Fxq "0-7" /sys/devices/platform/100010000.msc0/mpam/partitions/0/cpbm
then
    echo -e "Pass\n"
else
    echo -e "Fail\n"
fi

echo "Setting the cpbm 4-5 (00110000) in DSU for partition 45 and reading it back"
echo 4-5 > /sys/devices/platform/100010000.msc0/mpam/partitions/45/cpbm

if grep -Fxq "4-5" /sys/devices/platform/100010000.msc0/mpam/partitions/45/cpbm
then
    echo -e "Pass\n"
else
    echo -e "Fail\n"
fi
