
function xtitle {
  unset PROMPT_COMMAND
  echo -ne "\033]0;$1\007"
}

autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' get-revision true
zstyle ':vcs_info:*' stagedstr $'%{$fg_bold[green]%}+'
zstyle ':vcs_info:*' unstagedstr $'%{$fg_bold[red]%}+'
zstyle ':vcs_info:*' formats $'%{$fg_bold[green]%}%u%c[%b:%7.7i]%m%{$reset_color%}'

function vcs_prompt_info() {
  echo "${vcs_info_msg_0_}"
}

if [[ $CLICOLOR == 1 ]]; then
  export PROMPT=$'\n%{$fg[red]%}%n%{$reset_color%}@%{$fg[yellow]%}%m%{$reset_color%} in %{$fg[green]%}%~/%{$reset_color%}\n› '
  set_prompt () {
    export RPROMPT="$(vcs_prompt_info)"
  }
else
  export PROMPT=$'\n%n@%m in %~/\n› '
  set_prompt () {
    export RPROMPT="$(vcs_prompt_info)"
  }
fi

precmd() {
  vcs_info
  set_prompt
}
