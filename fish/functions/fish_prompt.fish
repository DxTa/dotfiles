set normal (set_color normal)
set red (set_color red)
set green (set_color green)
set gray (set_color -o black)

set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate 'yes'
set __fish_git_prompt_showuntrackedfiles 'yes'
set __fish_git_prompt_showcolorhints 'yes'

set __fish_git_prompt_char_cleanstate ''
set __fish_git_prompt_char_dirtystate '*'
set __fish_git_prompt_char_stagedstate '+'
set __fish_git_prompt_char_untrackedfiles '?'
set __fish_git_prompt_char_stashstate '#'
set __fish_git_prompt_char_invalidstate '!'


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
  printf '%s' (prompt_pwd)
  set_color normal

  # if test -n (__fish_git_prompt_dirty)
  #   set __fish_git_prompt_color_prefix red
  # end
  printf '%s' (__fish_git_prompt ' on [%s]')
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
