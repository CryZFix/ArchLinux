#!/bin/bash

echo ACCEPT_LICENSE="*" >> /etc/portage/make.conf

source /etc/profile
export PS1="(chroot) $PS1"

emerge-webrsync

eselect profile list
read -p "Enter number your choice profile: " setprofile
eselect profile set $setprofile

emerge -qavuDN @world
emerge cpuid2cpuflags
echo "CPU_FLAGS_X86=$(cpuid2cpuflags | grep -oP ': \K.*')" | sed 's/=/="/;s/$/"/' >> /etc/portage/make.conf

echo "Europe/Samara" > /etc/timezone
emerge --config sys-libs/timezone-data

echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
echo 'ru_RU.UTF-8 UTF-8' >> /etc/locale.gen
locale-gen
eselect locale list
read -p "Enter number your choice locale: " setlocale
eselect locale set $setlocale

sed -i 's/CONSOLEFONT="default8x16"/CONSOLEFONT="cyr-sun16"/' /etc/conf.d/consolefont
env-update && source /etc/profile
export PS1="(chroot) $PS1"

emerge -q sys-kernel/gentoo-sources sys-kernel/genkernel sys-fs/e2fsprogs sys-fs/btrfs-progs sys-fs/dosfstools dhcpcd
rc-update add dhcpcd default
echo '/dev/sda1         /boot       ext4        defaults                0 2' > /etc/fstab
eselect kernel list
read -p "Enter number of kernel: " setkernel
eselect kernel set $setkernel
genkernel all
echo '/dev/sda2         none        swap        sw                      0 0' >> /etc/fstab
echo '/dev/sda3         /           btrfs       noatime                 0 1' >> /etc/fstab

read -p "Enter name your PC: " sethostname
echo hostname="$sethostname" > /etc/conf.d/hostname

read -p "Enter username: " username
useradd -m -G wheel,audio,video $username
passwd $username
passwd

emerge -q sys-boot/grub:2
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

exit
