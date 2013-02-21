
# Colors
export CLICOLOR=1
export NC='\033[0m'
export WHITE='\033[1;37m'
export BLACK='\033[0;30m'
export BLUE='\033[0;34m'
export LIGHT_BLUE='\033[1;34m'
export GREEN='\033[0;32m'
export LIGHT_GREEN='\033[1;32m'
export CYAN='\033[0;36m'
export LIGHT_CYAN='\033[1;36m'
export RED='\033[0;31m'
export LIGHT_RED='\033[1;31m'
export PURPLE='\033[0;35m'
export LIGHT_PURPLE='\033[1;35m'
export YELLOW='\033[0;33m'
export LIGHT_YELLOW='\033[1;33m'
export GRAY='\033[1;30m'
export LIGHT_GRAY='\033[0;37m'
export END='\033[m'
export BOLD='\033[1m'


# History
export HISTCONTROL=ignoredups
export HISTFILESIZE=3000
export HISTIGNORE="ls:cd:[bf]g:exit:..:...:ll:lla"
alias h=history
hf() {
  grep "$@ $HOME/.bash_history"
}


# Input
bind "set show-all-if-ambiguous on"
bind "set completion-ignore-case on"
bind '"\e[A"':history-search-backward
bind '"\e[B"':history-search-forward
bind '"\C-g"':unix-filename-rubout
bind '"\e,"':menu-complete


# Options
shopt -s dotglob
shopt -s extglob
shopt -s nocaseglob
shopt -s cmdhist
shopt -s histappend
shopt -s expand_aliases
shopt -s checkwinsize
shopt -s cdspell
shopt -s no_empty_cmd_completion


if [ -f $HOME/local/etc/bash_completion ]; then
  . $HOME/local/etc/bash_completion
fi

if [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi

alias profileme="h | awk '{print \$2}' | awk 'BEGIN{FS=\"|\"}{print \$1}' | sort | uniq -c | sort -n | tail -n 20 | sort -nr"
alias reloadrc="source $HOME/.bashrc"

