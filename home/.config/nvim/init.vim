" Get dein {{{1
if (!isdirectory(expand("$HOME/.cache/dein/repos/github.com/Shougo/dein.vim")))
    call system(expand("mkdir -p $HOME/.cache/dein/repos/github.com"))
    call system(expand("git clone https://github.com/Shougo/dein.vim $HOME/.cache/dein/repos/github.com/Shougo/dein.vim"))
endif

set runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim/
if dein#load_state(expand('~/.cache/dein'))
    call dein#begin(expand('~/.cache/dein'))
    call dein#add('Shougo/dein.vim')

    " Plugins {{{1
    " themes
    call dein#add('rzhilkibaev/gruvbox')
    " quick search
    call dein#add('junegunn/fzf', { 'build': './install --all' }) " fuzzy finder
    call dein#add('junegunn/fzf.vim')
    " some extra file operations (:Rename, :Move, :SudoWrite,...)
    call dein#add('tpope/vim-eunuch')
    " seamlessly navigate between tmux and vim panels
    call dein#add('christoomey/vim-tmux-navigator')
    " send commands to tmux
    call dein#add('benmills/vimux')

    call dein#end()
    call dein#save_state()
endif
filetype plugin indent on

" Theme {{{1
set cursorline
set termguicolors
set background=dark
colorscheme gruvbox

" File types {{{1
" vim {{{2
autocmd FileType vim setlocal foldmethod=marker
" log {{{2
autocmd FileType text setlocal foldmethod=marker
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
" foldmethod=syntax makes it very slow to open large files
" foldmethod=indent is meh
if getfsize(expand(@%)) < 10000
    autocmd FileType json setlocal foldmethod=indent
endif
autocmd FileType json setlocal foldlevel=99 " unfold everything on start
" indentation
autocmd FileType json setlocal tabstop=2 " show existing Tab character as this many spaces
autocmd FileType json setlocal softtabstop=2 " how many spaces to insert when hitting Tab key
autocmd FileType json setlocal shiftwidth=2 " how many spaces to insert for each step of identation

" ruby {{{2
" Don't add folding for ruby. It slows down scrolling and startup by a lot
" even for small files.
"
" indentation
autocmd FileType ruby setlocal tabstop=2 " show existing Tab character as this many spaces
autocmd FileType ruby setlocal softtabstop=2 " how many spaces to insert when hitting Tab key
autocmd FileType ruby setlocal shiftwidth=2 " how many spaces to insert for each step of identation
" Keys {{{1
" When mapping keys keep in maind that Ctrl+{j,k} is used in fzf
map q <Nop>
let mapleader="\<Space>"
" go into normal mode with double esc
tnoremap <esc><esc> <C-\><C-n>
" Ctrl+n to jump to next buffer
nnoremap <C-n> :bnext<CR>
" Ctrl+p to jump to previous buffer
nnoremap <C-p> :bprevious<CR>
" git add current file
nnoremap <leader>gw :Gwrite<cr>
" git commit (i - go to insert mode)
nnoremap <leader>gc :Gcommit<cr>i
" git status
nnoremap <leader>gs :Gstatus<cr>
" git diff current file
nnoremap <leader>gd :Gvdiff<cr>
" vimux
function! VimuxSendSelection()
    call VimuxSendText(@v)
    call VimuxSendKeys("Enter")
endfunction
" If text is selected, save it in the v buffer and send that buffer it to tmux
vmap <leader>vs "vy :call VimuxSendSelection()<CR>
nnoremap <leader>vc :VimuxPromptCommand<cr>
nnoremap <leader>c :VimuxRunLastCommand<cr>
" fzf
" Override :Ag to show a preview window (toggle with Ctrl-?)
" If called as :Ag! then take up entire screen and put the preview window up above
command! -bang -nargs=* Ag
      \ call fzf#vim#ag(<q-args>,
      \                 <bang>0 ? fzf#vim#with_preview('up:60%')
      \                         : fzf#vim#with_preview('right:60%', '?'),
      \                 <bang>0)
command! -bang -nargs=* BLines
      \ call fzf#vim#buffer_lines(<q-args>,
      \                 <bang>0 ? fzf#vim#with_preview('up:60%')
      \                         : fzf#vim#with_preview('right:60%', '?'),
      \                 <bang>0)
" find file
nnoremap <leader>ff :Files<cr>
" find line
nnoremap <leader>fl :Ag<cr>
" find word under cursor
nnoremap <silent> <Leader>fw :Ag <C-R><C-W><CR>

" Tab character handling {{{1
set tabstop=4 " show existing Tab character as 4 spaces
set softtabstop=4 " how many spaces to insert when hitting Tab key
set shiftwidth=4 " how many spaces to insert for each step of identation
set expandtab " hitting Tab key inserts softtabstop spaces

" " Misc {{{1
set mouse=a " enable mouse in all modes
" Disable persistent undo for faster startup.
" set undofile
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

" Source extra configs {{{1
runtime! init.d/*.vim
