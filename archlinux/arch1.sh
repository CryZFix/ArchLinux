#!/bin/bash

fdisk -l
read -p 'Enter your disk name: /dev/' disk_name
if [ -z $disk_name ]
  then
    echo 'Your choice is empty'
    exit
  else
    echo 'Preparing the disk'
    disk_name="/dev/$disk_name"
fi

read -p 'Enter your choice, 1 - BIOS or 2 - UEFI (Default as BIOS): ' loader
read -p 'Enter your Username (Default junker): ' uservar && if [ -z $uservar ] ; then username=junker; else username=$uservar; fi
read -p 'Enter your Hostname (Default reichstag): ' hostvar && if [ -z $hostvar ] ; then hostname=reichstag; else hostname=$hostvar; fi
read -p 'Enter your TimeZone (Default Europe/Samara): ' timevar && if [ -z $timevar ] ; then timezone='Europe/Samara'; else timezone=$timevar; fi
read -sp 'Enter your Password (Default 123456): ' passvar && if [ -z $passvar ] ; then password=123456; else password=$passvar; fi
echo ""


#hostname=reichstag
#username=junker
#password=123456


##############################################
ESSENTIAL='base base-devel cmake linux-zen linux-zen-headers linux-firmware neovim dhcpcd netctl openssh dialog wpa_supplicant zsh'
##############################################
DRIVERS='xorg-server xorg-xinit xorg-xrandr xdotool ntfs-3g gvfs os-prober'
##############################################
APPS='bspwm sxhkd grub rofi alacritty dmenu pulseaudio pavucontrol wget tar networkmanager ppp git curl tree ranger'
##############################################
FONTS='ttf-liberation ttf-dejavu ttf-liberation ttf-dejavu'
##############################################
OPTS='bash-completion telegram-desktop tmux rsync feh ffmpegthumbnailer ueberzug zsh-theme-powerlevel10k pkgfile python-pip'
##############################################
AUR='google-chrome polybar networkmanager-dmenu-git'

timedatectl set-ntp true

if [[ $loader != 2 ]]; then
  echo 'Parts'
  (
    echo o;

    echo n;
    echo;
    echo;
    echo;
    echo +800M;
    echo a;

    echo n;
    echo;
    echo;
    echo;
    echo +2048M;

    echo n;
    echo;
    echo;
    echo;
    echo;

    echo w;
  ) | fdisk $disk_name

  #NVME add prefix for partition
  if [[ "$disk_name" == *"nvme"*  ]]
    then
    echo 'Adding a prefix for NVME'
    disk_name="$disk_name""p"
  else
    disk_name="$disk_name"
  fi

  # Formating
  mkfs.ext2 $disk_name"1" -L boot
  mkfs.ext4 $disk_name"3" -L root
  mkswap $disk_name"2" -L swap

  # Mounting
  mount $disk_name"3" /mnt
  mkdir /mnt/boot
  mount $disk_name"1" /mnt/boot
  swapon $disk_name"2"
elif [[ $loader == 2 ]]; then
  echo 'Parts'
  (
    echo g;

    echo n;
    echo;
    echo;
    echo +500M;
    echo t;
    echo 1;

    echo n;
    echo;
    echo;
    echo +4096M;
    echo t;
    echo 2;
    echo 19;

    echo n;
    echo;
    echo;
    echo;
    echo;

    echo w;
  ) | fdisk $disk_name

  #NVME add prefix for partition
  if [[ "$disk_name" == *"nvme"*  ]]
    then
    echo 'Adding a prefix for NVME'
    disk_name="$disk_name""p"
  else
    disk_name="$disk_name"
  fi

  #Formating
  mkfs.vfat -F32 $disk_name"1"
  mkfs.ext4 $disk_name"3" -L root
  mkswap $disk_name"2" -L swap

  #Mounting
  mount $disk_name"3" /mnt
  mkdir -p /mnt/boot/efi
  mount $disk_name"1" /mnt/boot/efi
  swapon $disk_name"2"
fi

# Necessary helper for sorting mirrors
curl -sSL 'https://www.archlinux.org/mirrorlist/?country=RU&protocol=https&ip_version=4' | sed 's/^#Server/Server/g' > /etc/pacman.d/mirrorlist
pacman -Sy
pacman -S --noconfirm pacman-contrib archlinux-keyring

