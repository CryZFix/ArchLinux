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
  echo +500M;

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

echo 'Ваша разметка диска'
fdisk -l

echo '2.4.2 Форматирование дисков'
mkfs.ext2  /dev/sda1 -L boot
mkfs.ext4  /dev/sda3 -L root
mkswap /dev/sda2 -L swap

echo '2.4.3 Монтирование дисков'
mount /dev/sda3 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
swapon /dev/sda2

echo '3.1 Выбор зеркал для загрузки. Ставим зеркало от Яндекс'
echo "Server = http://mirror.yandex.ru/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
echo "Server = https://mirror.rol.ru/archlinux/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist

echo '3.2 Установка основных пакетов'
pacstrap /mnt base base-devel linux linux-firmware nano dhcpcd netctl ttf-liberation ttf-dejavu wget tar bash-completion openssh dialog wpa_supplicant

echo '3.3 Настройка системы'
genfstab -pU /mnt >> /mnt/etc/fstab

echo 'С грфикой?'
read -p "1 - Да, 0 - Нет: " node_set
if [[ $node_set == 1 ]]; then
arch-chroot /mnt sh -c "$(curl -fsSL git.io/alfi2.sh)"
elif [[ $node_set == 0 ]]; then
arch-chroot /mnt sh -c "$(curl -fsSL https://raw.githubusercontent.com/CryZFix/ArchLinux_FastInstall_Private/main/arch2-2.sh)"
fi
