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
" themes
call dein#add('vim-airline/vim-airline') " advanced status line
call dein#add('morhetz/gruvbox')
" git
call dein#add('tpope/vim-fugitive') " git support
call dein#add('gregsexton/gitv') " git browser
" quick search
call dein#add('junegunn/fzf', { 'build': './install --all' }) " fuzzy finder
call dein#add('junegunn/fzf.vim')
" snippets
call dein#add('Shougo/neosnippet')
call dein#add('Shougo/neosnippet-snippets')
" autocomplete
call dein#add('Shougo/deoplete.nvim') " autocomplete
call dein#add('zchee/deoplete-jedi', {'on_ft': 'python'}) " autocomplete for python (make sure to install jedi)
" autobuild
call dein#add('neomake/neomake')
" file types
call dein#add('hashivim/vim-terraform.git', {'on_ft': 'terraform'})
call dein#add('ekalinin/Dockerfile.vim', {'on_ft': 'Dockerfile'})
call dein#add('tfnico/vim-gradle', {'on_ft': 'groovy'})
call dein#add('tmhedberg/SimpylFold', {'on_ft': 'python'})

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
" Airline
let g:airline_powerline_fonts=1 " Enable powerline fonts (nice looking airline with extra glyphs)
let g:airline#extensions#tabline#enabled = 1 " Enable bufer list on top
let g:airline#extensions#tabline#show_buffers = 1 " Show buffers even if one buffer
let g:airline#extensions#tabline#show_close_button = 0 " 'X' in the top right corner
let g:airline#extensions#tabline#show_tabs = 0 " Never show tabs, they hide buffers
let g:airline#extensions#tabline#show_tab_type = 0 " remove 'buffers' word in the top right corner
let g:airline#extensions#tabline#left_sep = '' " Straight bufer tabs
let g:airline#extensions#tabline#left_alt_sep = '' " Straight bufer tabs

" File types {{{1
" vim {{{2
autocmd FileType vim setlocal foldmethod=marker
" xml {{{2
let g:xml_syntax_folding=1
autocmd FileType xml setlocal foldmethod=syntax
autocmd FileType xml setlocal foldlevel=99 " unfold everything on start

" yaml {{{2
autocmd FileType yaml setlocal foldmethod=indent
autocmd FileType yaml setlocal foldlevel=99 " unfold everything on start
" indentation
autocmd FileType yaml setlocal tabstop=2 " show existing Tab character as this many spaces
autocmd FileType yaml setlocal softtabstop=2 " how many spaces to insert when hitting Tab key
autocmd FileType yaml setlocal shiftwidth=2 " how many spaces to insert for each step of identation

" Keys {{{1
map q <Nop>
" Backspace to switch between two latest buffers
nnoremap <BS> <C-^>
" Ctrl+n to jump to next buffer
nnoremap <C-n> :bnext<CR>
" Ctrl+p to jump to previous buffer
nnoremap <C-p> :bprevious<CR>
" Tab completion {{{2
" 1. If popup menu is visible, select and insert next item
" 2. Otherwise, if within a snippet, jump to next input
" 3. Otherwise, if preceding chars are whitespace, insert tab char
" 4. Otherwise, start manual autocomplete
imap <silent><expr><Tab> pumvisible() ? "\<C-n>"
            \ : (neosnippet#jumpable() ? "\<Plug>(neosnippet_jump)"
            \ : (<SID>is_whitespace() ? "\<Tab>"
            \ : deoplete#manual_complete()))

function! s:is_whitespace()
	let col = col('.') - 1
	return ! col || getline('.')[col - 1] =~? '\s'
endfunction

" Tab character handling {{{1
set tabstop=4 " show existing Tab character as 4 spaces
set softtabstop=4 " how many spaces to insert when hitting Tab key
set shiftwidth=4 " how many spaces to insert for each step of identation
set expandtab " hitting Tab key inserts softtabstop spaces

" Misc {{{1
set undofile
set hidden " can switch to another buffer without saving the current one
set nowrap " disable word wrapping
set number " show line numbers
set sidescroll=1 " horizontal scrolling reveals this many characters at once, not half a window
set clipboard+=unnamedplus " use system clipboard (make sure xsel is installed)
set hlsearch " highlight all occurences while typing
set wildmode=longest:full,full
" Align blocks of text and keep them selected
vmap < <gv
vmap > >gv

" Folding {{{1
function! MyFoldText() 
    let line = getline(v:foldstart)

    let nucolwidth = &fdc + &number * &numberwidth
    let windowwidth = winwidth(0) - nucolwidth - 3
    let foldedlinecount = v:foldend - v:foldstart

    " expand tabs into spaces
    let onetab = strpart('          ', 0, &tabstop)
    let line = substitute(line, '\t', onetab, 'g')

    let line = strpart(line, 0, windowwidth - 2 -len(foldedlinecount))
    let fillcharcount = windowwidth - len(line) - len(foldedlinecount)
    return line . ' ' . repeat(" ",fillcharcount) . foldedlinecount . ' ' . ' '
endfunction
set foldtext=MyFoldText() 

" Deoplete {{{1
let g:deoplete#enable_at_startup = 1
let g:deoplete#sources#jedi#show_docstring = 1
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif " autoclose preview window

" Neomake {{{1
autocmd! BufWritePost * Neomake " run Neomake on save
let g:neomake_open_list = 2 " open errors list, close when no errors

