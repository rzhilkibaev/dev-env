set nocompatible                                        " not compatible with vi, required by Vundle
filetype off                                            " required by Vundle

" set the runtime path to include Vundle
set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()
Plugin 'gmarik/Vundle.vim'
Plugin 'chase/vim-ansible-yaml'
Plugin 'fholgado/minibufexpl.vim' 
Plugin 'ekalinin/Dockerfile.vim'
Plugin 'altercation/vim-colors-solarized'
Plugin 'mileszs/ack.vim'
Plugin 'rking/ag.vim'
Plugin 'tmhedberg/SimpylFold'
" git wrapper
Plugin 'tpope/vim-fugitive'
call vundle#end()

" Put your non-Plugin stuff after this line
"
filetype plugin indent on

:set nowrap
:set tabstop=4 shiftwidth=4 expandtab
:set hidden
:set wildmenu
" Show line numbers
:set number
" When scrolling horizontally, advance by one character, not half the window
" size
:set sidescroll=1

"XML folding
let g:xml_syntax_folding=1
autocmd FileType xml setlocal foldmethod=syntax

"Highlight current line and column
:set cursorline                                                                                                                                                                                                                               
:set cursorcolumn
:hi CursorLine   cterm=NONE ctermbg=255
:hi CursorColumn cterm=NONE ctermbg=255

"Use CLIPBOARD for yank, put, etc...
:set clipboard=unnamedplus

"Highlight all occurences when searching
:set hlsearch
:set foldmethod=indent
:set foldlevel=99

" If in diff mode then ignore whitespace
if &diff
    set diffopt+=iwhite
endif
