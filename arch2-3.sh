#!/bin/bash
echo '[multilib]' >> /etc/pacman.conf
echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf

ln -svf /usr/share/zoneinfo/Europe/Samara /etc/localtime

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen 

locale-gen

echo 'LANG="ru_RU.UTF-8"' > /etc/locale.conf

echo 'KEYMAP=ru' >> /etc/vconsole.conf
echo 'FONT=cyr-sun16' >> /etc/vconsole.conf

mkinitcpio -p linux

pacman-key --init
pacman-key --populate
pacman -Syy
pacman -S grub --noconfirm 
grub-install /dev/sda

grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable dhcpcd
systemctl enable sshd
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config

echo 'Создаем root пароль'
passwd

echo 'Установка системы завершена! Перезагрузитесь вводом: reboot.'
exit
