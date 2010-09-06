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

