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

echo "This is a test script to check the MPMM functionality"
echo ""
echo "This is based on the PCT configured in the SCP which can be found at"
echo "product/tc2/scp_ramfw/config_mpmm.c"

retry=0

check_current_frequency() {
	cur_freq=$(cat /sys/devices/system/cpu/"$1"/cpufreq/cpuinfo_cur_freq)
	echo "Current set frequency of the $1 is $cur_freq"
	if [ $cur_freq -gt $2 ]; then
		if [ $retry -lt 3 ]; then
			echo "Failed and retrying.."
			sleep 0.05
			retry=$((retry+1))
			check_current_frequency $1 $2
		else
			retry=0
			echo "FAIL"
		fi
	else
		retry=0
		echo "PASS"
	fi
}

check_one_power_domain() {
	cpu_index=$1
	pct_array=$2
	i=0
	mpmm_test_pid=""
	cpu_core="cpu${cpu_index}"
	for max_freq in $pct_array ; do
		if [ $i -ne 0 ]; then
			echo ""
			echo "Starting a vector intensive workload on cpu$cpu_index"
			cpu_mask=$( printf "%x" $((1<<cpu_index)) )
			taskset $cpu_mask vector_workload &
			sleep 0.05
			cpu_index=$((cpu_index+1))
			mpmm_test_pid="$mpmm_test_pid $!"
		fi
		echo "According to the PCT, the max frequency should be $max_freq"
		check_current_frequency $cpu_core $max_freq
		i=$((i+1))
	done
	for pid in $mpmm_test_pid ; do
		kill -9 $pid
	done
}

if [ "$1" = "fvp" ]; then
	echo ""
	echo "Testing MPMM in FVP"
	echo ""
	echo "Testing the MPMM of A520 cores"
	echo "******************************"
	cpu_index=0
	check_one_power_domain 0 '1840000 1537000 1537000 1153000 1153000'
	echo ""
	echo "Testing the MPMM of A720 cores"
	echo "******************************"
	cpu_index=4
	check_one_power_domain 4 '2271000 1893000 1893000 1893000'
	echo ""
	echo "Testing the MPMM of X4 cores"
	echo "******************************"
	cpu_index=7
	check_one_power_domain 7 '3047000 2612000'
elif [ "$1" = "fpga" ]; then
	echo ""
	echo "Testing MPMM in FPGA"
	echo ""
	echo "Testing the MPMM of A520 cores"
	echo "******************************"
	cpu_index=0
	check_one_power_domain 0 '1840000 1537000 1537000 1153000 1153000'
	echo ""
	echo "Testing the MPMM of A720 cores"
	echo "******************************"
	cpu_index=4
	check_one_power_domain 4 '2650000 2650000 2271000 1893000 1419000 946000'
	echo ""
	echo "Testing the MPMM of X4-Min cores"
	echo "******************************"
	cpu_index=9
	check_one_power_domain 4 '3047000 3047000 2612000 1893000'
	echo ""
	echo "Testing the MPMM of X4 cores"
	echo "******************************"
	cpu_index=12
	check_one_power_domain 7 '3047000 3047000 2612000'

fi
