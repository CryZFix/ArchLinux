#!/bin/sh
# start some nice programs
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

# Window Manager of your choice
# exec gnome-session
exec i3
# exec startxfce4
# exec awesome
# exec openbox-session
