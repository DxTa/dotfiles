
function ef; vim ~/.config/fish/config.fish; end
function eff; vim ~/.config/fish/functions; end
function ev; vim ~/.vimrc; end
function ed; vim ~/.vim/custom-dictionary.utf-8.add; end
function eo; vim ~/Dropbox/Org; end
function eh; vim ~/.hgrc; end
function ep; vim ~/.pentadactylrc; end
function em; vim ~/.mutt/muttrc; end
function ez; vim ~/lib/dotfiles/zsh; end
function et; vim ~/.tmux.conf; end
function eg; vim ~/.gitconfig; end
function es; vim ~/.slate; end

function ..;    cd ..; end
function ...;   cd ../..; end
function ....;  cd ../../..; end
function .....; cd ../../../..; end


# Completions {{{

function make_completion --argument alias command
  complete -c $alias -xa "(
  set -l cmd (commandline -pc | sed -e 's/^ *\S\+ *//' );
  complete -C\"$command \$cmd\";
  )"
end

make_completion g "git"

# }}}
# Bind Keys {{{

# Backwards compatibility?  Screw that, it's more important that our function
# names have underscores so they look pretty.
function jesus_fucking_christ_bind_the_fucking_keys_fish
  bind \cn accept-autosuggestion
  bind \cw backward-kill-word
end

function fish_user_keybindings
  jesus_fucking_christ_bind_the_fucking_keys_fish
end
function fish_user_key_bindings
  jesus_fucking_christ_bind_the_fucking_keys_fish
end

set -g -x LC_ALL "en_US"
set -g -x NIX_LINK "$HOME/.nix-profile"


# Paths
function prepend_to_path -d "Prepend the given dir to PATH if it exists and is not already in it"
  if test -d $argv[1]
    if not contains $argv[1] $PATH
      set -gx PATH "$argv[1]" $PATH
    end
  end
end

set -gx PATH "/usr/X11R6/bin"
prepend_to_path "/usr/texbin"
prepend_to_path "/sbin"
prepend_to_path "/usr/sbin"
prepend_to_path "/bin"
prepend_to_path "/usr/bin"
prepend_to_path "/usr/local/bin"
prepend_to_path "$HOME/Projects/dotfiles/bin"
prepend_to_path "$HOME/Applications/Postgres.app/Contents/MacOS/bin"
prepend_to_path "$HOME/Applications/Emacs.app/Contents/MacOS/bin-x86_64-10_9"
prepend_to_path "$HOME/.rbenv/shims"
prepend_to_path "$HOME/.local/bin"

set BROWSER open

set -g -x fish_greeting ''
set -g -x EDITOR vim
set -g -x COMMAND_MODE unix2003
set -g -x RUBYOPT rubygems
set -g -x CLASSPATH "$CLASSPATH:/usr/local/Cellar/clojure-contrib/1.2.0/clojure-contrib.jar"

set -g -x NODE_PATH "/usr/local/lib/node_modules"

set -g -x VIM_BINARY "/usr/local/bin/vim"
set -g -x MVIM_BINARY "/usr/local/bin/mvim"

set -g -x DRIP_SHUTDOWN 30

set -g -x MAVEN_OPTS "-Xmx512M -XX:MaxPermSize=512M"
set -g -x _JAVA_OPTIONS "-Djava.awt.headless=true"

set -g -x GPG_TTY (tty)

function headed_java -d "Put Java into headed mode"
  echo "Changing _JAVA_OPTIONS"
  echo "from: $_JAVA_OPTIONS"
  set -g -e _JAVA_OPTIONS
  echo "  to: $_JAVA_OPTIONS"
end
function headless_java -d "Put Java into headless mode"
  echo "Changing _JAVA_OPTIONS"
  echo "from: $_JAVA_OPTIONS"
  set -g -x _JAVA_OPTIONS "-Djava.awt.headless=true"
  echo "  to: $_JAVA_OPTIONS"
end



# }}}
# Python variables {{{

set -g -x PIP_DOWNLOAD_CACHE "$HOME/.pip/cache"
# set -g -x WORKON_HOME "$HOME/lib/virtualenvs"

# prepend_to_path "/usr/local/share/python"
# prepend_to_path "/usr/local/Cellar/PyPi/3.6/bin"
# prepend_to_path "/usr/local/Cellar/python/2.7.1/bin"
# prepend_to_path "/usr/local/Cellar/python/2.7/bin"
# prepend_to_path "/usr/local/Cellar/python/2.6.5/bin"

# set -g -x PYTHONPATH ""
# set PYTHONPATH "$PYTHONPATH:/usr/local/lib/python2.7.1/site-packages"
# set PYTHONPATH "$PYTHONPATH:/usr/local/lib/python2.7/site-packages"
# set PYTHONPATH "$PYTHONPATH:/usr/local/lib/python2.6/site-packages"
# set PYTHONPATH "$HOME/lib/python/see:$PYTHONPATH"
# set PYTHONPATH "$HOME/lib/hg/hg:$PYTHONPATH"

# set -gx WORKON_HOME "$HOME/lib/virtualenvs"
# . ~/.config/fish/virtualenv.fish

# }}}
# Z {{{

# . ~/src/z-fish/z.fish

# }}}

if test -f $HOME/.local.fish
  . $HOME/.local.fish
end

true
