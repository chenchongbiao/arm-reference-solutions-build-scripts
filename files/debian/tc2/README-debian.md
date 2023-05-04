These manual steps are required to create Debian filesystem and mount it on virtIO disk image.
All these steps require sudo permission so they are not in any script for security reasons.

#######################################################################
######################### BUILD DEBIAN ################################
#######################################################################

# Run fetch-debian.sh from build-scripts directory for Stage 1 of building Debian filesystem

# Run below steps from chroot for Stage 2 of building Debian filesystem
distro=bullseye
export LANG=C

# It builds debian based on the packages fetched in stage 1
/debootstrap/debootstrap --second-stage

cat <<EOT > /etc/apt/sources.list
# (COPY AND PASTE below lines - This helps to install the dependencies using apt)

deb     http://ftp.jp.debian.org/debian  bullseye           main contrib non-free
deb-src http://ftp.jp.debian.org/debian  bullseye           main contrib non-free
deb     http://ftp.jp.debian.org/debian  bullseye-updates   main contrib non-free
deb-src http://ftp.jp.debian.org/debian  bullseye-updates   main contrib non-free
deb     http://security.debian.org       bullseye-security  main contrib non-free
deb-src http://security.debian.org       bullseye-security  main contrib non-free
EOT

cat <<EOT > /etc/apt/apt.conf.d/71-no-recommends
# (COPY AND PASTE below lines)

APT::Install-Recommends "0";
APT::Install-Suggests   "0";
EOT

# Add hostname
echo "debian_tc" > /etc/hostname

# Remove existing passwd if any
sed -i -e "s/root:x:0:0/root::0:0/g" /etc/passwd

# Reduce package number installed by apt:
echo "APT::Install-Recommends "0" ; APT::Install-Suggests "0" ; " > /etc/apt/apt.conf.d/80donotinstallsuggested

# Set root password
echo "root:root" | chpasswd

# Update debian
apt update && apt upgrade first.

#exit from chroot
exit

##########################################################################
############# MOUNT DEBIAN FILESYSTEM TO VIRTIO DISK IMAGE ###############
##########################################################################

Please follow the steps execution sequence in below order:

# Create a mount point, it requires sudo permission
mkdir mount_point

# Mount the filesystem (mount_point) to virtIO disk image (debian_disk_image)
# Please refer build-scripts/config/ddk.cfg for virtIO debian_disk_image path information
sudo mount <path to virtIO disk image>/debian_disk_image mount_point

# Copy the debian filesystem content into mount_point

# mount command will show mounted filesystem, you should see "type ext4 (rw,relatime)" for the debian mount
mount | grep debian_disk_image


##########################################################################
############## COPY DDK FILES TO THE FILESYSTEM ##########################
##########################################################################

# Copy the GPU DDK files from location $DEPLOY_DIR/ddk/lib/ to debian filesystem mount_point under /lib/

# At this stage mount_point has Debian filesystem along with GPU DDK files.

###########################################################################
################### STEPS TO RUN WESTON AFTER BOOTUP ######################
###########################################################################

# Load mali driver module
insmod /usr/lib/aarch64-linux-gnu/mali/wayland/mali_kbase.ko

# Pre-requisite for Weston
mkdir -p /tmp/wayland && chmod 700 /tmp/wayland
export XDG_RUNTIME_DIR=/tmp/wayland/
export LD_LIBRARY_PATH=/usr/lib/aarch64-linux-gnu/mali/wayland/
export WAYLAND_DISPLAY=wayland-0

# Launch weston in the background
LD_LIBRARY_PATH=/usr/lib/aarch64-linux-gnu/mali/wayland/ XDG_RUNTIME_DIR=/tmp/wayland weston --backend=drm-backend.so --tty=1 --idle-time=0 --drm-device=card0 &

# Run weston clients applications (Examples below):
weston-image <jpg image> &
weston-terminal &

# Alternatively, run /usr/lib/aarch64-linux-gnu/mali/wayland/run_weston.sh which executes above commands and launch the weston automatically.
