
inoremap # X<BS>#
inoremap <m-a> @
inoremap <m-h> <space>=><space>

nnoremap ,. '.

noremap H ^
noremap L g_
nnoremap D dg_
nnoremap Y yg_

noremap gp :set paste<cr>"+p:set nopaste<cr>
noremap gP :set paste<cr>"+P:set nopaste<cr>
vnoremap Y "+y

nnoremap <c-s> gUiwe

nnoremap <leader>s :%s//<left>
nnoremap <leader>g :g//#<left><left>

nnoremap Q :bw<cr>

nnoremap j gj
nnoremap k gk
nnoremap <c-j> 10gj
nnoremap <c-k> 10gk

inoremap <m-u> <esc>mzgUiw`za

set pastetoggle=<f6>

nnoremap <silent> <leader>? :execute 'vimgrep /'.@/.'/g %'<cr>:copen<cr>

nnoremap gF :edit <cfile><cr>

vnoremap > >gv
vnoremap < <gv

map <tab> %

nnoremap <leader>s :setlocal spell!<cr>

nnoremap <c-tab> :bn<cr>
nnoremap <c-s-tab> :b#<cr>
inoremap <c-a> <home>
inoremap <c-e> <end>
nnoremap <leader>b :buffers<cr>:b

cnoremap <c-a> <home>
cnoremap <c-e> <end>
cnoremap <c-f> <right>
cnoremap <c-b> <left>
cnoremap <c-d> <del>
cnoremap cdf cd %:p:h
cnoremap %% <c-r>=expand('%:p:h').'/'<cr>

" nmap <leader>e :edit %%
nnoremap <leader>k :close<cr>
nnoremap <leader>K :bd<cr>

" nnoremap <silent> <leader>x :execute getline(".")<cr>
vnoremap <silent> <leader>x y:execute @@<cr>
vnoremap <leader> X di<c-r>=@@<cr>

nnoremap vv `[V`]

inoremap <m-v> :execute 'set keymap='.(&keymap == '' ? 'vietnamese-telex' : '')<cr>:echo &keymap<cr>

nnoremap <leader>vv :vsplit $MYVIMRC<cr>
nnoremap <leader>vs :source $MYVIMRC<cr>

nnoremap <leader>1 :close<cr>
