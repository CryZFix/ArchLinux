#!/bin/bash

##############################################
ESSENTIAL='base base-devel linux linux-firmware nano dhcpcd netctl openssh dialog wpa_supplicant zsh'
##############################################
DRIVERS='xorg-server xorg-xinit ntfs-3g gvfs os-prober'
##############################################
APPS='i3-gaps grub rofi alacritty dmenu pulseaudio pavucontrol wget tar networkmanager ppp git curl tree vim ranger'
##############################################
FONTS='ttf-liberation ttf-dejavu ttf-liberation ttf-dejavu'
##############################################
OPTS='bash-completion telegram-desktop tmux picom nitrogen ffmpegthumbnailer ueberzug zsh-theme-powerlevel10k pkgfile'

timedatectl set-ntp true

echo 'Parts'
(
  echo o;

  echo n;
  echo;
  echo;
  echo;
  echo +800M;
  echo a;

  echo n;
  echo;
  echo;
  echo;
  echo +2048M;

  echo n;
  echo;
  echo;
  echo;
  echo;

  echo w;
) | fdisk /dev/sda

# Formating
mkfs.ext2  /dev/sda1 -L boot
mkfs.ext4  /dev/sda3 -L root
mkswap /dev/sda2 -L swap

# Mounting
mount /dev/sda3 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
swapon /dev/sda2

# Necessary helper for sorting mirrors
curl -sSL 'https://www.archlinux.org/mirrorlist/?country=RU&protocol=https&ip_version=4' | sed 's/^#Server/Server/g' > /etc/pacman.d/mirrorlist
pacman -Sy
pacman -S --noconfirm pacman-contrib

update_mirrorlist(){
  curl -sSL 'https://www.archlinux.org/mirrorlist/?country=RU&protocol=https&ip_version=4&use_mirror_status=on' | sed 's/^#Server/Server/g' | rankmirrors - > /etc/pacman.d/mirrorlist
}
sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 5/g' /etc/pacman.conf
update_mirrorlist
pacman -Syy

# Install the base packages
pacstrap /mnt $ESSENTIAL $DRIVERS $APPS $FONTS $OPTS

# Generate fstab
genfstab -pU /mnt >> /mnt/etc/fstab

arch-chroot /mnt sh -c "$(curl -fsSL https://raw.githubusercontent.com/CryZFix/Linux/main/archlinux/arch2.sh)"
