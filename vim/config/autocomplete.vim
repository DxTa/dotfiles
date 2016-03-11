
set pumheight=15
set completeopt=menu
set showfulltag
set complete=.,b,u,d,t
set previewheight=4


autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType ruby,eruby setlocal omnifunc=rubycomplete#Complete
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType php setlocal omnifunc=phpcomplete#CompletePHP
autocmd FileType go setlocal omnifunc=go#complete#Complete


function! InsertTabWrapper()
  if pumvisible()
    return "\<c-n>"
  endif
  let col = col('.') - 1
  if !col || getline('.')[col - 1] !~ '\k'
    return "\<tab>"
  else
    return "\<c-n>"
  endif
endfunction
inoremap <expr><tab> InsertTabWrapper()
inoremap <expr><s-tab> pumvisible()?"\<c-p>":"\<c-d>"

inoremap <silent> <c-f> <c-x><c-f>
inoremap <silent> <c-o> <c-x><c-o>
inoremap <silent> <c-l> <c-x><c-l>
" inoremap <silent> <c-u> <c-x><c-u>
