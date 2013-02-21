
set t_Co=256

set showcmd
set laststatus=2
set statusline=
set statusline+=[%n]%f\ %h%m%r[%{&encoding}\ %{&fileformat}\ %{strlen(&ft)?&ft:'none'}]
set statusline+=%1*
set statusline+=%{exists('g:loaded_syntastic_plugin')?SyntasticStatuslineFlag():''}
set statusline+=%*
set statusline+=%=
set statusline+=%{exists('g:loaded_fugitive')?fugitive#statusline():''}
set statusline+=%-14.(\ \ %l,%c%)\ %P\ [%L]

set display+=lastline
set synmaxcol=350

highlight SpellBad term=underline gui=underline

set background=dark
colorscheme badwolf

if has('gui_running')
  set guioptions=ceg
  set gtl=%t gtt=%F
  set vb t_vb=
  set numberwidth=5
  set guicursor+=a:Cursor-blinkon0
  set columns=100
  set lines=40
  " set cursorline
  " set number

  set background=dark
  colorscheme badwolf

  if has("gui_gtk2")
    " set guifont=DejaVu\ Sans\ Mono\ 11
    set guifont=M+\ 2m\ 11
  elseif has("gui_macvim") || has("gui_mac")
    set macmeta
    set guifont=Menlo:h15
  elseif has("gui_win32")
    set guifont=Consolas:h11
  end

else
  set ttyfast
  set ttyscroll=50
  set ttimeoutlen=10

  augroup FastEscape
    autocmd!
    autocmd InsertEnter * set timeoutlen=0
    autocmd InsertLeave * set timeoutlen=1000
  augroup END
endif
