#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

apt-get -y update
apt-get -y install bc \
                   bison \
                   build-essential \
                   chrpath \
                   cpio \
                   curl \
                   debianutils \
                   diffstat \
                   doxygen \
                   dwarves \
                   file \
                   flex \
                   gawk \
                   gcc-9 \
                   gdisk \
                   git \
                   git-core \
                   git-lfs \
                   glibc-source \
		   golang \
		   libwayland-bin \
                   iputils-ping \
                   lib32ncurses5-dev \
                   libatomic1 \
                   libdbus-1-3 \
                   libegl1-mesa \
                   libelf-dev \
                   libgl1-mesa-glx \
                   libgnutls28-dev \
                   liblz4-tool \
                   libncurses5 \
                   libsdl1.2-dev \
                   libssl-dev \
                   libstdc++6 \
                   libz-dev \
                   lsb-core \
                   m4 \
                   make \
                   nano \
                   ninja-build \
                   openssl \
                   parted \
                   python-is-python3 \
                   python3 \
                   python3-git \
                   python3-jinja2 \
                   python3-pexpect \
                   python3-pip \
                   rsync \
                   socat \
                   srecord \
                   telnet \
                   texinfo \
                   u-boot-tools \
                   udev \
                   unzip \
                   uuid-runtime \
                   vim \
                   wget \
                   xterm \
                   xz-utils \
                   zip \
                   zstd

#Get wayland 1.18.0 for debian
wget https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/wayland/1.18.0-1/wayland_1.18.0.orig.tar.gz
tar -xvzf wayland_1.18.0.orig.tar.gz

# Install ubuntu packages based on ubuntu versions - Refer to the user guide for more info
U_VER_22_04=22.04
U_VER_20_04=20.04
U_VER_18_04=18.04
OUT=`lsb_release -a | awk '/Description:/ {print $3}'`
U_VER=`echo $OUT | awk -F '.' '{printf("%0.2d.%0.2d", $1, $2)}'`
echo U_VER=$U_VER
if [ $U_VER == $U_VER_22_04 ];
then
	if [ $(dpkg-query -W -f='${Status}' pylint 2>/dev/null | grep -c "ok installed") -eq 0 ];
	then
		apt install pylint python-is-python3 -y
	fi
elif [ $U_VER == $U_VER_20_04 ];
then
	if [ $(dpkg-query -W -f='${Status}' pylint 2>/dev/null | grep -c "ok installed") -eq 0 ];
	then
		apt install pylint python -y
	fi
elif [ $U_VER == $U_VER_18_04 ];
then
	if [ $(dpkg-query -W -f='${Status}' pylint3 python-pip 2>/dev/null | grep -c "ok installed") -eq 0 ];
	then
		apt install pylint3 python-pip python -y
	fi
fi
