
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


" Tabularize
nmap <leader>a= :Tabularize /^[^=]*\zs/<cr>
vmap <leader>a= :Tabularize /^[^=]*\zs/<cr>
nmap <leader>a, :Tabularize first_comma<cr>
vmap <leader>a, :Tabularize first_comma<cr>
nmap <leader>a: :Tabularize /:<cr>
vmap <leader>a: :Tabularize /:<cr>
nmap <leader>a\ :Tabularize /\|<cr>
vmap <leader>a\ :Tabularize /\|<cr>
vmap <leader>A :Tabularize /

" Ack
nmap <leader>A :Ack<space>

" Fugitive
nnoremap <leader>gs :Gstatus<cr>
nnoremap <leader>gc :Gcommit<cr>
nnoremap <leader>ga :Gwrite<cr>
nnoremap <leader>gd :Gdiff<cr>
nnoremap <leader>gg :Ggrep<space>
nnoremap <leader>G :Git<space>

" NERDCommenter
let g:NERDSpaceDelims=1
let g:NERD_c_alt_style=1
nmap <silent> <leader>m <leader>c<space>
vmap <silent> <leader>m <leader>c<space>
vmap <silent> <leader>M <leader>cm

" NERDTree
let g:NERDTreeWinSize=35
let g:NERDTreeHijackNetrw=1
let g:NERDTreeMinimalUI=1
let g:NERDTreeShowBookmarks=0
let g:NERDTreeStatusLine=1
noremap <silent> <f1> :NERDTreeToggle<cr>

" SplitJoin
function! s:join(cmd)
  if exists(':SplitjoinJoin') && !v:count
    let tick = b:changedtick
    SplitjoinJoin
    if tick == b:changedtick
      execute 'normal! '.a:cmd
    endif
  else
    execute 'normal! '.v:count.a:cmd
  endif
endfunction

nnoremap <silent> gJ :<C-U>call <SID>join('gJ')<CR>
nnoremap <silent>  J :<C-U>call <SID>join('J')<CR>
nnoremap <silent> gS :SplitjoinSplit<CR>
nnoremap <silent>  S :SplitjoinSplit<CR>

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

" Zen Coding
let g:user_zen_settings = {
      \ 'html': {
      \   'filters': 'html',
      \   'indentation': '  ',
      \   'default_attributes': {
      \     'meta:cs': {'charset': 'utf-8'},
      \   }
      \ },
      \ 'css': {
      \   'filters': 'html,fc',
      \ },
      \ }

imap <c-]> <c-y>,
map <m-]> <c-y>n