update_mirrorlist(){
  curl -sSL 'https://www.archlinux.org/mirrorlist/?country=RU&protocol=https&ip_version=4&use_mirror_status=on' | sed 's/^#Server/Server/g' | rankmirrors - > /etc/pacman.d/mirrorlist
}
sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 5/g' /etc/pacman.conf
update_mirrorlist
pacman -Syy

# Install the base packages
pacstrap /mnt $ESSENTIAL $DRIVERS $APPS $FONTS $OPTS

# Generate fstab
genfstab -pU /mnt >> /mnt/etc/fstab


cat << REALEND > /mnt/arch2.sh
#!/bin/bash

# Hostname
echo $hostname > /etc/hostname

# Timezone
rm -f /etc/localtime
ln -svf /usr/share/zoneinfo/$timezone /etc/localtime

# Create regular user
useradd -m -g users -G wheel -s /bin/bash $username
echo "$username:$password" | chpasswd

# Locale
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Create RAM loader
echo 'Создадим загрузочный RAM диск'
if [[ loader == 2 ]]; then
  pacman -S efibootmgr
fi
mkinitcpio -p linux-zen

#NVME add prefix for partition
  if [[ "$disk_name" == *"nvme"*  ]]
    then
    disk_name=$($disk_name | sed 's/^.$//')
  else
    disk_name=$disk_name
  fi

grub-install $disk_name
grub-mkconfig -o /boot/grub/grub.cfg

# Config sudo
# allow users of group wheel to use sudo
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL$/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL$/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
chmod 777 /home/$username/arch3.sh

# Uncomment multilib repo
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 5/g' /etc/pacman.conf
pacman -Syy

# graphics driver
# nvidia=$(lspci | grep -e VGA -e 3D | grep 'NVIDIA' 2> /dev/null || echo '')
# amd=$(lspci | grep -e VGA -e 3D | grep 'AMD' 2> /dev/null || echo '')
# intel=$(lspci | grep -e VGA -e 3D | grep 'Intel' 2> /dev/null || echo '')
# if [[ -n "$nvidia" ]]; then
#   pacman -S --noconfirm nvidia
# fi

# if [[ -n "$amd" ]]; then
#   pacman -S --noconfirm xf86-video-amdgpu
# fi

# if [[ -n "$intel" ]]; then
#   pacman -S --noconfirm xf86-video-intel
# fi

# if [[ -n "$nvidia" && -n "$intel" ]]; then
#   pacman -S --noconfirm bumblebee
#   gpasswd -a $username bumblebee
#   systemctl enable bumblebeed
# fi

# Enabe NM and sshd service
systemctl enable NetworkManager
systemctl enable sshd

# Downloading config for i3, polybar, etc
 # tar -czf config.tar.gz .config
chsh -s /bin/zsh $username
mkdir downloads
cd downloads


cat << EOF > arch3.sh
#!/bin/bash

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

pikaur -Syu $AUR --noconfirm

git clone https://github.com/CryZFix/dotfiles.git
rsync -a --exclude='.git/' dotfiles/ /home/$username

cd ..
cd ..
cd ..
rm -rf files

EOF


rm /home/$username/.bashrc
sudo mv -f * /home/$username
sudo -u $username sh /home/$username/arch3.sh
rm /home/$username/arch3.sh
sudo systemctl enable zramswap.service
sed -i 's/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL$/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
wget https://github.com/CryZFix/Linux/raw/main/archlinux/attach/config.tar
sudo rm -rf /home/$username/.config/*
sudo tar -xf config.tar -C /home/$username
sudo chown $username:users /home/$username/.*

# Adding autologin without DE
sudo echo -e "[Service]\nExecStart=\nExecStart=-/sbin/agetty -o '-p -f -- \\u' --noclear --autologin" "$username" '- $TERM' > autologin.conf
sudo mkdir /etc/systemd/system/getty@tty1.service.d/
sudo mv -f autologin.conf /etc/systemd/system/getty@tty1.service.d/autologin.conf

pikaur -S 
git clone https://github.com/pijulius/picom.git
cd picom
meson --buildtype=release . build
ninja -C build
mkdir -p /home/$username/.local/bin
cp build/src/picom /home/$username/.local/bin

cd ..
rm -rf downloads
echo 'Install is complete, rebooting...'
exit
REALEND
arch-chroot /mnt sh arch2.sh
rm /mnt/arch2.sh
echo Finaly.
