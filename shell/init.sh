
# OS Identification
export OS=`uname -s | sed -e 's/  */-/g;y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/'`
export OSVERSION=`uname -r`; OSVERSION=`expr "$OSVERSION" : '[^0-9]*\([0-9]*\.[0-9]*\)'`
export MACHINE=`uname -m | sed -e 's/  */-/g;y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/'`
export PLATFORM="$MACHINE-$OS-$OSVERSION"


# Handy variable
export CLI=$HOME/cli
export TODO="$HOME/Dropbox/GTD/@Projects.taskpaper"


# Remote
if [[ -z $SSH_CONNECTION ]]; then
  export IS_REMOTE=false
else
  export IS_REMOTE=true
fi

# Better shell on vim and emacs
# if [[ $TERM == "dumb" ]]; then
  # export CLICOLOR=0
# else
  export CLICOLOR=1
  if [ "$OS" = "linux" ]; then
    alias ls='ls --color=auto'
    # export LS_COLORS='no=00:di=35:fi=00:ln=00:ex=31:tw=34:ow=34:or=04'
  else
    alias ls='ls -G'
  fi
# fi

export GREP_OPTIONS='--color=auto' GREP_COLOR='1;32'

[ -n "$TMUX" ] && export TERM=screen-256color

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
source $CLI/shell/alias.sh
source $CLI/shell/tools.sh
. $CLI/shell/n.sh
. $CLI/shell/z.sh

# Shell config and prompt
[ -n "$ZSH_VERSION" ] && for file in $CLI/zsh/*.zsh; do source $file; done
[ -n "$BASH_VERSION" ] && for file in $CLI/bash/*.bash; do source $file; done

