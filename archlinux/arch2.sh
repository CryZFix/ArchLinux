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

echo 'Добавляем русскую локаль системы'
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
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

echo 'Устанавливаем SUDO'
echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

echo 'Раскомментируем репозиторий multilib Для работы 32-битных приложений в 64-битной системе.'
echo '[multilib]' >> /etc/pacman.conf
echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
pacman -Syy

systemctl enable sddm
echo 'Numlock=on' > /etc/sddm.conf

echo 'Подключаем автозагрузку менеджера входа и интернет'
systemctl enable NetworkManager
systemctl enable sshd

echo 'Качаем и устанавливаем настройки'
  # tar -czf config.tar.gz .config для архивации настроек
mkdir downloads
cd downloads
wget https://raw.githubusercontent.com/CryZFix/Linux/test/archlinux/attach/bashrc
rm /home/$username/.bashrc
sudo mv -f bashrc /home/$username/.bashrc
wget https://github.com/CryZFix/Linux/raw/test/archlinux/attach/config.tar.gz
sudo rm -rf /home/$username/.config/*
sudo tar -xzf config.tar.gz -C /home/$username/
cd /home/$username/
curl -OL https://raw.githubusercontent.com/CryZFix/Linux/test/archlinux/arch3.sh

cd
rm -rf downloads

echo 'Установка системы завершена! Перезагрузитесь вводом: reboot.'
exit
