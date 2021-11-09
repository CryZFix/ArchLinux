#!/bin/bash

mkdir files
cd files
echo 'Установка AUR (pikaur)'
sudo pacman-key --init
sudo pacman-key --populate
sudo pacman -Syy wget git curl --needed base base-devel --noconfirm
wget 'https://aur.archlinux.org/cgit/aur.git/snapshot/pikaur.tar.gz'
tar xzfv pikaur*
cd pikaur
makepkg -fsri --noconfirm
cd ..

echo 'Создаем нужные директории'
sudo pacman -S xdg-user-dirs --noconfirm
xdg-user-dirs-update

echo 'Установка базовых программ и пакетов'
sudo pacman -S f2fs-tools dosfstools xorg-xrandr ntfs-3g alsa-lib alsa-utils file-roller p7zip unrar gvfs aspell-ru pulseaudio pavucontrol --noconfirm

echo 'Установить рекомендумые программы'
pikaur -S google-chrome nomachine remmina freerdp veracrypt vlc vim icq-bin anydesk-bin whatsapp-for-linux viber libreoffice libreoffice-fresh-ru neofetch qbittorrent galculator --noconfirm
pikaur -Syy
pikaur -S xflux hunspell-ru megasync-nopdfium xorg-xkill ttf-symbola ttf-clear-sans --noconfirm
sudo pacman -Rs xfburn orage parole mousepad xfce4-appfinder xfce4-clipman-plugin xfce4-timer-plugin xfce4-time-out-plugin xfce4-artwork xfce4-taskmanager xfce4-smartbookmark-plugin xfce4-sensors-plugin xfce4-notes-plugin xfce4-netload-plugin xfce4-dplugin xfce4-mpc-plugin xfce4-mount-plugin xfce4-mailwatch-plugin xfce4-genmon-plugin xfce4-fsguard-plugin xfce4-eyes-pluiskperf-plugin xfce4-dict xfce4-cpugraph-plugin xfce4-cpufreq-plugin
pikaur -Syy anydesk-bin
sudo systemctl enable anydesk
sudo systemctl restart anydesk

echo 'Редактим конфиг NoMachine'
sudo killall nxserver.bin
wget 'https://raw.githubusercontent.com/CryZFix/ArchLinux_FastInstall_Private/main/attach/nxconfig'
sudo rm /usr/NX/etc/server.cfg
sudo mv nxconfig /usr/NX/etc/server.cfg
sudo systemctl enable nxserver
sudo systemctl restart nxserver

# Подключаем zRam
pikaur -S zramswap --noconfirm
sudo systemctl enable zramswap.service

cd ..
rm -rf files
echo 'Установка завершена.'
