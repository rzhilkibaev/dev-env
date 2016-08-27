" Plugins  {{{1
" Setup dein {{{2
if (!isdirectory(expand("$HOME/.config/nvim/repos/github.com/Shougo/dein.vim")))
    call system(expand("mkdir -p $HOME/.config/nvim/repos/github.com"))
    call system(expand("git clone https://github.com/Shougo/dein.vim $HOME/.config/nvim/repos/github.com/Shougo/dein.vim"))
endif

set runtimepath+=~/.config/nvim/repos/github.com/Shougo/dein.vim/
call dein#begin(expand('~/.config/nvim'))
call dein#add('Shougo/dein.vim')

" Plugins {{{2
call dein#add('vim-airline/vim-airline') " advanced status line
call dein#add('morhetz/gruvbox')
call dein#add('tpope/vim-fugitive') " git support
call dein#add('Shougo/deoplete.nvim') " autocomplete
call dein#add('zchee/deoplete-jedi') " autocomplete for python (make sure to install jedi)
call dein#add('neomake/neomake')
call dein#add('hashivim/vim-terraform.git', {'on_ft': 'terraform'})
call dein#add('ekalinin/Dockerfile.vim', {'on_ft': 'Dockerfile'})
call dein#add('tfnico/vim-gradle', {'on_ft': 'groovy'})

" Install all {{{2
if dein#check_install()
    call dein#install()
    let pluginsExist=1
endif

call dein#end()
filetype plugin indent on

" Theme {{{1
set termguicolors
set background=dark
colorscheme gruvbox
" enable transparent background
au ColorScheme * hi Normal ctermbg=none guibg=none

" File types {{{1
" vim {{{2
autocmd FileType vim setlocal foldmethod=marker
" xml {{{2
autocmd FileType xml let g:xml_syntax_folding=1
autocmd FileType xml setlocal foldmethod=syntax
autocmd FileType xml set foldlevel=99 " unfold everything on start

" Keys {{{1
map q <Nop>
" Ctrl+n to jump to next buffer
nnoremap <C-n> :bnext<CR>
" Ctrl+p to jump to previous buffer
nnoremap <C-p> :bprevious<CR>

" Tab character handling {{{1
set tabstop=4 " show existing Tab character as 4 spaces
set softtabstop=4 " how many spaces to insert when hitting Tab key
set shiftwidth=4 " how many spaces to insert for each step of identation
set expandtab " hitting Tab key inserts softtabstop spaces

" Airline {{{1
let g:airline_powerline_fonts=1 " Enable powerline fonts (nice looking airline with extra glyphs)
let g:airline#extensions#tabline#enabled = 1 " Enable bufer list on top
let g:airline#extensions#tabline#left_sep = '' " Straight bufer tabs
let g:airline#extensions#tabline#left_alt_sep = '' " Straight bufer tabs

" Misc {{{1
set undofile
set hidden " can switch to another buffer without saving the current one
set nowrap " disable word wrapping
set number " show line numbers
set sidescroll=1 " horizontal scrolling reveals this many characters at once, not half a window
set clipboard+=unnamedplus " use system clipboard (make sure xsel is installed)
set hlsearch " highlight all occurences while typing
" Align blocks of text and keep them selected
vmap < <gv
vmap > >gv

" Deoplete {{{1
let g:deoplete#enable_at_startup = 1
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif " autoclose preview window

" Neomake {{{1
autocmd! BufWritePost * Neomake " run Neomake on save
let g:neomake_open_list = 2 " open errors list, close when no errors
