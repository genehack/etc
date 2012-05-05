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

    # work around for Snow Leopard xterm bug
    # <http://discussions.apple.com/thread.jspa?threadID=2148278&tstart=0>
    resize >& /dev/null

    # there's some oddness with the default PATH on macs...
    PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/X11/bin"
else
    export HOSTNAME=`hostname`
    export DOMAIN=`hostname -d`
    export FULL_HOSTNAME=`hostname -f`
fi

case $TERM in
    xterm)
        if [ ! $( infocmp xterm-256color>/dev/null 2>/dev/null ) ]; then
            export TERM=xterm-256color
        fi
        ;;
    screen)
        if [ ! $( infocmp screen-256color>/dev/null 2>/dev/null ) ]; then
            export TERM=screen-256color
        fi
        ;;
esac

if [ -e $HOME/.bash_private ]; then . $HOME/.bash_private; fi

# ganked from http://superuser.com/questions/39751/
pathadd() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        if [ "$2" ] && [ "$2" == "fore" ]; then
            PATH="$1:$PATH"
        else
            PATH="$PATH:$1"
        fi
    fi
}

set_up_bash_completion () {
    # Check for bash (and that we haven't already been sourced).
    [ -z "$BASH_VERSION" -o -n "$BASH_COMPLETION" ] && return;

    # Check for recent enough version of bash.
    bash=${BASH_VERSION%.*}; bmajor=${bash%.*}; bminor=${bash#*.}

    if [ -n "$PS1" ]; then
        if [ $bmajor -eq 2 -a $bminor '>' 04 ] || [ $bmajor -gt 2 ]; then
            if [ -e /etc/bash_completion ]; then
                . /etc/bash_completion;
            elif [ -e $HOME/etc/bash_completion ]; then
                . $HOME/etc/bash_completion;
            fi
        fi
    fi
}

set_up_bash_completion;
if [ -d $HOME/etc/bash_completion.d ]; then
    for i in `ls $HOME/etc/bash_completion.d`; do
        source $HOME/etc/bash_completion.d/$i
    done
fi

if [ -e $HOME/.aliases ]; then . $HOME/.aliases; fi

pathadd "/opt/local/bin" "fore"

for PKG in ctags emacs git node perl python ruby scala subversion tig tmux vim ImageMagick; do
    pathadd "/opt/$PKG/bin" "fore"
done

pathadd "$HOME/local/bin"
if [ -e $HOME/local/man ]; then MANPATH=$HOME/local/man:$MANPATH; fi

pathadd "$HOME/bin" "fore"
if [ -e $HOME/man ]; then MANPATH=$HOME/man:$MANPATH; fi

if [ -e $HOME/proj/git-achievements ]; then
    pathadd "$HOME/proj/git-achievements"
    alias git="git-achievements"
fi

export PERL_CPANM_OPT="--skip-installed --prompt"

# bashcomp for cpanm (<http://blog.netcubed.de/2011/02/bash-completion-for-cpanm-and-cpanf/>)
if [ $(which setup-bash-complete) ]; then
    source setup-bash-complete
fi

# 'e' lives in my emacs repo
export ALTERNATE_EDITOR=""
export EDITOR="e"
export GIT_EDITOR="e"
export VISUAL="e"

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

# from https://gist.github.com/1182950
function parse_git_stash {
    [[ $(git stash list 2> /dev/null | tail -n1) != "" ]] && echo " {STASH} "
}

setprompt() {
  local load etc vcs base_dir sub_dir ref last_command

  P1="\[{$(color yellow)\]\T\[$(color off)}\]"
  P2="\[($(color green)\]$HOSTNAME\[$(color off))\]"

  if [ -e /proc/loadavg ]; then
      load=( $(</proc/loadavg) )
  else
      load=""
  fi

  P3=""
  if [ $load ]; then
      if [ ${load%.*} -ge 2 ]; then
	  P3="\[[$(color red white)\]$load\[$(color off)\]]"
      else
	  P3="\[[$(color ltblue)\]$load\[$(color off)\]]"
      fi
  fi

  P4="-\[$(color red)\]\$?\[$(color off)\]-"

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
      P5="\[$(color bd)\]$__vcs_ref\[$(color off)\]\[$(color red)\]$(parse_git_stash)\[$(color off)\]<\[$(color yellow)\]$working_on$__vcs_sub_dir\[$(color off)\]>"
  else
      P5="<\[$(color yellow)\]\w\[$(color off)\]>"
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
export LC_ALL=en_US.UTF-8
export RI='-f ansi'

shopt -s cdspell
shopt -s dotglob
shopt -s no_empty_cmd_completion

t() {
    TMUX=`which tmux`
    TMUX_ID="working"
    TMUX_OPTS=""

    if [ -z $TMUX ]; then
        echo "tmux not in PATH, sorry."
        exit 1
    fi

    $($TMUX has -t $TMUX_ID 2>/dev/null)
    if [ $? = 1 ]; then
        $TMUX $TMUX_OPTS new -s $TMUX_ID
    else
        $TMUX attach -d -t $TMUX_ID
    fi

}

working-screen() {
    echo "use t instead!"
}

v() {
  mod_file="lib/${1//:://}.pm"
  if [ -f $mod_file ]; then
    command vim $mod_file
  else
    mod_file="t/$mod_file"
    if [ -f $mod_file ]; then
      command vim $mod_file
    else
      mod_file=$(perldoc -l $1 | sed 's/pod$/pm/')
      if [ -f $mod_file ]; then
        command vim $mod_file
      else
        command vim $@
      fi
    fi
  fi
}
