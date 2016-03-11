" Maintainer:   Lars Smit
" Version:      0.1
" Last Change:  7 februari 2011
" Credits:      Vim color scheme "getafe"
"
" Color Scheme Overview:
"	:ru syntax/hitest.vim
"
" Relevant Help:
"	:h highlight-groups
"
"	Colors
"         HEX       R   G   B
" blue    #01B0F0   1   176 240
" pink    #FF358B   255 53  139
" black   #000000   0   0   0
" brown   #1B1D1E   27  29  30
" green   #AEEE00   174 238 0
" grey    #5A7085   90  112 133
" orange  #FF500E   255 80  14
" yellow  #FFDC00   255 220 0
" white   #F8FFF9   248 255 249
" cyan    #C6C5FE   198 197 254


set background=dark

hi clear

if exists("syntax_on")
  syntax reset
endif

let colors_name = "getafe"

"————————————————+———————————————————————————————————————————————+———+———————————————————————————————————————————————"
"                | GUI                                           |   | TERMINAL                                      "
"      TYPE      +———————————————+———————————————+———————————————+———+———————————————+———————————————+———————————————"
"                | foreground    | background    |               |   | foreground    | background    |               "
"————————————————+———————————————+———————————————+———————————————+———+———————————————+———————————————+———————————————"

"————————————————————————————————————————————————————————————————————————————————————————————————————————————————————"
" Full colors reset
"————————————————————————————————————————————————————————————————————————————————————————————————————————————————————"

" Base colors

hi ColorColumn                     guibg=#080808   gui=none                            ctermbg=NONE
hi Conceal         guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Cursor          guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi CursorIM        guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi CursorColumn    guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi CursorLine                      guibg=#080808   gui=none                            ctermbg=NONE
hi Directory       guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi DiffAdd         guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi DiffChange      guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi DiffDelete      guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi DiffText        guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi ErrorMsg        guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi VertSplit       guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Folded          guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi FoldColumn      guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi SignColumn      guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi IncSearch       guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi LineNr          guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi MatchParen      guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi ModeMsg         guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi MoreMsg         guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi NonText         guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Normal          guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Pmenu           guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi PmenuSel        guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi PmenuSbar       guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi PmenuThumb      guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Question        guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Search          guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi SpecialKey      guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi SpellBad        guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi SpellCap        guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi SpellLocal      guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi SpellRare       guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi StatusLine      guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi StatusLineNC    guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi TabLine         guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi TabLineFill     guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi TabLineSel      guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Title           guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi VisualNOS       guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi WarningMsg      guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi WildMenu        guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE

"————————————————————————————————————————————————————————————————————————————————————————————————————————————————————"
" Syntax related colors
"————————————————————————————————————————————————————————————————————————————————————————————————————————————————————"

hi Comment         guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Constant        guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi String          guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Character       guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Number          guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Boolean         guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Float           guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Identifier      guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Function        guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Statement       guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Conditional     guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Repeat          guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Label           guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Operator        guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Keyword         guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Exception       guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi PreProc         guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Include         guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Define          guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Macro           guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi PreCondit       guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Type            guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi StorageClass    guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Structure       guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Typedef         guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Special         guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi SpecialChar     guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Tag             guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Delimiter       guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi SpecialComment  guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Debug           guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Underlined      guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Ignore          guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Error           guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE
hi Todo            guifg=#F8FFF9   guibg=#080808   gui=none            ctermfg=15      ctermbg=NONE

"————————————————————————————————————————————————————————————————————————————————————————————————————————————————————"
" Interface                                                                                                          "
"————————————————————————————————————————————————————————————————————————————————————————————————————————————————————"

