set nocompatible                                        " not compatible with vi, required for extra features to work
let mapleader=','

" configure dein plugin manager
set runtimepath+=~/.vim/dein/repos/github.com/Shougo/dein.vim
call dein#begin(expand('~/.vim/dein')) " plugins' root path
call dein#add('Shougo/dein.vim') " plugin manager
call dein#add('Shougo/vimproc.vim', {'build' : 'make'}) " enables parallel execution (used by other plugins)
call dein#add('Shougo/unite.vim') " search trough file names, file content, buffers...
call dein#add('Shougo/neomru.vim') " unite plugin source, allows to search for most recently used files
call dein#add('Shougo/neoyank.vim') " unite plugin source, allows to search trough yank history
call dein#add('chase/vim-ansible-yaml') " ansible syntax hightlight
call dein#add('ekalinin/Dockerfile.vim') " Dockerfile syntax highlight
call dein#add('vim-airline/vim-airline') " advanced status line
call dein#add('tmhedberg/SimpylFold') " python code folding
call dein#add('tpope/vim-sensible') " convinient defaults
call dein#add('altercation/vim-colors-solarized')
call dein#add('tpope/vim-fugitive') " adds git commands to vim
call dein#end()

filetype plugin indent on

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
set clipboard=unnamedplus

set hlsearch " highlight all occurences when searching
set foldmethod=indent " fold based on identation
set foldlevel=99 " unfold everything on start

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
nnoremap <leader>r :<C-u>Unite -no-split -start-insert -ignorecase buffer file_mru file_rec/async:!<cr>
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

" Enable folding for xml file type
let g:xml_syntax_folding=1
autocmd FileType xml setlocal foldmethod=syntax
