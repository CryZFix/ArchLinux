#
# ~/.bashrc
#

if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
exec startx
fi

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alies postinstaller='sh -c "$(curl -fsSL git.io/alfipi.sh)"'
alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '
