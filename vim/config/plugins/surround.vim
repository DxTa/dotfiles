
" Surround
vmap ( S)
vmap [ S]
vmap { S}

augroup Surround
  au!
  autocmd FileType ruby let g:surround_45 = "<% \r %>"
  autocmd FileType ruby let g:surround_61 = "<%= \r %>"
  autocmd FileType php let g:surround_45 = "<?php \r ?>"
  autocmd FileType php let g:surround_61 = "<?php echo \r ?>"
  autocmd FileType html let g:surround_45 = "{% \r %}"
  autocmd FileType html let g:surround_61 = "{{ \r }}"
augroup END

imap <c-s> <Plug>Isurround
imap <m-s> <Plug>ISurround

