
# Local
if [ -d $HOME/cli/bin ]; then
  export PATH=$HOME/cli/bin:$PATH
fi

LOCAL=$HOME/.local
if [ -d $LOCAL/bin ]; then
  export PATH=$LOCAL/bin:$PATH
fi

# Platform specifics
if [ "$OS" = "linux" ]; then
  alias open='xdg-open'
  alias pbp='xsel -b'
  alias pbc='xsel -b -i'
  alias mvim=vim
fi

if [ "$OS" = "darwin" ]; then
  alias updatedb=/usr/libexec/locate.updatedb
  alias pbp=pbpaste
  alias pbc=pbcopy
  alias vim='mvim -v'
  alias vim='emacsclient -a ""'
  alias emacs='Emacs'
fi

# Editor
if [ "$OS" = "linux" ]; then
  export EDITOR=vim
  # Workaround for GVim iBus bug
  # gvim='gvim -f'
else
  export EDITOR='mvim -v'
fi

# Homebrew
if [ -e $LOCAL/bin/brew ]; then
  export PATH=$LOCAL/bin:$PATH
  export PATH=$LOCAL/sbin:$PATH
  export PATH=$LOCAL/share/npm/bin:$PATH
  export PATH=$LOCAL/share/pypy:$PATH

  export RBENV_ROOT=$LOCAL/var/rbenv
  export ANDROID_SDK_ROOT=$LOCAL/opt/android-sdk
  export ANDROID_HOME=$ANDROID_SDK_ROOT
fi

# Ruby
export GEM_HOME=$LOCAL

if [ -d $HOME/.rbenv ]; then
  export PATH=$HOME/.rbenv/bin:$PATH
fi
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# Node
[[ -s "$HOME/.nvm/nvm.sh" ]] && . "$HOME/.nvm/nvm.sh"
export NODE_PATH=$LOCAL/lib/node_modules:$NODE_PATH
export PATH=$PATH:$HOME/.npm/bin

# Clojure
if [ -d $LOCAL/clojurescript ]; then
  export CLOJURESCRIPT_HOME=$LOCAL/clojurescript
  export PATH=$CLOJURESCRIPT_HOME/bin:$PATH
fi

# Go
if [ -d $HOME/Projects/go ]; then
  export GOPATH=$HOME/Projects/go
  export PATH=$GOPATH/bin:$PATH
fi

# Heroku
if [ -d "/usr/local/heroku" ]; then
  export PATH="/usr/local/heroku/bin:$PATH"
fi

# Android SDK
if [ -d $LOCAL/adt ]; then
  export PATH=$LOCAL/adt/sdk/tools:$PATH
  export PATH=$LOCAL/adt/sdk/platform-tools:$PATH
fi

# Emacs
if [ -d $HOME/.cask ]; then
  export PATH=$HOME/.cask/bin:$PATH
fi

if [[ "$OS" = "darwin" ]]; then
  export PATH=$HOME/Applications/Emacs.app/Contents/MacOS:$PATH
  export PATH=$HOME/Applications/Emacs.app/Contents/MacOS/bin:$PATH
  export PATH=/Applications/Emacs.app/Contents/MacOS:$PATH
  export PATH=/Applications/Emacs.app/Contents/MacOS/bin:$PATH
  export JAVA_HOME=$(/usr/libexec/java_home)
fi

# WP-cli
if [ -d $HOME/.wp-cli ]; then
  export PATH=$HOME/.wp-cli/bin:$PATH
fi

# Docker
export DOCKER_HOST=tcp://192.168.132.128:4243

# Shortcut
export DEV=$HOME/Projects
function c() {
  cd $DEV/$1;
}

# Vault
# Config vault first: vault -c -p
command -v vault >/dev/null 2>&1 && function pws() {
  vault "$1" | pbc
}

# ls
alias pu='pushd'
alias po='popd'
alias dir="ls --format=long"
alias l="ls -hl"
alias la="ls -hlA"

# safe
alias cp="cp -pv"
alias mv="mv -v"
alias rm="rm -i"

# cd
alias ..="cd .."
alias ...="cd ../../"
alias ....="cd ../../../"
alias .....="cd ../../../"
alias ......="cd ../../../../"

md() {
  mkdir -p "$1" && cd "$1";
}

# git
alias g=git
alias gst='git st'
alias gdf='git diff'
alias gdc='git diff --cached'
alias gci='git commit'

# grep
alias grep="grep --color"

# Ruby & Rails
alias r=rails
alias be='bundle exec'
alias bi='bundle install'
alias rk=rake

fr() {
  if [ -e "Procfile.local" ]; then
    echo "::DEVELOPMENT::"
    nf start --wrap --procfile Procfile.local
  elif [ -e "Procfile" ]; then
    echo "::PRODUCTION::"
    nf start --wrap
  fi
}

# Node
alias gl=gulp
alias km='karma start karma.conf.js'

# Vim
alias v=vim

# Emacs
alias e="emacsclient"
es() {
  emacsclient -c -a "" "/sudo::$*"
}

# Mics.
alias mk=make
alias gr=gradle

alias h=history
alias tm="tmux -2"
alias ducks="du -cksh * | sort -rn | head -11"
alias t='grep -e "^-" $TODO | grep -ve "\(@someday\|@cancelled\|@done\)"'
alias pp='pygmentize -O style=monokai -f console256 -g'
alias cleanup="find . -name '*.DS_Store' -type f -ls -delete"
alias remoteip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en1"
alias ips="ifconfig -a | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print $1'"
alias whois="whois -h whois-servers.net"
alias sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"
alias httpdump="sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""

f() {
  find . -name "$1"
}

extract() {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2) tar xjf $1 ;;
      *.tar.gz) tar xzf $1 ;;
      *.bz2) bunzip2 $1 ;;
      *.rar) rar x $1 ;;
      *.gz) gunzip $1 ;;
      *.tar) tar xf $1 ;;
      *.tbz2) tar xjf $1 ;;
      *.tgz) tar xzf $1 ;;
      *.zip) unzip $1 ;;
      *.Z) uncompress $1 ;;
      *.7z) 7z x $1 ;;
      *) echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

man() {
  env LESS_TERMCAP_mb=$'\E[01;31m' \
    LESS_TERMCAP_md=$'\E[01;38;5;74m' \
    LESS_TERMCAP_me=$'\E[0m' \
    LESS_TERMCAP_se=$'\E[0m' \
    LESS_TERMCAP_so=$'\E[38;5;246m' \
    LESS_TERMCAP_ue=$'\E[0m' \
    LESS_TERMCAP_us=$'\E[04;38;5;146m' \
    man "$@"
}
