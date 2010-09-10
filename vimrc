" General options
set nocompatible      " vim should be vim
set wrap              " softwrap text
set softtabstop=2     " 2 space tabs!
set shiftwidth=2      " we mean it!
set expandtab         " and spaces only!
set number            " show linenumbers
set autowrite         " autosave, most times
set autoread          " autoread
set encoding=utf-8    " it's a UTF-8 world
set ruler             " show line/col in status line
set showcmd           " show partial command in status line
set smarttab          " be smart about <TAB> at BOL
set fileformats=unix,mac,dos
set history=5000
set hlsearch
set incsearch
set showmatch


set autoindent       " indent
set smartindent
filetype indent plugin on

" colors
syntax on
colorscheme advantage
set bg=dark

" folding configuration
set foldmethod=marker
set nofoldenable

" This is for winmanager
map <F1> :WMToggle<CR>

" This is for taglist
let Tlist_Inc_Winwidth = 0
map <F3> :Tlist<CR>

" Use perl compiler for all *.pl and *.pm files.
autocmd BufNewFile,BufRead *.p? compiler perl

autocmd BufWritePre *.pl,*.pm :%s/\s\+$//e
au BufNewFile,BufRead *.yaml,*.yml,*.pg so ~/.vim/yaml.vim

" This is for perldoc.vim
autocmd BufNewFile,BufRead *.p? map <F1> :Perldoc<cword><CR>
autocmd BufNewFile,BufRead *.p? setf perl
autocmd BufNewFile,BufRead *.p? let g:perldoc_program='/usr/bin/perldoc'
"autocmd BufNewFile,BufRead *.p? source /home/genehack/.vim/ftplugin/perl_doc.vim

" perl test files
au BufRead,BufNewFile *.t setfiletype=perl

" syntax check on save
autocmd BufWritePost *.pl !perl -c %

autocmd FileType perl setlocal foldmarker={,}

" from http://blogs.perl.org/users/steffen_mueller/2010/08/tiny-vim-convenience-hack.html
perl << EOS
use Text::FindIndent;
sub FindIndent {
  my @cmd = do {
    my $doc = join "\n", $curbuf->Get( 1 .. $curbuf->Count );
    Text::FindIndent->to_vim_commands( $doc );
  };
  for ( @cmd ) {
    s{:set\b}{:setlocal};
    VIM::DoCommand $_;
  }
}
EOS
autocmd FileType perl :perl FindIndent()

set tags+=~/.ptags

" highlight lines longer than 80 chars in perl files
autocmd FileType perl match ErrorMsg '\%>80v.\+'

" automatically source the .vimrc file if I change it
" the bang (!) forces it to overwrite this command rather than stack it
au! BufWritePost .vimrc source %

" modified from http://groups.google.com/group/vim-perl/browse_thread/thread/41bf2594911b3f51
let $VIMRC = "$HOME/.vimrc"
map ,v :tabe $VIMRC<CR>
map <silent> ,V :source $VIMRC<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR>

" http://vim.wikia.com/wiki/VimTip306
function! HandleURI()
  let s:uri = matchstr(getline("."), '[a-z]*:\/\/[^ >,;:]*')
  echo s:uri
  if s:uri != ""
	  exec "!open \"" . s:uri . "\""
  else
	  echo "No URI found in line."
  endif
endfunction
map <Leader>w :call HandleURI()<CR>

" Use the below highlight group when displaying bad whitespace is desired.
highlight BadWhitespace ctermbg=red guibg=red

" Make trailing whitespace be flagged as bad.
au BufRead,BufNewFile *.p?,*.t match BadWhitespace /\s\+$/

au BufNewFile *.p?,*.t set fileformat=unix

let perl_include_pod=1
let perl_extended_vars=1
let perl_want_scope_in_variables=1

function! InsertTabWrapper()
  let col = col('.') - 1
  if !col || getline('.')[col - 1] !~ '\k'
    return "\<Tab>"
  else
    return "\<C-O>"
  endif
endfunction
inoremap <tab> <C-X><C-R>=InsertTabWrapper()<CR>

" save keystrokes on the Perl shebang
iabbrev #!p #!/opt/perl/bin/perl<C-M><BS><C-M>use strict;<C-M>use warnings;<C-M><ESC>:filetype detect<C-M>i

map <F9> :wincmd gf<CR>
