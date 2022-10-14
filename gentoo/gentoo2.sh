#!/bin/bash
hostname=reichstag
username=junker

echo 'ACCEPT_LICENSE="*"' >> /etc/portage/make.conf

source /etc/profile
export PS1="(chroot) $PS1"

emerge-webrsync

eselect profile list
read -p "Enter number your choice profile: " setprofile
eselect profile set $setprofile

emerge -qvuDN @world
emerge cpuid2cpuflags
echo "CPU_FLAGS_X86=$(cpuid2cpuflags | grep -oP ': \K.*')" | sed 's/=/="/;s/$/"/' >> /etc/portage/make.conf

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

emerge -q sys-kernel/gentoo-kernel-bin sys-fs/e2fsprogs sys-fs/btrfs-progs sys-fs/dosfstools dhcpcd
rc-update add dhcpcd default

eselect kernel list
eselect kernel set 1
genkernel all

echo hostname="$hostname" > /etc/conf.d/hostname
useradd -m -G wheel,audio,video $username
### IF NOT SET_PASS is set then the password will be "password"
SET_PASS=${SET_PASS:-password}
echo "$username:${SET_PASS}" | chpasswd

emerge -q sys-boot/grub:2

grub-install /dev/sda

grub-mkconfig -o /boot/grub/grub.cfg

exit
