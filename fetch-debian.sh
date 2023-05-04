# Install debootstrap
echo "Installing debootstrap"
sudo apt-get -y install debootstrap
export targetdir=debian11-rootfs
export distro=bullseye
mkdir $PWD/$targetdir
sudo chown root $PWD/$targetdir

# Fetch the debian packages. Also fetch weston.
echo "Fetching debian and Weston packages"
sudo debootstrap --arch=arm64 --include weston --foreign $distro $PWD/$targetdir
sudo cp /etc/resolv.conf $PWD/$targetdir/etc
sudo chroot $PWD/$targetdir
