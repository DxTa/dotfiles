
set foldmethod=manual
set foldlevelstart=0
set foldcolumn=4
set foldnestmax=3


function! CustomFoldText()
  let line = getline(v:foldstart)

  let nucolwidth = &fdc + &number * &numberwidth
  let windowwidth = winwidth(0) - nucolwidth - 3
  let foldedlinecount = v:foldend - v:foldstart

  " expand tabs into spaces
  let onetab = strpart('    ', 0, &tabstop)
  let line = substitute(line, '\t', onetab, 'g')

  let line = strpart(line, 0, windowwidth - 2 -len(foldedlinecount))
  let fillcharcount = windowwidth - len(line) - len(foldedlinecount) - 6
  return line . '…' . repeat(" ",fillcharcount) . foldedlinecount . ' lines' . '  '
endfunction
set foldtext=CustomFoldText()


nnoremap <silent> <space> za
nnoremap zr zCzO
nnoremap z0 zMzvzz
