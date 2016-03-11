" Unite
let g:unite_data_directory = expand("~/.vim/tmp/unite")
let g:unite_source_history_yank_enable = 1
let g:unite_enable_start_insert = 1
" let maplocalleader="f"
nnoremap <Leader>e :Unite file<cr>
nnoremap <Leader>b :Unite buffer<cr>
" nnoremap <Leader>f :Unite -hide-status-line file<cr>
nnoremap <Leader>o :Unite outline<cr>
nnoremap <Leader>t :Unite outline<cr>
nnoremap <Leader>u :Unite file_mru<cr>
nnoremap <Leader>s :Unite session<cr>
nnoremap <Leader>l :Unite line/fast<cr>
nnoremap <Leader>y :Unite history/yank<cr>
nnoremap <Leader>j :Unite jump<cr>
nnoremap <Leader>c :Unite change<cr>
nnoremap <Leader>x :Unite command<cr>

nnoremap <Leader>fn :Unite file -input=Dropbox/Notes/<cr>
autocmd FileType unite call s:unite_custom_settings()

function! s:unite_custom_settings()
  " map <buffer> <esc> <Plug>(unix_exit)
  nnoremap <buffer> <esc> :q<cr>i<esc>
  imap <buffer> <C-j> <Plug>(unite_select_next_line)
  imap <buffer> <C-k> <Plug>(unite_select_previous_line)
endfunction

" Projects mappings<leader> handles my common finding inside Rails/Kohana/WP projects
nnoremap <Leader>fj :call FindInMyProject('javascripts', 'js')<cr>
nnoremap <Leader>fs :call FindInMyProject('stylesheets', 'sass', 'css')<cr>
nnoremap <Leader>fm :call FindInMyProject('models')<cr>
nnoremap <Leader>fc :call FindInMyProject('controllers')<cr>
nnoremap <Leader>fv :call FindInMyProject('views')<cr>
nnoremap <Leader>ft :call FindInMyProject('spec')<cr>

function! FindInMyProject(...)
  let l:path = a:0
  for pattern in a:000
    let paths = glob('**/'.pattern, 1)
    if !empty(paths)
      let l:path = split(paths, "\n")[0]
      break
    endif
  endfor

  execute 'Unite -input='.l:path.' file'
endfunction
