#
# ~/.bashrc
#

if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
exec startx
fi

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

bind "set completion-ignore-case on"

alias postinstaller='wget git.io/alfipi.sh && sh alfipi.sh && rm alfipi.sh'
alias ls='ls --color=auto'
PS1='\[\033[01;32m\]\A\[\033[00m - \[\033[01;32m\]\u\[\033[00m\]\[\033[00m@\[\033[01;34m\]\h\[\033[01;31m\]$PWD\[\033[01;34m\]\[\033[00m $\n'

#shopt
shopt -s autocd # change to named directory
shopt -s cdspell # autocorrects cd misspellings
shopt -s cmdhist # save multi-line commands in history as single line
shopt -s dotglob
shopt -s histappend # do not overwrite history
shopt -s expand_aliases # expand aliases