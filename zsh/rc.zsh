
# OS Identification
export OS=`uname -s | sed -e 's/  */-/g;y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/'`
export OSVERSION=`uname -r`; OSVERSION=`expr "$OSVERSION" : '[^0-9]*\([0-9]*\.[0-9]*\)'`
export MACHINE=`uname -m | sed -e 's/  */-/g;y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/'`
export PLATFORM="$MACHINE-$OS-$OSVERSION"

export LANG="en_US.UTF-8"

if [ "$OS" = "darwin" ]; then
  launchctl setenv LANG $LANG
  launchctl setenv LC_CTYPE $LC_CTYPE
  launchctl setenv PATH $PATH
fi


# TERM
[ "$OS" = "linux" ] && export TERM=xterm-256color
[ -n "$TMUX" ] && export TERM=screen-256color

# Handy variable
export CLI=$HOME/Projects/dotfiles
export TODO="$HOME/Dropbox/GTD/@Projects.taskpaper"


# Remote
if [[ -z $SSH_CONNECTION ]]; then
  export IS_REMOTE=false
else
  export IS_REMOTE=true
fi

export CLICOLOR=1
if [ "$OS" = "linux" ]; then
  alias ls='ls --color=auto'
  # export LS_COLORS='no=00:di=35:fi=00:ln=00:ex=31:tw=34:ow=34:or=04'
else
  alias ls='ls -G'
fi

export GREP_OPTIONS='--color=auto' GREP_COLOR='1;32'

# Stop C-S to freeze the terminal
stty -ixon

# Navigation
export CDPATH=.:$HOME:$HOME/Dropbox

# This is gem
export WORDCHARS='*?[]~&;!$%^<>'

# use .localrc for SUPER SECRET CRAP that you don't
# want in your public, versioned repo.
if [[ -a ~/.localrc ]]; then
    source ~/.localrc
fi

# Utilities
source $CLI/shell/tools.sh
. $CLI/shell/n.sh
. $CLI/shell/z.sh

# Shell config and prompt
source $CLI/zsh/prompt.zsh


autoload colors; colors;
autoload -U url-quote-magic
zle -N self-insert url-quote-magic


# History
HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS

hf() {
  grep "$@ $HOME/.zsh_history"
}


# Input
zle -N newtab

zmodload -i zsh/complist
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path ~/.zsh/cache/

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' insert-tab pending

zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u `whoami` -o pid,user,comm -w -w"

bindkey -e
bindkey '^W' backward-kill-word
bindkey '\M\b' backward-kill-word

autoload -U edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line


# Mac OS X Proxy Icon in Terminal
if [ "$TERM_PROGRAM" = "Apple_Terminal" ] || [ "$TERM_PROGRAM" = "iTerm.app" ]; then
  update_terminal_cwd () {
    local SEARCH=' '
    local REPLACE='%20'
    local PWD_URL="file://$HOST${PWD//$SEARCH/$REPLACE}"
    printf '\e]7;%s\a' "$PWD_URL"
  }
  autoload add-zsh-hook
  add-zsh-hook chpwd update_terminal_cwd
  update_terminal_cwd
fi


# Emacs
[[ $EMACS = t ]] && unsetopt zle


# Options
setopt NONOMATCH
setopt NO_BG_NICE
setopt NO_HUP
setopt NO_LIST_BEEP
setopt LOCAL_OPTIONS
setopt LOCAL_TRAPS
setopt PROMPT_SUBST
setopt CORRECT
setopt COMPLETE_IN_WORD
setopt LONG_LIST_JOBS
setopt AUTO_CD
setopt MULTIOS

fpath=($HOME/cli/zsh/functions $fpath)
autoload -U compinit; compinit;

compdef '_git' g

alias reloadrc="source $HOME/.zshrc"
