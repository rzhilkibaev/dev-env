" Get dein {{{1
if (!isdirectory(expand("$HOME/.config/nvim/repos/github.com/Shougo/dein.vim")))
    call system(expand("mkdir -p $HOME/.config/nvim/repos/github.com"))
    call system(expand("git clone https://github.com/Shougo/dein.vim $HOME/.config/nvim/repos/github.com/Shougo/dein.vim"))
endif

set runtimepath+=~/.config/nvim/repos/github.com/Shougo/dein.vim/
if dein#load_state(expand('~/.config/nvim'))
    call dein#begin(expand('~/.config/nvim'))
    call dein#add('Shougo/dein.vim')

    " Plugins {{{1
    " themes
    call dein#add('vim-airline/vim-airline') " advanced status line
    call dein#add('rzhilkibaev/gruvbox')
    " git
    call dein#add('tpope/vim-fugitive') " git support
    " quick search
    call dein#add('junegunn/fzf', { 'build': './install --all' }) " fuzzy finder
    call dein#add('junegunn/fzf.vim')
    call dein#add('scrooloose/nerdtree')
    " autocomplete
    call dein#add('Shougo/deoplete.nvim') " autocomplete
    " file types
    call dein#add('hashivim/vim-terraform.git')
    call dein#add('ekalinin/Dockerfile.vim', {'on_ft': 'Dockerfile'})
    call dein#add('tmhedberg/SimpylFold', {'on_ft': 'python'})
    " google a word under cursor
    call dein#add('szw/vim-g')
    " some extra file operations (:Rename, :Move, :SudoWrite,...)
    call dein#add('tpope/vim-eunuch')
    " seamlessly navigate between tmux and vim panels
    call dein#add('christoomey/vim-tmux-navigator')
    " send commands to tmux
    call dein#add('benmills/vimux')
    " code formatter
    call dein#add('sbdchd/neoformat')
    " Ruby
    call dein#add('tpope/vim-rails')

    " Install all {{{1
    if dein#check_install()
        call dein#install()
    endif

    call dein#end()
    call dein#save_state()
endif
filetype plugin indent on

" Theme {{{1
set cursorline
set termguicolors
set background=dark
colorscheme gruvbox
" enable transparent background
" au ColorScheme * hi Normal ctermbg=none guibg=none
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

" json {{{2
autocmd FileType json setlocal foldmethod=indent
autocmd FileType json setlocal foldlevel=99 " unfold everything on start
" indentation
autocmd FileType json setlocal tabstop=2 " show existing Tab character as this many spaces
autocmd FileType json setlocal softtabstop=2 " how many spaces to insert when hitting Tab key
autocmd FileType json setlocal shiftwidth=2 " how many spaces to insert for each step of identation

" terraform {{{2
autocmd FileType terraform setlocal foldmarker={,}
autocmd FileType terraform setlocal foldmethod=marker
" indentation
autocmd FileType terraform setlocal tabstop=2 " show existing Tab character as this many spaces
autocmd FileType terraform setlocal softtabstop=2 " how many spaces to insert when hitting Tab key
autocmd FileType terraform setlocal shiftwidth=2 " how many spaces to insert for each step of identation

" ruby {{{2
autocmd FileType ruby setlocal foldmethod=indent
autocmd FileType ruby setlocal foldlevel=99 " unfold everything on start
" indentation
autocmd FileType ruby setlocal tabstop=2 " show existing Tab character as this many spaces
autocmd FileType ruby setlocal softtabstop=2 " how many spaces to insert when hitting Tab key
autocmd FileType ruby setlocal shiftwidth=2 " how many spaces to insert for each step of identation
" find method definition
" match whole word def, match whole current word
nnoremap <silent> <Leader>fm :Ag \bdef\b \b<C-R><C-W>\b<CR>
" find class definition
" match whole word class, match whole current word, match eol or space or ::
nnoremap <silent> <Leader>fc :Ag \bclass\b .*\b<C-R><C-W>\b($\| \|::)<CR>
" Keys {{{1
" When mapping keys keep in maind that Ctrl+{j,k} is used in fzf
map q <Nop>
let mapleader="\<Space>"
nnoremap <leader>qq :qa!<cr>
nnoremap <leader>w :w<cr>
" go into normal mode with double esc
tnoremap <esc><esc> <C-\><C-n>
" delete not into unnambed buffer but into the black hole
nnoremap d "_d
vnoremap d "_d
nnoremap D "_D
vnoremap D "_D
nnoremap c "_c
vnoremap c "_c
nnoremap C "_C
vnoremap C "_C
nnoremap dd "_dd
vnoremap dd "_dd
" Shift+h/l to go to behining/end of the line
nnoremap H ^
nnoremap L $
" Backspace to switch between two latest buffers
nnoremap <BS> <C-^>
" Ctrl+n to jump to next buffer
nnoremap <C-n> :bnext<CR>
" Ctrl+p to jump to previous buffer
nnoremap <C-p> :bprevious<CR>
" find file
nnoremap <leader>ff :Files<cr>
" find line
nnoremap <leader>fl :Ag<cr>
" find word under cursor
nnoremap <silent> <Leader>fw :Ag <C-R><C-W><CR>
" NERDTree
nnoremap <leader>ft :NERDTreeToggle<cr>
" git add current file
nnoremap <leader>gw :Gwrite<cr>
" git commit
nnoremap <leader>gc :Gcommit<cr>i
" git status
nnoremap <leader>gs :Gstatus<cr>
" git diff current file
nnoremap <leader>gd :Gvdiff<cr>
" make (! prevents jumping to the file with first error, vim doesn't recognize
" file names correctly sometimes.
nnoremap <leader>m :make!<cr>
" google a word under cursor on F1
nnoremap <F1> :Googlef<cr>
" vimux
nnoremap <leader>vc :VimuxPromptCommand<cr>
nnoremap <leader>c :VimuxRunLastCommand<cr>

" Tab completion {{{2
" 1. If popup menu is visible, select and insert next item
" 2. Otherwise, if within a snippet, jump to next input
" 3. Otherwise, if preceding chars are whitespace, insert tab char
" 4. Otherwise, start manual autocomplete
imap <silent><expr><Tab> pumvisible() ? "\<C-n>"
            \ : (<SID>is_whitespace() ? "\<Tab>"
            \ : deoplete#manual_complete())

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
set mouse=a " enable mouse in all modes
set undofile
set hidden " can switch to another buffer without saving the current one
set nowrap " disable word wrapping
set virtualedit=all " allow moving cursor past end of line in all modes
set number " show line numbers
set sidescroll=1 " horizontal scrolling reveals this many characters at once, not half a window
set clipboard+=unnamedplus " use system clipboard (make sure xsel is installed)
set hlsearch " highlight all occurences while typing
set ignorecase
set smartcase
set wildmode=longest:full,full
set inccommand=split " show substitute result live
" Open new split panes to right and bottom, which feels more natural than Vim’s default
set splitbelow
set splitright
" Align blocks of text and keep them selected
vmap < <gv
vmap > >gv
let g:NERDTreeWinPos = "right"
let NERDTreeQuitOnOpen=1

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
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif " autoclose preview window

" Source extra configs {{{1
runtime! init.d/*.vim
