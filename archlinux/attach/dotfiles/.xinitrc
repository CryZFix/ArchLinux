#!/bin/sh
# Xfce передаётся по умолчанию

if [ -f $HOME/.Xresources ]; then
    xrdb -merge $HOME/.Xresources
fi

exec i3
