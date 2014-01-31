
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
  alias vim='emacsclient -a vim'
  alias emacs='Emacs'
fi


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
alias bd=". bd -s"
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

# Rails
alias r=rails
alias be='bundle exec'
alias bi='bundle install'
function fr() {
  if [ -e "Procfile.local" ]; then
    echo "::DEVELOPMENT::"
    nf start --wrap --procfile Procfile.local
  elif [ -e "Procfile" ]; then
    echo "::PRODUCTION::"
    nf start --wrap
  fi
}

# Vim
alias v=vim

# Emacs
alias e="emacsclient"
es() {
  emacsclient -c -a "" "/sudo::$*"
}

# Mics.
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

alias grd=gradle
alias grt=grunt
alias mk=make
alias rk=rake

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
