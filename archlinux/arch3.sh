#!/bin/bash

mkdir -p files
cd files
echo 'Установка AUR (yay)'
sudo pacman-key --init
sudo pacman-key --populate
sudo pacman -Syyu wget git curl --needed base base-devel --noconfirm
wget 'https://aur.archlinux.org/cgit/aur.git/snapshot/yay.tar.gz'
tar xzfv yay*
cd yay
makepkg -fsri --noconfirm
cd ..
cd ..
rm -rf files
echo "[[ -f ~/.bashrc ]] && . ~/.bashrc" > /home/$username/.bash_profile

yay -Syyu i3-gaps polybar rofi pywal calc networkmanager-dmenu zramswap --noconfirm
sudo systemctl enable zramswap.service

exit
