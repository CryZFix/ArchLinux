#!/bin/bash

read -p "Enter the number of threads on your processor (not cores, just threads): " cputhreads

### Creating partitions
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

### Formatting disks
mkfs.ext2 /dev/sda1 -L boot
mkswap /dev/sda2 -L swap
mkfs.ext4 /dev/sda3 -L root

### Mounting disks
mount /dev/sda3 /mnt/gentoo
mkdir /mnt/gentoo/boot
mount /dev/sda1 /mnt/gentoo/boot
swapon /dev/sda2

### Download and run make fstab script
curl -OL https://raw.githubusercontent.com/CryZFix/Linux/main/gentoo/genfstab
chmod +x genfstab
mkdir -p /mnt/gentoo/etc
./genfstab /mnt/gentoo > /mnt/gentoo/etc/fstab

### Download stage3 and extract
cd /mnt/gentoo
DISTMIRROR=http://distfiles.gentoo.org
DISTBASE=${DISTMIRROR}/releases/amd64/autobuilds/current-install-amd64-minimal/
FILE=$(wget -q $DISTBASE -O - | grep -o -E 'stage3-amd64-openrc-20\w*\.tar\.(bz2|xz)' | uniq)
[ -z "$FILE" ] && echo No stage3 found on $DISTBASE && exit 1
echo download latest stage file $FILE
wget $DISTBASE$FILE
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner

### Add FLAGS 
sed -i 's/COMMON_FLAGS="-O2 -pipe"/COMMON_FLAGS="-march=native -O2 -pipe"/' /mnt/gentoo/etc/portage/make.conf
echo MAKEOPTS='"-j'$cputhreads'"' >> /mnt/gentoo/etc/portage/make.conf

cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

mkdir /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf

### Mount opt's dirs
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys 
mount --make-rslave /mnt/gentoo/sys 
mount --rbind /dev /mnt/gentoo/dev 
mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run

chroot /mnt/gentoo sh -c "$(curl -fsSL https://raw.githubusercontent.com/CryZFix/linux/main/gentoo/gentoo2.sh)"

cd
umount -l /mnt/gentoo/dev{/shm,/pts,} 
umount -R /mnt/gentoo

echo 'Installation was complity. You can reboot PC..'
