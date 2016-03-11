
NOTE_DIR=$HOME/Dropbox/Notes

n() {
  count=$(ls -c $NOTE_DIR | grep -i "$*" -c)
  if [[ $count == 0 ]]; then
    $EDITOR $NOTE_DIR/"$*".md
  elif [[ $count == 1 ]]; then
    $EDITOR "$NOTE_DIR/$(ls -c $NOTE_DIR | grep -i "$*")"
  else
    ls -c $NOTE_DIR | grep -i "$*"
  fi
}

nls() {
  ls -c $NOTE_DIR | grep -i "$*"
}

