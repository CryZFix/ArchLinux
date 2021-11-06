#
# ~/.bashrc
#

if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
exec startx
fi

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias postinstaller='wget git.io/alfipi.sh && sh alfipi.sh && rm alfipi.sh'
alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '
