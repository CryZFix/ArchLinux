#!/bin/bash
echo 'Прописываем имя компьютера'
read -p "Введите имя компьютера: " hostname
read -p "Введите имя пользователя: " username
echo $hostname > /etc/hostname
ln -svf /usr/share/zoneinfo/Europe/Samara /etc/localtime

echo 'Добавляем пользователя'
useradd -m -g users -G wheel -s /bin/bash $username

echo 'Создаем root пароль'
passwd

echo 'Устанавливаем пароль пользователя'
passwd $username

echo '3.4 Добавляем русскую локаль системы'
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen 

echo 'Обновим текущую локаль системы'
locale-gen

echo 'Указываем язык системы'
echo 'LANG="ru_RU.UTF-8"' > /etc/locale.conf

echo 'Вписываем KEYMAP=ru FONT=cyr-sun16'
echo 'KEYMAP=ru' >> /etc/vconsole.conf
echo 'FONT=cyr-sun16' >> /etc/vconsole.conf

echo 'Создадим загрузочный RAM диск'
mkinitcpio -p linux

echo '3.5 Устанавливаем загрузчик'
pacman-key --init
pacman-key --populate
pacman -Syy
pacman -S grub --noconfirm 
grub-install /dev/sda

echo 'Обновляем grub.cfg'
grub-mkconfig -o /boot/grub/grub.cfg

echo 'Ставим программу для Wi-fi'
pacman -S dialog wpa_supplicant netctl --noconfirm 

echo 'Устанавливаем SUDO'
echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

echo 'Раскомментируем репозиторий multilib Для работы 32-битных приложений в 64-битной системе.'
echo '[multilib]' >> /etc/pacman.conf
echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
pacman -Syy

echo 'Ставим иксы и драйвера'
pacman -S wget tar xorg-server xorg-drivers xorg-xinit pulseaudio pavucontrol bash-completion --noconfirm

echo 'Cтавим DM'
pacman -S sddm --noconfirm
systemctl enable sddm
echo 'Numlock=on' > /etc/sddm.conf

echo 'Ставим шрифты'
pacman -S ttf-liberation ttf-dejavu ttf-symbola ttf-clear-sans --noconfirm 

echo 'Ставим сеть'
pacman -S networkmanager ppp openssh --noconfirm

echo 'Подключаем автозагрузку менеджера входа и интернет'
systemctl enable NetworkManager
systemctl enable sshd
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config

echo 'Качаем и устанавливаем настройки Xfce'
  # tar -czf config.tar.gz .config для архивации настроек
mkdir downloads
cd downloads
wget https://raw.githubusercontent.com/CryZFix/Linux/main/archlinux/attach/bashrc
rm /home/$username/.bashrc
sudo mv -f bashrc /home/$username/.bashrc
wget https://github.com/CryZFix/Linux/raw/main/archlinux/attach/config.tar.gz
sudo rm -rf /home/$username/.config/*
sudo tar -xzf config.tar.gz -C /home/$username/

echo 'env user'
su $username

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

yay -Syyu i3-gaps polybar rofi pywal calc networkmanager-dmenu zramswap --noconfirm
sudo systemctl enable zramswap.service

exit
rm -rf downloads

echo 'Установка системы завершена! Перезагрузитесь вводом: reboot.'
exit
