
# Local
if [ -d $HOME/cli/bin ]; then
  export PATH=$HOME/cli/bin:$PATH
fi
LOCAL=$HOME/local

# PHP Composer
# alias composer='php composer.phar'

# Homebrew
if [ -d $LOCAL/bin ]; then
  export PATH=$LOCAL/bin:$PATH
  export PATH=$LOCAL/sbin:$PATH
  export PATH=$LOCAL/share/python:$PATH
  export PATH=$LOCAL/share/npm/bin:$PATH
fi

# Python
if [ -d $HOME/.local/bin ]; then
  export PATH=$HOME/.local/bin:$PATH
fi

# Ruby
if [ -d $HOME/.rbenv ]; then
  export PATH=$HOME/.rbenv/bin:$PATH
  eval "$(rbenv init -)"
fi

# Node
[[ -s "$HOME/.nvm/nvm.sh" ]] && . "$HOME/.nvm/nvm.sh"
export NODE_PATH=$LOCAL/lib/node_modules:$NODE_PATH

# Clojure
if [ "$OS" = "linux" ]; then
  export JAVA_HOME='/usr/lib/jvm/java-6-sun'
  export PATH=$JAVA_HOME:$PATH
fi

if [ -d $LOCAL/jars ]; then
  for jar in $LOCAL/jars/*.jar; do export CLASSPATH="$jar:$CLASSPATH"; done
fi

if [ -d $LOCAL/clojurescript ]; then
  export CLOJURESCRIPT_HOME=$LOCAL/clojurescript
  export PATH=$CLOJURESCRIPT_HOME/bin:$PATH
fi

# Heroku
if [ -d "/usr/local/heroku" ]; then
  export PATH="/usr/local/heroku/bin:$PATH"
fi

# MAMP & Emacs
if [[ "$OS" = "darwin" ]]; then
  # export PATH=/Applications/MAMP/bin/php/php5.3.6/bin:$PATH
  export PATH=$HOME/Applications/Emacs.app/Contents/MacOS:$PATH
  export PATH=$HOME/Applications/Emacs.app/Contents/MacOS/bin:$PATH
fi

# Shortcut
export DEV=$HOME/Projects
function c() {
  cd $DEV/$1;
}

# Editor
if [ "$OS" = "linux" ]; then
  export EDITOR=vim
  export GIT_EDITOR=vim
  # Workaround for GVim iBus bug
  # gvim='gvim -f'
else
  export EDITOR='mvim -v'
  export GIT_EDITOR='mvim -v'
fi

# Vault
command -v vault >/dev/null 2>&1 && function pws() {
  vault "$1" -p | pbc
}

