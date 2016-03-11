
" Clojure
let g:vimclojure#FuzzyIndent=1
let g:vimclojure#HighlightContrib=1
" let g:vimclojure#DynamicHighlighting=1
let g:vimclojure#ParenRainbow=1
" let g:vimclojure#WantNailgun=1
" let g:vimclojure#NailgunClient=$HOME."/local/bin/ng"
let g:ref_clojure_cmd=$HOME."/local/bin/clj"
let g:ref_clojure_classpath=[
      \ $HOME."/local/jars/clojure-1.4.0.jar",
      \ $HOME."/local/jars/clojure-contrib.jar"
      \ ]

" Ruby
command! Rroutes :edit config/routes.rb
autocmd BufRead,BufNewFile {Gemfile,Rakefile,Vagrantfile,Thorfile,config.ru} set ft=ruby
let g:ruby_no_expensive=1
let g:ruby_space_error=1
let g:rubycomplete_buffer_loading=1
let g:rubycomplete_classes_in_global=1
let g:rubycomplete_rails=1

" PHP
let g:php_baselib=1
let g:php_noShortTags=1
let g:php_htmlInString=0

" HTML
let g:html_indent_script1 = "inc"
let g:html_indent_style1 = "inc"
let g:html_indent_inctags = "head,body,article,aside,details,figcaption,figure,footer,header,hgroup,menu,nav,section"

let g:html_no_rendering=1

let g:envent_handler_attributes_complete=0
let g:html5_rdfa_attributes_complete=0
let g:html5_microdata_attributes_complete=0
let g:html5_aria_attributes_complete=0

" Markdown, Pandoc
autocmd FileType markdown,pandoc syntax match Comment /\%^---\_.\{-}---$/
