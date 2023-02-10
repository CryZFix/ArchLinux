#!/bin/bash
username=junker

APPS='google-chrome polybar calc networkmanager-dmenu-git'

cd /home/$username
mkdir -p files
cd files
echo 'Установка AUR (pikaur)'
sudo pacman-key --init
sudo pacman-key --populate
sudo pacman -Syyu wget git curl --needed base base-devel --noconfirm
wget 'https://aur.archlinux.org/cgit/aur.git/snapshot/pikaur.tar.gz'
tar xzfv pikaur*
cd pikaur
makepkg -fsri --noconfirm
cd ..
cd ..
rm -rf files

pikaur -Syyu $APPS --noconfirm
