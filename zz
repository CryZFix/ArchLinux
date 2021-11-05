#!/bin/bash
mkdir ~/downloads
cd ~/downloads

echo 'Качаем и устанавливаем настройки Xfce'
  # Чтобы сделать копию ваших настоек перейдите в домашнюю директорию ~/username 
  # открйте в этой категории терминал и выполните команду ниже
  # Предварительно можно очистить конфиг от всего лишнего
  # tar -czf config.tar.gz .config
  # Выгрузите архив в интернет и скорректируйте ссылку на свою.
wget https://github.com/cryzfix/ArchLinux_FastInstall_Private/raw/main/attach/config.tar.gz
sudo rm -rf ~/.config/*
sudo tar -xzf config.tar.gz -C ~/
wget https://github.com/CryZFix/ArchLinux_FastInstall_Private/raw/main/attach/bg.jpg
sudo rm -rf /usr/share/backgrounds/xfce/* #Удаляем стандартные обои
sudo mv -f ~/downloads/bg.jpg /usr/share/backgrounds/xfce/bg.jpg

# Очистка
rm -rf ~/downloads/

echo 'Установка завершена! 
