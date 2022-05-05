
set nocompatible
set nolist
set scrolloff=5
set scrolljump=5
set sidescroll=10
set showcmd
set showmatch
set showmode
set ruler
set noerrorbells
set undolevels=1000
set viminfo='50,"50

" Tab expansion
set softtabstop=2
set shiftwidth=2
set expandtab
set tabstop=2
set backspace=2

" Line numbers
set number

" Search
set incsearch
set hlsearch

" Indentation
filetype indent plugin on
set autoindent

" Show tabs as an error
syn match tab display "\t"
hi link tab Error

" Change the color of comments
hi Comment ctermfg=darkcyan

" Kill the arrow keys
inoremap  <Up>    <NOP>
inoremap  <Down>  <NOP>
inoremap  <Left>  <NOP>
inoremap  <Right> <NOP>
noremap   <Up>    <NOP>
noremap   <Down>  <NOP>
noremap   <Right> <NOP>
noremap   <Left>  <NOP>

imap  ii  <Esc>

