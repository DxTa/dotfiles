
function xtitle {
  unset PROMPT_COMMAND
  echo -ne "\033]0;$1\007"
}

function todop() {
  if [[ ! -e $TODO ]]; then return; fi

  todos=$(grep -e "^-" $TODO \
    | grep -ve "\(@someday\|@cancelled\|@done\)" | grep -c "")
  if [ $todos != 0 ]; then
    echo -e "[#:$todos]"
  fi
}

autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git hg svn
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' get-revision true
zstyle ':vcs_info:*' stagedstr $'%{$fg_bold[green]%}+'
zstyle ':vcs_info:*' unstagedstr $'%{$fg_bold[red]%}+'
zstyle ':vcs_info:*' formats $'%{$fg_bold[green]%}%u%c[%b:%7.7i]'

function git_prompt_info() {
    echo "${vcs_info_msg_0_}"
    # echo -ne $(git-prompt_status)
}

if [[ $CLICOLOR == 1 ]]; then
  export PROMPT=$'\n%{$fg[red]%}%n%{$reset_color%}@%{$fg[yellow]%}%m%{$reset_color%} in %{$fg[green]%}%~/%{$reset_color%}\n› '
  set_prompt () {
    export RPROMPT="$(git_prompt_info)%{$fg[cyan]%}$(todop)%{$reset_color%}"
  }
else
  export PROMPT=$'\n%n at %m in %~/\n› '
  set_prompt () {
    export RPROMPT="$(git-prompt_status)$(todop)"
  }
fi

precmd() {
  vcs_info
  set_prompt
}
