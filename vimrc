" General options
set nocompatible
set wrap
set softtabstop=2
set shiftwidth=2
set expandtab
set autoindent
set smartindent
set number
set autowrite
set autoread
set encoding=utf-8
set ruler
set showmode
set showcmd


filetype indent plugin on

" colors
syntax on
colorscheme advantage

autocmd BufWritePre *.pl,*.pm :%s/\s\+$//e
au BufNewFile,BufRead *.yaml,*.yml,*.pg so ~/.vim/yaml.vim
