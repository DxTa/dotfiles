
" Unite
let g:unite_data_directory = expand("~/.vim/tmp/unite")
let g:unite_source_history_yank_enable = 1
let g:unite_enable_start_insert = 1
nnoremap <leader>e :Unite -hide-status-line file<cr>
nnoremap <leader>b :Unite -hide-status-line buffer<cr>
nnoremap <leader>f :Unite -hide-status-line file<cr>
nnoremap <leader>o :Unite -hide-status-line outline<cr>
nnoremap <leader>t :Unite -hide-status-line outline<cr>
nnoremap <leader>r :Unite -hide-status-line file_mru<cr>
nnoremap <leader>s :Unite -hide-status-line session<cr>
nnoremap <leader>l :Unite -hide-status-line line/fast<cr>
nnoremap <leader>y :Unite -hide-status-line history/yank<cr>
nnoremap <leader>j :Unite -hide-status-line jump<cr>
nnoremap <leader>c :Unite -hide-status-line change<cr>
nnoremap <leader>x :Unite -hide-status-line command<cr>

nnoremap <leader>fn :Unite file -input=Dropbox/Notes/<cr>
autocmd FileType unite call s:unite_custom_settings()

function! s:unite_custom_settings()
  map <buffer> <esc> <Plug>(unix_exit)
endfunction

" Projects mappings<leader> handles my common finding inside Rails/Kohana/WP projects
nnoremap <leader>fj :call FindInMyProject('javascripts', 'js')<cr>
nnoremap <leader>fs :call FindInMyProject('stylesheets', 'sass', 'css')<cr>
nnoremap <leader>fm :call FindInMyProject('models')<cr>
nnoremap <leader>fc :call FindInMyProject('controllers')<cr>
nnoremap <leader>fv :call FindInMyProject('views')<cr>
nnoremap <leader>ft :call FindInMyProject('spec')<cr>

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

