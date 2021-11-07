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
PS1='\[\033[01;32m\]\A\[\033[00m - \[\033[01;32m\]\u\[\033[00m\]\[\033[00m@\[\033[01;34m\]\h\[\033[01;31m\]$PWD\[\033[01;34m\]\[\033[00m $\n'
