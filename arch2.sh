#!/bin/bash
read -p "Введите имя компьютера: " hostname
read -p "Введите имя пользователя: " username

echo 'Прописываем имя компьютера'
echo $hostname > /etc/hostname
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

echo 'Добавляем пользователя'
useradd -m -g users -G wheel -s /bin/bash $username

echo 'Создаем root пароль'
passwd

echo 'Устанавливаем пароль пользователя'
passwd $username

echo 'Устанавливаем SUDO'
echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

echo 'Раскомментируем репозиторий multilib Для работы 32-битных приложений в 64-битной системе.'
echo '[multilib]' >> /etc/pacman.conf
echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
pacman -Syy

echo 'Ставим иксы и драйвера'
pacman -S wget tar xorg-server xorg-drivers xorg-xinit pulseaudio pavucontrol bash-completion --noconfirm

echo "Ставим XFCE"
pacman -S xfce4 xfce4-goodies --noconfirm

echo 'Cтавим DM'
pacman -S sddm --noconfirm
systemctl enable sddm
echo 'Numlock=on' > /etc/sddm.conf

echo 'Ставим шрифты'
pacman -S ttf-liberation ttf-dejavu --noconfirm 

echo 'Ставим сеть'
pacman -S networkmanager network-manager-applet ppp --noconfirm

echo 'Подключаем автозагрузку менеджера входа и интернет'
systemctl enable NetworkManager

echo 'Качаем и устанавливаем настройки Xfce'
  # Чтобы сделать копию ваших настоек перейдите в домашнюю директорию ~/username 
  # открйте в этой категории терминал и выполните команду ниже
  # Предварительно можно очистить конфиг от всего лишнего
  # tar -czf config.tar.gz .config
  # Выгрузите архив в интернет и скорректируйте ссылку на свою.
pacman -S arc-gtk-theme
mkdir downloads
cd downloads
wget https://github.com/cryzfix/ArchLinux_FastInstall_Private/raw/main/attach/config.tar.gz
sudo rm -rf /home/$username/.config/xfce4*
sudo tar -xzf config.tar.gz -C /home/$username/
wget https://github.com/CryZFix/ArchLinux_FastInstall_Private/raw/main/attach/bg.jpg
sudo rm -rf /usr/share/backgrounds/xfce/* #Удаляем стандартные обои
sudo mv -f bg.jpg /usr/share/backgrounds/xfce/bg.jpg

echo 'Делаем авто вход без DE?'
read -p "1 - Да, 0 - Нет: " node_set
if [[ $node_set == 1 ]]; then
sudo systemctl disable sddm
sudo pacman -R sddm --noconfirm
sudo pacman -S xorg-xinit --noconfirm
cp /etc/X11/xinit/xserverrc /home/$username/.xserverrc
wget https://raw.githubusercontent.com/ordanax/arch/master/attach/.xinitrc
sudo mv -f .xinitrc /home/$username/.xinitrc
wget https://raw.githubusercontent.com/ordanax/arch/master/attach/.bashrc
rm /home/$username/.bashrc
sudo mv -f .bashrc /home/$username/.bashrc
sudo echo -e '[Service]\nExecStart=\nExecStart=-/usr/bin/agetty --autologin' "$username" '--noclear %I $TERM' > override.conf
sudo mkdir /etc/systemd/system/getty@tty1.service.d/
sudo mv -f override.conf /etc/systemd/system/getty@tty1.service.d/override.conf
elif [[ $node_set == 0 ]]; then
  echo 'Пропускаем.'
fi

rm -rf downloads

echo 'Установка завершена! Перезагрузите систему.'
echo 'Если хотите подключить AUR, установить мои конфиги XFCE, тогда после перезагрзки и входа в систему, установите wget (sudo pacman -S wget) и выполните команду:'
echo 'wget git.io/alfipi.sh && sh alfipi.sh'
exit
