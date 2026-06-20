" ================================
" Basic Settings
" ================================

set clipboard=unnamedplus
set completeopt=noinsert,menuone,noselect
set cursorline
set number
set cc=80
set title
set hidden
set autoindent
set mouse=a
set inccommand=split
set splitbelow splitright
set ttyfast

filetype plugin indent on
syntax on

set wildmenu
set spell

" ================================
" Plugin Management
" ================================

call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')

Plug 'morhetz/gruvbox'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ryanoasis/vim-devicons'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
Plug 'jiangmiao/auto-pairs'
Plug 'sheerun/vim-polyglot'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'tpope/vim-fugitive'

call plug#end()

" ================================
" Plugin Configuration
" ================================

colorscheme gruvbox
set background=dark

let g:airline_solarized_bg='dark'
let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#left_sep=' '
let g:airline#extensions#tabline#left_alt_sep='|'
let g:airline#extensions#tabline#formatter='unique_tail'

let NERDTreeQuitOnOpen=1
let NERDTreeShowHidden=1

" ================================
" Key Mappings
" ================================

let mapleader = ","

nnoremap <leader>n :NERDTreeToggle<CR>
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprevious<CR>
nnoremap <leader>bd :bdelete<CR>
