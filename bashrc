# -*- sh -*-

if [ -f /etc/bashrc ]; then . /etc/bashrc; fi

OS=`uname`
if [ $OS = 'Linux' ];     then export OS_TYPE='linux'
elif [ $OS = 'Darwin' ];  then export OS_TYPE='darwin'
elif [ $OS = 'FreeBSD' ]; then export OS_TYPE='freebsd'
else                           export OS_TYPE='UNKNOWN'
fi

if [ $OS_TYPE = 'darwin' -o $OS_TYPE = 'freebsd' ]; then
    export HOSTNAME=`/bin/hostname -s`
    export DOMAIN=`/bin/hostname | cut -f2- -d.`
    export FULL_HOSTNAME=`/bin/hostname`
else
    export HOSTNAME=`hostname`
    export DOMAIN=`hostname -d`
    export FULL_HOSTNAME=`hostname -f`
    if [ $TERM != 'dumb' ]; then export TERM=xterm-256color; fi
fi


if [ -e $HOME/.bash_private ]; then . $HOME/.bash_private; fi

if [ -e /etc/bash_completion ]; then . /etc/bash_completion; fi

if [ -e $HOME/.aliases ]; then . $HOME/.aliases; fi

if [ -d /opt/local/bin ]; then
    export PATH=/opt/local/bin:$PATH
fi

if [ -e /opt/local/perl/bin ];    then export PATH=/opt/local/perl/bin:$PATH
elif [ -e /opt/perl/bin ];        then export PATH=/opt/perl/bin:$PATH
elif [ -e /opt/perl/5.10.0/bin ]; then export PATH=/opt/perl/5.10.0/bin:$PATH
elif [ -e /opt/perl/5.8.8/bin ];  then export PATH=/opt/perl/5.8.8/bin:$PATH
fi


for PKG in awesome emacs git subversion ; do
    if [ -e /opt/$PKG ]; then
        export PATH=/opt/$PKG/bin:$PATH
    fi
done

if [ -e $HOME/local/bin ]; then export PATH=$HOME/local/bin:$PATH; fi
if [ -e $HOME/local/man ]; then export MANPATH=$HOME/local/man:$MANPATH; fi

if [ -e $HOME/bin ]; then export PATH=$HOME/bin:$PATH; fi
if [ -e $HOME/man ]; then export MANPATH=$HOME/man:$MANPATH; fi

if [ $OS_TYPE = 'darwin' ]; then
    EMACS='/Applications/Emacs.app/Contents/MacOS/Emacs'
    EMACSCLIENT='/Applications/Emacs.app/Contents/MacOS/bin/emacsclient'
else
    EMACS=`which emacs`
    EMACSCLIENT=`which emacsclient`
fi

export EDITOR="$EMACSCLIENT -t"
export GIT_EDITOR="$EMACSCLIENT -t"
export VISUAL="$EMACSCLIENT -t"

## KEYCHAIN 
if shopt -q login_shell ; then
    `which keychain 2>&1 >/dev/null`
    if [ $? = 0 ]; then
        if [ -e ~/.ssh/id_dsa ]; then
            keychain -q ~/.ssh/id_dsa 2>/dev/null
        fi
        if [ -e ~/.keychain/${HOSTNAME}-sh ]; then
            . ~/.keychain/${HOSTNAME}-sh > /dev/null
        fi
    fi
fi

# next three ganked from <http://muness.blogspot.com/2008/06/stop-presses-bash-said-to-embrace.html>
sub_dir() {
    local sub_dir
    sub_dir=$(stat --printf="%n" "${PWD}")
    sub_dir=${sub_dir#$1}
    echo ${sub_dir#/}
}

git_dir() {
    base_dir=$(git rev-parse --show-cdup 2>/dev/null) || return 1
    if [ -n "$base_dir" ]; then
	base_dir=`cd $base_dir; pwd`
    else
	base_dir=$PWD
    fi
    sub_dir=$(git rev-parse --show-prefix)
    sub_dir="/${sub_dir%/}"
    ref=$(git symbolic-ref -q HEAD || git name-rev --name-only HEAD 2>/dev/null)
    ref=${ref#refs/heads/}
    vcs="git"
    alias cleanup="git fsck && git gc"
    alias commit="git commit -s"
    alias dc="d --cached"
    alias l="git log"
    alias lp="l -p"
    alias lss="l --stat --summary"
    alias newbranch="git checkout -b"
    alias pull="git pull"
    alias push="commit ; git push"
    alias revert="git checkout"
}

svn_dir() {
    [ -d ".svn" ] || return 1
    base_dir="."
    while [ -d "$base_dir/../.svn" ]; do base_dir="$base_dir/.."; done
    base_dir=`cd $base_dir; pwd`
    sub_dir="/$(sub_dir "${base_dir}")"
    ref=$(svn info "$base_dir" | awk '/^URL/ { sub(".*/","",$0); r=$0 } /^Revision/ { sub("[^0-9]*","",$0); print r":"$0 }')
    vcs="svn"
    alias pull="svn up"
    alias commit="svn commit"
    alias push="svn ci"
    alias revert="svn revert"
}

setprompt() {
  local load etc vcs base_dir sub_dir ref last_command

  P1="{$(color yellow)\T$(color off)}"
  P2="($(color green)\h$(color off))"

  if [ -e /proc/loadavg ]; then
      load=( $(</proc/loadavg) )
  else
      load=""
  fi
  
  P3=""
  if [ $load ]; then 
      if [ ${load%.*} -ge 2 ]; then
	  P3="[$(color red white)$load$(color off)]"
      else
	  P3="[$(color ltblue)$load$(color off)]"
      fi
  fi
    
  P4="-$(color red)\$?$(color off)-"

  # this next bit also ganked from http://muness.blogspot.com/2008/06/stop-presses-bash-said-to-embrace.html
  git_dir || svn_dir

  if [ -n "$vcs" ]; then
      alias st="$vcs status"
      alias d="$vcs diff"
      alias up="pull"
      alias cdb="cd $base_dir"
      base_dir="$(basename "${base_dir}")"
      working_on="$base_dir:"
      __vcs_ref="[$ref]"
      __vcs_sub_dir="${sub_dir}"
      P5="$(color bd)$__vcs_ref$(color off)<$(color yellow)$working_on$__vcs_sub_dir$(color off)>"
  else
      P5="<$(color yellow)\w$(color off)>"
  fi

  PS1="\n$P1 $P2 $P3 $P4\n$P5 \$ "
}

if [ $TERM = 'dumb' ]; then
    PS1='$ '
else 
    PROMPT_COMMAND=setprompt
fi

export HISTFILESIZE=1000000000
export HISTIGNORE="&:ls:[bf]g:ext"
export HISTSIZE=1000000
export LC_ALL=POSIX
export RI='-f ansi'

shopt -s cdspell
shopt -s dotglob
shopt -s no_empty_cmd_completion

