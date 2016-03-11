
function! ClojureFold()
  if getline(v:lnum) =~ '^\s*(\(ns\|import\|defmacro\|defmethod\|defn\).*\s'
    return ">1"
  elseif getline(v:lnum + 1) =~ '^$'
    return "<1"
  endif
  return "="
endfunction

setlocal foldmethod=expr foldexpr=ClojureFold()

