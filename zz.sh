#!/bin/bash
mkdir ~/downloads
cd ~/downloads

wget https://github.com/CryZFix/ArchLinux_FastInstall_Private/raw/main/attach/bg.jpg
sudo rm -rf /usr/share/backgrounds/xfce/* #Удаляем стандартные обои
sudo mv -f ~/downloads/bg.jpg /usr/share/backgrounds/xfce/bg.jpg

# Очистка
rm -rf ~/downloads/

echo 'Установка завершена! 