hi ColorColumn                     guibg=#5A7085                                       ctermbg=NONE
hi Cursor          guifg=#1B1D1E   guibg=#FF500E                       ctermfg=234     ctermbg=NONE
hi CursorLine                      guibg=#000000                                       ctermbg=235      cterm=NONE
hi Directory       guifg=#01B0F0                                       ctermfg=39
hi VertSplit       guifg=#F8FFF9   guibg=#5A7085                       ctermfg=15      ctermbg=NONE
hi Folded          guifg=#5A7085   guibg=#FFDC00                       ctermfg=60      ctermbg=NONE
hi IncSearch       guifg=#1B1D1E   guibg=#a7a7a7                       ctermfg=234     ctermbg=NONE
hi LineNr          guifg=#5A7085   guibg=#000000                       ctermfg=60      ctermbg=NONE
hi NonText         guifg=#eeeeee   guibg=#080808                       ctermfg=7       ctermbg=NONE
hi Search          guifg=#F8FFF9   guibg=#FF358B                       ctermfg=15      ctermbg=NONE
hi StatusLine      guifg=#F8FFF9   guibg=#01B0F0    gui=bold           ctermfg=15      ctermbg=NONE
hi StatusLineNC    guifg=#F8FFF9   guibg=#5A7085                       ctermfg=15      ctermbg=NONE
hi Todo            guifg=#000000   guibg=#FFDC00    gui=bold           ctermfg=0       ctermbg=NONE
hi Visual          guifg=#F8FFF9   guibg=#5A7085                                       ctermbg=NONE
hi ModeMsg         guifg=#000000   guibg=#FFDC00                       ctermfg=0       ctermbg=NONE
hi SpecialKey      guifg=#5A7085                                       ctermfg=60
hi ErrorMsg        guifg=#000000   guibg=#FF500E                       ctermfg=0       ctermbg=NONE
hi Title           guifg=#F8FFF9                                       ctermfg=15
hi DiffAdd	       guifg=#000000   guibg=#AEEE00                       ctermfg=0       ctermbg=NONE
hi DiffChange      guifg=#000000   guibg=#FFDC00                       ctermfg=0       ctermbg=NONE
hi DiffDelete      guifg=#000000   guibg=#FF358B                       ctermfg=0       ctermbg=NONE
hi DiffText        guifg=#F8FFF9                                       ctermfg=15
hi MatchParen      guifg=#F8FFF9   guibg=#FF500E                       ctermfg=15      ctermbg=NONE
hi Identifier      guifg=#FF500E                                       ctermfg=202
hi Type            guifg=#AEEE00                                       ctermfg=154
hi Label           guifg=#AEEE00                                       ctermfg=154
hi Special         guifg=#01B0F0                                       ctermfg=39
hi WildMenu        guifg=#01B0F0   guibg=#000000                       ctermfg=39      ctermbg=NONE
hi Pmenu           guifg=#01B0F0   guibg=#000000                       ctermfg=39      ctermbg=NONE
hi PmenuSel                        guibg=#5A7085                                       ctermbg=NONE
hi PmenuSbar                       guibg=#5A7085                                       ctermbg=NONE
hi PmenuThumb      guifg=#01B0F0                                       ctermfg=39

"————————————————————————————————————————————————————————————————————————————————————————————————————————————————————"
" Syntax related colors
"————————————————————————————————————————————————————————————————————————————————————————————————————————————————————"

hi Comment         guifg=#5A7085                                       ctermfg=60
hi Constant        guifg=#FF358B                                       ctermfg=204
hi String          guifg=#FF358B                                       ctermfg=204
hi Number          guifg=#FF500E                                       ctermfg=202
hi Boolean         guifg=#AEEE00                                       ctermfg=154
hi Float           guifg=#B37A7A                                       ctermfg=138
hi Function        guifg=#01B0F0                                       ctermfg=39
hi Statement       guifg=#01B0F0                                       ctermfg=39
hi Conditional     guifg=#AEEE00                                       ctermfg=154
hi Operator        guifg=#FF500E                                       ctermfg=202
hi Keyword         guifg=#AEEE00                                       ctermfg=154
hi Define          guifg=#AEEE00                                       ctermfg=154
hi Delimiter       guifg=#AEEE00                                       ctermfg=154


