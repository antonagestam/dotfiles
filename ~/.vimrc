set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Plugin 'godlygeek/tabular'
Plugin 'plasticboy/vim-markdown'
" Plugin 'JulesWang/css.vim'
" Plugin 'pangloss/vim-javascript'
Plugin 'ekalinin/Dockerfile.vim'
Plugin 'dense-analysis/ale'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'sheerun/vim-polyglot'

let g:vim_markdown_folding_disabled = 1

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" MY STUFF :D

syntax on
set modeline
set background=dark

" show eg number of lines selected in visual mode
set showcmd

" tab settings
filetype indent plugin on
set tabstop=8
set expandtab
set shiftwidth=4
set softtabstop=4
set shiftround
set smarttab

" use actual tab chars in Makefiles
autocmd FileType make set tabstop=8 shiftwidth=8 softtabstop=0 noexpandtab

" fix indentation in yaml and ruby files
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType ruby setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType json setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType elm setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType markdown setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType txt setlocal ts=2 sts=2 sw=2 expandtab

" highlight long lines
" highlight OverLength ctermbg=red ctermfg=white guibg=#592929
" match OverLength /\%81v.\+/

" http://vim.wikia.com/wiki/Backspace_and_delete_problems
set backspace=indent,eol,start

" remove trailing whitespace
autocmd BufWritePre *.py %s/\s\+$//e

" vsplit opens new file to the right
set splitright

" remember last position in file
if has("autocmd")
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" show a visual line under the cursor's current line
" set cursorline

" show the matching part of the pair for [] {} and ()
set showmatch

" enable all Python syntax highlighting features
let python_highlight_all = 1

" enable mouse scroll
set mouse=a

" associate *.cnf files with ini syntax
au BufRead,BufNewFile *.cnf set filetype=dosini

" inspired by https://nvie.com/posts/how-i-boosted-my-vim/
set hidden
set ignorecase
set smartcase
set hlsearch
set incsearch
set history=1000         " remember more commands and search history
set undolevels=1000      " use many muchos levels of undo
set title                " change the terminal's title
set nobackup

" prevent double spaces when using e.g. gq
" https://stackoverflow.com/a/4760477
set nojoinspaces

" do not lose selection after indenting and deindenting
" https://vim.fandom.com/wiki/Shifting_blocks_visually
vnoremap > >gv
vnoremap < <gv
" do not lose selection after deleting a block
vnoremap x xgv
