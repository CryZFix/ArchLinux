#!/bin/bash

##############################################
ESSENTIAL='base base-devel linux linux-firmware nano dhcpcd netctl openssh dialog wpa_supplicant'
##############################################
DRIVERS='xorg-server xorg-drivers xorg-xinit'
##############################################
APPS='i3-gaps sddm grub xterm rofi dmenu pulseaudio pavucontrol wget tar bash-completion networkmanager ppp git curl'
##############################################
FONTS='ttf-liberation ttf-dejavu ttf-liberation ttf-dejavu ttf-symbola ttf-clear-sans'

loadkeys ru
setfont cyr-sun16

echo 'Синхронизация системных часов'
timedatectl set-ntp true

echo 'Создание разделов'
(
  echo o;

  echo n;
  echo;
  echo;
  echo;
  echo +700M;

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

echo 'Форматирование дисков'
mkfs.ext2  /dev/sda1 -L boot
mkfs.ext4  /dev/sda3 -L root
mkswap /dev/sda2 -L swap

echo 'Монтирование дисков'
mount /dev/sda3 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
swapon /dev/sda2

pacstrap /mnt $ESSENTIAL $DRIVERS $APPS $FONTS

echo '3.3 Настройка системы'
genfstab -pU /mnt >> /mnt/etc/fstab

arch-chroot /mnt sh -c "$(curl -fsSL https://raw.githubusercontent.com/CryZFix/Linux/test/archlinux/arch2.sh)"