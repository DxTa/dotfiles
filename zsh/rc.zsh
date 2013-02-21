
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

autoload -U edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search
bindkey '^P' up-line-or-search
bindkey '^N' down-line-or-search
bindkey '^R' history-incremental-search-backward
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^F' forward-char
bindkey '^B' backward-char
bindkey '^K' kill-line
bindkey '^D' delete-char
bindkey 'ƒ' forward-word
bindkey '∫' backward-word
bindkey ' ' magic-space
bindkey '^/' undo
bindkey '^[[Z' reverse-menu-complete
bindkey '^W' backward-kill-word


# Mac OS X Proxy Icon in Terminal
if [ "$OS" = "darwin" ] && [ "$TERM_PROGRAM" = "Apple_Terminal" ]; then
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

