#!/bin/bash
hostname=reichstag
username=junker

echo 'ACCEPT_LICENSE="*"' >> /etc/portage/make.conf

source /etc/profile
export PS1="(chroot) $PS1"

emerge-webrsync

emerge -qvuDN @world
emerge cpuid2cpuflags
echo "CPU_FLAGS_X86=$(cpuid2cpuflags | grep -oP ': \K.*')" | sed 's/=/="/;s/$/"/' >> /etc/portage/make.conf
echo 'INPUT_DEVICES="synaptics libinput"' >> /etc/portage/make.conf

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

### graphics driver
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

eselect kernel list
eselect kernel set 1
genkernel all

echo hostname="$hostname" > /etc/conf.d/hostname
useradd -m -G wheel,audio,video $username

emerge -q sys-boot/grub:2
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

emerge --autounmask-write x11-base/xorg-drivers x11-base/xorg-server dev-vcs/git alacritty
etc-update
emerge x11-base/xorg-drivers x11-base/xorg-server dev-vcs/git alacritty
cd /home/$username
git clone https://github.com/bakkeby/dwm-flexipatch.git

read -n 1 -s -r -p "Press any key to continue and type password for user: $username"
passwd $username

exit
