#!/bin/bash

read -p "Введите дату и время в форамате MMDDhhmmYYYY: " datatime
date $datatime

cd /mnt/gentoo

links 'https://mirror.yandex.ru/gentoo-distfiles/releases/amd64/autobuilds/'

tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner

cp --dereference /etc/resolv.conf /mnt/gentoo/etc/