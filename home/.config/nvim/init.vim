let mapleader="\<Space>"

" exit INSERT mode with jj
inoremap jj <Esc>
" Ctrl+n to jump to next buffer
nnoremap <C-n> :bnext<CR>
" Ctrl+p to jump to previous buffer
nnoremap <C-p> :bprevious<CR>

" configure dein plugin manager
set runtimepath+=~/.config/nvim/dein/repos/github.com/Shougo/dein.vim
call dein#begin(expand('~/.config/nvim/dein')) " plugins' root path
call dein#add('Shougo/dein.vim') " plugin manager
call dein#add('Shougo/unite.vim') " search trough file names, file content, buffers...
call dein#add('Shougo/neomru.vim') " unite plugin source, allows to search for most recently used files
call dein#add('Shougo/neoyank.vim') " unite plugin source, allows to search trough yank history
call dein#add('chase/vim-ansible-yaml') " ansible syntax hightlight
call dein#add('ekalinin/Dockerfile.vim') " Dockerfile syntax highlight
call dein#add('vim-airline/vim-airline') " advanced status line
call dein#add('tmhedberg/SimpylFold') " python code folding
call dein#add('altercation/vim-colors-solarized')
call dein#add('tpope/vim-fugitive') " adds git commands to vim
call dein#add('nathanaelkane/vim-indent-guides') " adds indentation guides
call dein#end()

set nowrap " disable word wrapping
set number " show line numbers
set sidescroll=1 " horizontal scrolling reveals this many characters at once, not half a window

" Tab character handling
set tabstop=4 " show existing Tab character as 4 spaces
set softtabstop=4 " how many spaces to insert when hitting Tab key
set shiftwidth=4 " how many spaces to insert for each step of identation
set expandtab " hitting Tab key inserts softtabstop spaces

" Buffers
set hidden " can switch to another buffer without saving the current one

" Highlight current line and column
"set cursorline                                                                                                                                                                                                                               
"set cursorcolumn
"hi CursorLine   cterm=NONE ctermbg=255
"hi CursorColumn cterm=NONE ctermbg=255

" Use CLIPBOARD (gui clipboard) for yank, put, etc...
set clipboard+=unnamedplus

set foldmethod=indent " fold based on identation
set foldlevel=99 " unfold everything on start

" Transparent background
let g:solarized_termtrans=1

" ignore whitespace in diff mode
if &diff
    set diffopt+=iwhite
endif

" Configure airline
let g:airline_powerline_fonts=1 " Enable powerline fonts (nice looking airline with extra glyphs)
let g:airline#extensions#tabline#enabled = 1 " Enable bufer list on top

" confugure Unite
let g:unite_source_history_yank_enable = 1
call unite#filters#matcher_default#use(['matcher_fuzzy'])
nnoremap <leader>r :<C-u>Unite -no-split -start-insert -ignorecase buffer file_mru file_rec/neovim<cr>
nnoremap <leader>g :<C-u>Unite -no-split -start-insert -ignorecase grep:.<cr>
nnoremap <leader>y :<C-u>Unite -no-split -start-insert -ignorecase history/yank<cr>
nnoremap <leader>f :<C-u>Unite -no-split -start-insert -ignorecase line<cr>

" Custom mappings for the unite buffer
autocmd FileType unite call s:unite_settings()
function! s:unite_settings()
    " Play nice with supertab
    let b:SuperTabDisabled=1
    " Enable navigation with control-j and control-k in insert mode
    imap <buffer> <C-j>   <Plug>(unite_select_next_line)
    imap <buffer> <C-k>   <Plug>(unite_select_previous_line)
endfunction

let g:unite_source_history_yank_enable = 1

" Solarized
set background=light
colorscheme solarized

" Enable folding for xml file type
let g:xml_syntax_folding=1
autocmd FileType xml setlocal foldmethod=syntax

" Enable indent guides
let g:indent_guides_enable_on_vim_startup=1
