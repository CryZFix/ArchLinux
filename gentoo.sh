#!/bin/bash

loadkeys ru
setfont cyr-sun16

echo '2.3 Синхронизация системных часов'
timedatectl set-ntp true

echo '2.4 создание разделов'
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

echo '2.4.2 Форматирование дисков'
mkfs.ext2  /dev/sda1 -L boot
mkfs.ext4  /dev/sda3 -L root
mkswap /dev/sda2 -L swap

echo '2.4.3 Монтирование дисков'
mount /dev/sda3 /mnt/gentoo
mkdir /mnt/boot
mount /dev/sda1 /mnt/gentoo/boot
swapon /dev/sda2

read -p "Enter the date and time in the format > MMDDhhmmYYYY: " datatime
date $datatime

cd /mnt/gentoo

links 'https://mirror.yandex.ru/gentoo-distfiles/releases/amd64/autobuilds/current-stage3-amd64-openrc/'

tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner

read -p "Enter the number of threads on your processor (not cores, just threads): " cputhreads
echo MAKEOPTS="$cputhreads" >> /mnt/gentoo/etc/portage/make.conf

cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys 
mount --make-rslave /mnt/gentoo/sys 
mount --rbind /dev /mnt/gentoo/dev 
mount --make-rslave /mnt/gentoo/dev