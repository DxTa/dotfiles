
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

