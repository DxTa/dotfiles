
" CtrlP
let g:ctrlp_map=',e'
let g:ctrlp_dont_split='NERD_tree_2'
let g:ctrlp_max_depth=6
let g:ctrlp_working_path_mode='ra'
let g:ctrlp_match_window_reversed=0
let g:ctrlp_mruf_exclude = '.git/*\|vendor/*'

let g:ctrlp_extensions = ['quickfix', 'buffertag', 'tag', 'undo', 'changes']

let g:ctrlp_user_command = {
      \ 'types': {
      \   1: ['.git', 'cd %s && git ls-files'],
      \   2: ['.hg', 'hg --cwd %s locate -I .'],
      \ },
      \ 'fallback': "find %s '(' -type f -or -type l ')' -maxdepth 10 -not -path '*/\\.*/*'",
      \ 'ignore': 1
      \ }

nnoremap <leader>t :CtrlPBufTagAll<cr>
nnoremap <leader>b :CtrlPBuffer<cr>
" nnoremap <leader>e :CtrlP<cr>
nnoremap <leader>fq :CtrlPQuickfix<cr>
nnoremap <leader>r :CtrlPMRU<cr>

nnoremap <leader>fn :CtrlP $HOME/Dropbox/Notes/<cr>

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

  execute 'CtrlP '.l:path
endfunction

