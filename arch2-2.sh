#!/bin/bash
ln -svf /usr/share/zoneinfo/Europe/Samara /etc/localtime

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

echo 'Раскомментируем репозиторий multilib Для работы 32-битных приложений в 64-битной системе.'
echo '[multilib]' >> /etc/pacman.conf
echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
pacman -Syy
pacman -S wget tar bash-completion --noconfirm

echo 'Ставим шрифты'
pacman -S ttf-liberation ttf-dejavu --noconfirm 

echo 'Ставим сеть'
pacman -S networkmanager networkmanager-openvpn networkmanager-vpnc networkmanager-openconnect networkmanager-pptp network-manager-applet ppp openssh --noconfirm

echo 'Подключаем автозагрузку менеджера входа и интернет'
systemctl enable NetworkManager
systemctl enable sshd
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config

rm -rf downloads

echo 'Создаем root пароль'
passwd

echo 'Установка системы завершена! Перезагрузитесь вводом: reboot.'
exit
