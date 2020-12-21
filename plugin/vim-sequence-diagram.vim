vim9script
# NiVa 2020/12/21 Vim9script Version

import Generate_diagram from "../autoload/vim_seq_diag.vim"
def g:Stuff_SequenceDiagram(path: string)
  Generate_diagram(path)
enddef
# Vim plugin file for rendering
# js-sequence-diagram(https://bramp.github.io/js-sequence-diagrams/)
#
# Maintainer:	Xavier Chow <xiayezhou at gmail dot com>
# Last change:	Apr 08 2016
# Version:     0.1.0

if exists( "g:generate_diagram" )
  finish
endif
g:generate_diagram = 1

#default nmap is <leader>t
if ( !hasmapto( '<Plug>GenerateDiagram', 'n' ) )
  nmap <unique> <leader>t <Plug>GenerateDiagram
endif

autocmd FileType sequence nmap <silent> <buffer> <Plug>GenerateDiagram
      \ :call g:Stuff_SequenceDiagram(resolve(expand('<sfile>:p:h')) .. (( has('unix') ) ? '/' : '\'))<CR>

if !exists("g:generate_diagram_theme_hand")
  g:generate_diagram_theme_hand = 0
endif


