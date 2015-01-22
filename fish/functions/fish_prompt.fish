set normal (set_color normal)
set red (set_color red)
set green (set_color green)
set gray (set_color -o black)

function fish_prompt
  set last_status $status

  z --add "$PWD"

  echo

  set_color red
  printf '%s' (whoami)
  set_color normal
  printf '@'

  set_color yellow
  printf '%s' (hostname|cut -d . -f 1)
  set_color normal
  printf ' in '

  set_color $fish_color_cwd
  printf '%s' "$PWD"
  set_color normal

  printf ' on %s' (git-prompt_status)
  
  echo

  if test $last_status -eq 0
    set_color white -o
    printf '› '
  else
    set_color red -o
    printf '[%d]› ' $last_status
  end

  set_color normal
end
