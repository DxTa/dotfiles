
set modelines=0
set noerrorbells
set autoread autowrite
set hidden
set mouse=a
set shortmess=aTI
" let mapleader=","
set diffopt=filler,iwhite
set tags=./tags;/

filetype plugin indent on
syntax enable

set encoding=utf-8
set formatoptions=tcrqn
set backspace=indent,eol,start
set nostartofline

set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set smarttab
set shiftround

set autoindent
set nosmartindent

set noswapfile
set nobackup
set backupdir=$HOME/.vim/tmp/backup//
set directory=$HOME/.vim/tmp/swap//

set undofile
set undodir=$HOME/.vim/tmp/undo//

" set nolist
set listchars=trail:∙,tab:▸∙,eol:¬,extends:❯,precedes:❮
nnoremap <leader>i :setlocal list!<cr>

set wildmenu
set wildmode=full
set wildignore+=*.o,*.elc,*.pyc,*.class,*~,.git,.svn,.hg,.bzr
set wildignore+=*.jpg,*.png,*.bmp,*.gif,*.out,*.zip,*.rar,*.tar.gz,*.exe
set wildignore+=*.DS_Store,*.orig

set nowrap
set linebreak
set colorcolumn=90
nnoremap <leader>w :setlocal wrap!<cr>

set noequalalways
set splitbelow splitright
" set winwidth=90 winheight=24
noremap <f2> :vsp<cr>:bn<cr>
noremap <f3> :sp<cr>:bn<cr>
noremap <f4> :close<cr>
nnoremap <leader>z :close<cr>
nnoremap <m-j> <c-w>w
nnoremap <m-k> <c-w>W

nnoremap <silent> sv :vsp<cr>:bn<cr>
nnoremap <silent> sh :sp<cr>:bn<cr>

set hlsearch
set incsearch
set ignorecase
set smartcase
set gdefault
nnoremap n nzz
nnoremap N Nzz
nnoremap * *<c-o>
nnoremap # #<c-o>
nnoremap <silent> <cr> :nohlsearch<cr>

autocmd BufReadPost,BufWritePre * silent! %s/[\r \t]\+$//
autocmd FocusLost * silent! wa

autocmd! BufReadPost *
      \ if line("'\"") > 0 && line("'\"") <= line("$") |
      \   execute 'normal! g`"zvzz' |
      \ endif

