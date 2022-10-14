#!/bin/bash

read -p "Enter the number of threads on your processor (not cores, just threads): " cputhreads

echo 'Creating partitions'
(
  echo o;

  echo n;
  echo;
  echo;
  echo;
  echo +2048M;
  echo a;

  echo n;
  echo;
  echo;
  echo;
  echo +4096M;

  echo n;
  echo;
  echo;
  echo;
  echo;

  echo w;
) | fdisk /dev/sda
echo 'Formatting disks'
mkfs.ext2 /dev/sda1 -L boot
mkswap /dev/sda2 -L swap
mkfs.ext4 /dev/sda3 -L root

echo 'Mounting disks'
mkdir -p /mnt/gentoo
mount /dev/sda3 /mnt/gentoo
mkdir /mnt/gentoo/boot
mount /dev/sda1 /mnt/gentoo/boot
swapon /dev/sda2

cd /mnt/gentoo

DISTMIRROR=http://distfiles.gentoo.org
DISTBASE=${DISTMIRROR}/releases/amd64/autobuilds/current-install-amd64-minimal/
FILE=$(wget -q $DISTBASE -O - | grep -o -E 'stage3-amd64-openrc-20\w*\.tar\.(bz2|xz)' | uniq)
[ -z "$FILE" ] && echo No stage3 found on $DISTBASE && exit 1
echo download latest stage file $FILE
wget $DISTBASE$FILE 

tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
rm stage3-*
curl -OL https://raw.githubusercontent.com/CryZFix/Linux/main/gentoo/genfstab
chmod +x genfstab
./genfstab /mnt/gentoo > /mnt/gentoo/etc/fstab

sed -i 's/COMMON_FLAGS="-O2 -pipe"/COMMON_FLAGS="-march=native -O2 -pipe"/' /mnt/gentoo/etc/portage/make.conf
echo MAKEOPTS='"-j'$cputhreads'"' >> /mnt/gentoo/etc/portage/make.conf

cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

mkdir /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf

mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys 
mount --make-rslave /mnt/gentoo/sys 
mount --rbind /dev /mnt/gentoo/dev 
mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run

# Make pre-configure file installer
cat > chrootstart.sh << EOF
#!/bin/bash

hostname=reichstag
username=junker
password=123456

echo 'ACCEPT_LICENSE="*"' >> /etc/portage/make.conf

source /etc/profile
export PS1="(chroot) $PS1"

emerge-webrsync

emerge -qvuDN @world
emerge cpuid2cpuflags
echo "CPU_FLAGS_X86=$(cpuid2cpuflags | grep -oP ': \K.*')" | sed 's/=/="/;s/$/"/' >> /etc/portage/make.conf
echo 'INPUT_DEVICES="synaptics libinput"' >> /etc/portage/make.conf

# graphics driver
nvidia=$(lspci | grep -e VGA -e 3D | grep 'NVIDIA' 2> /dev/null || echo '')
amd=$(lspci | grep -e VGA -e 3D | grep 'AMD' 2> /dev/null || echo '')
intel=$(lspci | grep -e VGA -e 3D | grep 'Intel' 2> /dev/null || echo '')
if [[ -n "$nvidia" ]]; then
  echo 'VIDEO_CARDS="nouveau"' >> /etc/portage/make.conf
fi

if [[ -n "$amd" ]]; then
  echo 'VIDEO_CARDS="amdgpu radeon radeonsi"' >> /etc/portage/make.conf
fi

if [[ -n "$intel" ]]; then
  echo 'VIDEO_CARDS="intel"' >> /etc/portage/make.conf
fi

echo "Europe/Samara" > /etc/timezone
emerge --config sys-libs/timezone-data

sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
echo 'ru_RU.UTF-8 UTF-8' >> /etc/locale.gen
locale-gen
eselect locale list
eselect locale set 4

sed -i 's/CONSOLEFONT="default8x16"/CONSOLEFONT="cyr-sun16"/' /etc/conf.d/consolefont
env-update && source /etc/profile
export PS1="(chroot) $PS1"

emerge -q sys-kernel/gentoo-sources sys-kernel/genkernel sys-fs/e2fsprogs sys-fs/btrfs-progs sys-fs/dosfstools dhcpcd
rc-update add dhcpcd default

eselect kernel list
eselect kernel set 1

genkernel all

echo hostname="$sethostname" > /etc/conf.d/hostname

useradd -m -G wheel,audio,video $username
echo "$username:$password" | chpasswd

emerge -q sys-boot/grub:2
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

emerge x11-base/xorg-drivers x11-base/xorg-server git alacritty
git clone https://github.com/bakkeby/dwm-flexipatch.git
cd dwm-flexipatch
make install

echo 'exec dwm &'

EOF

time chroot . ./chrootstart.sh
rm chrootstart.sh

umount var/tmp
rm -rf var/tmp/*
rm -rf var/cache/distfiles
umount *
cd /
## umount somehow fails recently, but can not find usage, lets go lazy
umount -l /mnt/gentoo  || exit 1

echo 'Installation was complity. You can reboot PC..'
