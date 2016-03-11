
function! SetIndent(n)
  execute "setlocal tabstop=".a:n
  execute "setlocal shiftwidth=".a:n
  execute "setlocal softtabstop=".a:n
endfunction
command! -bar -nargs=1 SetIndent silent call SetIndent(<args>)


" From https://github.com/garybernhardt/
function! ExtractVariable()
  let name = input("Variable name: ")
  if name == ''
    return
  endif
  normal! gv
  exec "normal c" . name
  exec "normal! O" . name . " = "
  normal! $p
endfunction
vnoremap <leader>ve :call ExtractVariable()<cr>


function! InlineVariable()
  let l:tmp_a = @a
  normal "ayiw
  normal 2daW
  let l:tmp_b = @b
  normal "bd$
  normal dd
  normal k$
  exec '/\<' . @a . '\>'
  exec ':.s/\<' . @a . '\>/' . @b
  let @a = l:tmp_a
  let @b = l:tmp_b
endfunction
nnoremap <leader>vi :call InlineVariable()<cr>


function! s:VSetSearch()
  let temp = @@
  norm! gvy
  let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
  let @@ = temp
endfunction
vnoremap * :<C-u>call <SID>VSetSearch()<cr>//<cr><c-o>
vnoremap # :<C-u>call <SID>VSetSearch()<cr>??<cr><c-o>


function! ShowSyntaxStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunction
nnoremap <f7> :call ShowSyntaxStack()<cr>


" Compile c source code using gcc and run
function! CompileRunGcc()
  exec "w"
  exec "!gcc % -Wall -lm -o %<.o"
  silent exec "!%:p:h/%<.o"
endfunction


" Open URL in web-browser
function! HandleURL()
  let s:uri = matchstr(getline("."), '[a-z]*:\/\/[^ >,;]*')
  echo s:uri
  if s:uri != ""
    silent exec "!open '".s:uri."'"
  else
    echo "No URI found in line."
  endif
endfunction
map <leader>U :call HandleURL()<cr>


" Sudo write
command! -bar -nargs=0 SudoW silent execute 'write !sudo tee % > /dev/null' | silent edit!


" Hex Editing
command! -bar -nargs=0 HexR silent execute '%!xxd'
command! -bar -nargs=0 HexW silent execute '%!xxd -r'


" Diff this
command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis


" CD
command! -bar -nargs=0 Cdf execute 'cd %:p:h'


" Scratch
function! ScratchToggle()
  if exists("w:is_scratch_window")
    unlet w:is_scratch_window
    exec q
  else
  endif
endfunction
command! ScratchToggle call ScratchToggle()
nnoremap <silent> <f8> :ScratchToggle<cr>

" Rename
function! RenameFile(new_name)
  let old_name = expand('%')
  let new_name = a:new_name
  if new_name != '' && new_name != old_name
    exec ':saveas ' . new_name
    exec ':silent !rm ' . old_name
    redraw!
  endif
endfunction
command! -bar -nargs=1 Rename silent call RenameFile(<args>)
