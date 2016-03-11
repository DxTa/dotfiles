
" Change to root projects dir of the first buffer
let g:is_first_opened_buffer=1
function! ChangeIfFirst()
  if g:is_first_opened_buffer == 0 || v:this_session != '' || expand("%") == ''
    return
  endif

  let scm_list = ['.git', '.hg']
  for scm in scm_list
    let scm_dir = finddir(scm, expand("%:p:h") . ";")
    if !(scm_dir == scm) && !empty(scm_dir)
      exec "cd" escape(substitute(scm_dir, scm . "$", "", ""), ' \')
      let g:is_first_opened_buffer=0
      return
    endif
  endfor

  exec "cd %:p:h"
  let g:is_first_opened_buffer=0
endfunction
autocmd BufEnter * call ChangeIfFirst()

