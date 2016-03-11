
" Zen Coding
let g:user_zen_settings = {
      \ 'html': {
      \   'filters': 'html',
      \   'indentation': '  ',
      \   'default_attributes': {
      \     'meta:cs': {'charset': 'utf-8'},
      \     'form': {'method': 'POST'},
      \   }
      \ },
      \ 'css': {
      \   'filters': 'html,fc',
      \ },
      \ }

imap <c-]> <c-y>,
map <m-]> <c-y>n

