
" SmartInput
" Ruby, CoffeeScript # -> #{}
call smartinput#map_to_trigger('i', '#', '#', '#')
call smartinput#define_rule({
      \   'at': '\%#',
      \   'char': '#',
      \   'input': '#{}<left>',
      \   'filetype': ['ruby', 'coffee'],
      \   'syntax': ['Constant', 'Special', 'String'],
      \ })

