
# Platform specifics
if [ "$OS" = "linux" ]; then
  alias open='xdg-open'
  alias pbp='xclip -selection clipboard -o'
  alias pbc='xclip -selection clipboard'
  alias mvim='vim'
  alias install='sudo pacman -S'
fi

if [ "$OS" = "darwin" ]; then
  alias updatedb=/usr/libexec/locate.updatedb
  alias pbp=pbpaste
  alias pbc=pbcopy
fi

# ls
alias pu='pushd'
alias po='popd'
alias dir="ls --format=long"
alias l="ls -hl"
alias la="ls -hlA"


# verbose
alias cp="cp -pv"
alias rm="rm -v"
alias mv="mv -v"

# safe
alias rm="rm -i"

# cd
alias ..="cd .."
alias ...="cd ../../"
md() {
  mkdir -p "$1" && cd "$1";
}


# git
alias g=git
alias gst='git st'
alias gdf='git diff'
alias gdc='git diff --cached'
alias gci='git commit'


# rails
alias r=rails
alias be='bundle exec'
alias bi='bundle install'


# grep
alias grep="grep --color"

# Emacs
alias e="emacsclient -c -a vim"
alias ec="emacsclient -c -a vim"
es() {
  emacsclient -c -a vim "/sudo::$*"
}

# e() {
  # if ([ -e "$1" ] && ! [ -w "$1" ]) || ( ! [ -e "$1" ] && ! [ -w "dirname $1" ]); then
    # emacsclient -a vim "/sudo::$*"
  # else
    # emacsclient -a vim $*
  # fi
# }
alias vim=e

# Mics.
alias h=history
alias tm="tmux -2"
alias ducks="du -cksh * | sort -rn | head -11"
alias t='grep -e "^-" $TODO | grep -ve "\(@someday\|@cancelled\|@done\)"'

# From Paul Irish
alias pp='pygmentize -O style=monokai -f console256 -g'
alias cleanup="find . -name '*.DS_Store' -type f -ls -delete"
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en1"
alias ips="ifconfig -a | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print $1'"
alias whois="whois -h whois-servers.net"
alias sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"
alias httpdump="sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""

pws() {
  vault "$1" -p | pbc
}

v() {
  if [ $# == 0 ]; then
    mvim
  else
    mvim --servername $(basename $(pwd)) --remote "$@" 1>/dev/null 2>&1
  fi
}

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
