
setlocal iskeyword+=-
setlocal foldmethod=marker foldmarker={,}
nnoremap <buffer> <f9> ?{<cr>jV/\v^\s*\}?$<cr>k:sort<cr>:noh<cr>

highlight VendorPrefix gui=bold
match VendorPrefix /-\(moz\|webkit\|o\|ms\)-[A-zA-Z-]\+/

