
# Local
if [ -d $HOME/cli/bin ]; then
  export PATH=$HOME/cli/bin:$PATH
fi
LOCAL=$HOME/local

# Homebrew
if [ -d $LOCAL/bin ]; then
  export PATH=$LOCAL/bin:$PATH
  export PATH=$LOCAL/sbin:$PATH
  export PATH=$LOCAL/share/npm/bin:$PATH
  export PATH=$LOCAL/share/pypy:$PATH

  export RBENV_ROOT=$LOCAL/var/rbenv
  export ANDROID_SDK_ROOT=$LOCAL/opt/android-sdk
  export ANDROID_HOME=$ANDROID_SDK_ROOT
fi

# Java
if [ -e "/usr/libexec/java_home" ]; then
  export JAVA_HOME=$(/usr/libexec/java_home -v 1.7)
fi

# Ruby
if [ -d $HOME/.rbenv ]; then
  export PATH=$HOME/.rbenv/bin:$PATH
fi
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

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

# Go
if [ -d $HOME/build/go-learning ]; then
  export GOPATH=$HOME/build/go-learning
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
if [[ "$OS" = "darwin" ]]; then
  export PATH=$HOME/Applications/Emacs.app/Contents/MacOS:$PATH
  export PATH=$HOME/Applications/Emacs.app/Contents/MacOS/bin:$PATH
fi

# WP-cli
if [ -d $HOME/.wp-cli ]; then
  export PATH=$HOME/.wp-cli/bin:$PATH
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
# Config vault first: vault -c -p
command -v vault >/dev/null 2>&1 && function pws() {
  vault "$1" | pbc
}
