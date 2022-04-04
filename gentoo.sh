#!/bin/bash

echo 'Partition BIOS or UEFI'
read -p "1 - BIOS, 2 - UEFI: " node_set
if [[ $node_set == 1 ]]; then
echo 'Creating partitions'
(
  echo o;

  echo n;
  echo;
  echo;
  echo;
  echo +2048M;

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
elif [[ $node_set == 0 ]]; then
echo 'Creating partitions'
(
  echo g;

  echo n;
  echo;
  echo;
  echo +2048M;
  echo t;
  echo 1;

  echo n;
  echo;
  echo;
  echo +4096M;
  echo t;
  echo 2;
  echo 19;

  echo n;
  echo;
  echo;
  echo;
  echo;

  echo w;
) | fdisk /dev/sda

echo 'Formatting disks'
mkfs.vfat -F 32 /dev/sda1 -L boot
mkswap /dev/sda2 -L swap
mkfs.ext4 /dev/sda3 -L root
fi

echo 'Mounting disks'
mount /dev/sda3 /mnt/gentoo
mkdir /mnt/gentoo/boot
mount /dev/sda1 /mnt/gentoo/boot
swapon /dev/sda2

read -p "Enter the date and time in the format > MMDDhhmmYYYY: " datatime
date $datatime

cd /mnt/gentoo

echo 'Select the desired stage3 -- tar.xz'
read -n 1 -s -r -p "Press any key to continue"
links 'https://mirror.yandex.ru/gentoo-distfiles/releases/amd64/autobuilds/current-stage3-amd64-openrc/'

tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner

sed -i 's/COMMON_FLAGS="-O2 -pipe"/COMMON_FLAGS="-march=native -O2 -pipe"/' /mnt/gentoo/etc/portage/make.conf
read -p "Enter the number of threads on your processor (not cores, just threads): " cputhreads
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

chroot /mnt/gentoo sh -c "$(curl -fsSL https://raw.githubusercontent.com/CryZFix/ArchLinux/main/gentoo2.sh)"

cd
umount -l /mnt/gentoo/dev{/shm,/pts,} 
umount -R /mnt/gentoo

echo 'Installation was complity. You can reboot PC..'
