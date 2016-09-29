let g:jsx_ext_required = 0 " Allow JSX in normal JS files
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_loc_list_height = 2
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_cursor_column = 0
let g:syntastic_check_on_wq = 1
let g:syntastic_auto_jump = 0
let g:syntastic_enable_balloons = 0

let g:syntastic_javascript_checkers = ['eslint']

" autocmd FileType javascript let b:syntastic_checkers = findfile('.eslintrc', '.;') !=# '' ? ['eslint'] : []

let local_eslint = finddir('node_modules', '.;') . '/.bin/eslint'
if matchstr(local_eslint, "^\/\\w") == ''
  let local_eslint = getcwd() . "/" . local_eslint
endif
if executable(local_eslint)
  let g:syntastic_javascript_eslint_exec = local_eslint
endif
