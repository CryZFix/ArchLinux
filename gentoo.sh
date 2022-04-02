#!/bin/bash

loadkeys ru
setfont cyr-sun16

read -p "Введите дату и время в форамате MMDDhhmmYYYY: " datatime
date $datatime

cd /mnt/gentoo

links 'https://mirror.yandex.ru/gentoo-distfiles/releases/amd64/autobuilds/'

tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner

read -p "Введите колличество потоков вашего процессора(не ядер, именно потоков): " cputhreads
echo MAKEOPTS="$cputhreads" >> /mnt/gentoo/etc/portage/make.conf

cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys 
mount --make-rslave /mnt/gentoo/sys 
mount --rbind /dev /mnt/gentoo/dev 
mount --make-rslave /mnt/gentoo/dev