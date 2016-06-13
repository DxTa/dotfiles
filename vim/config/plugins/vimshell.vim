" let g:vimshelluserprompt = 'fnamemodify(getcwd(), ":~")' let g:vimshell_prompt = '$ '
let g:vimshell_prompt_expr = 'escape(fnamemodify(getcwd(), ":~").">", "\\[]()?! ")." "'
let g:vimshell_prompt_pattern = '^\%(\f\|\\.\)\+> '
nnoremap ,. :VimShell -toggle<cr>
