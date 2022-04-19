#!/bin/bash

##############################################
ESSENTIAL='base base-devel linux linux-firmware nano dhcpcd netctl openssh dialog wpa_supplicant'
##############################################
DRIVERS='xorg-server xorg-drivers xorg-xinit'
##############################################
APPS='i3-gaps xterm rofi dmenu pulseaudio pavucontrol wget tar bash-completion networkmanager ppp git curl'
##############################################
FONTS='ttf-liberation ttf-dejavu ttf-liberation ttf-dejavu ttf-symbola ttf-clear-sans'

sudo pacman -Sy $ESSENTIAL $DRIVERS $APPS $FONTS --noconfirm


# https://aur.archlinux.org/zramswap.git
# https://aur.archlinux.org/polybar.git
# https://aur.archlinux.org/networkmanager-dmenu-git.git