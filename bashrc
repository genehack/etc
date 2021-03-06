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

for PKG in ctags emacs git node python ruby subversion tig tmux vim ImageMagick; do
    pathadd "/opt/$PKG/bin" "fore"
done

if [ -e /opt/scala ]; then
    export SCALA_HOME=/opt/scala
    pathadd "$SCALA_HOME/bin" "fore"
    pathadd "/opt/sbt/bin" "fore"
fi

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
        if [ -e ~/.ssh/id_rsa ]; then
            keychain -q ~/.ssh/id_rsa 2>/dev/null
        fi
        if [ -e ~/.keychain/${HOSTNAME}-sh ]; then
            . ~/.keychain/${HOSTNAME}-sh > /dev/null
        fi
    fi
fi

[[ -r "$HOME/.smartcd_config" ]] && source ~/.smartcd_config

# next three ganked from <http://muness.blogspot.com/2008/06/stop-presses-bash-said-to-embrace.html>
sub_dir() {
    local sub_dir
    sub_dir=$(stat --printf="%n" "${PWD}")
    sub_dir=${sub_dir#$1}
    echo ${sub_dir#/}
}

git_prompt_status() {
    INDEX=$(git status --porcelain 2> /dev/null)
    STATUS=""
    if $(echo "$INDEX" | grep '^?? ' &> /dev/null); then
        STATUS="$(color blue)✭$(color off)"
    fi
    if $(echo "$INDEX" | grep '^A  ' &> /dev/null); then
        STATUS="$(color green)✚$(color off)$STATUS"
    elif $(echo "$INDEX" | grep '^M  ' &> /dev/null); then
        STATUS="$(color green)✚$(color off)$STATUS"
    fi
    if $(echo "$INDEX" | grep '^ M ' &> /dev/null); then
        STATUS="$(color yellow)✹$(color off)$STATUS"
    elif $(echo "$INDEX" | grep '^AM ' &> /dev/null); then
        STATUS="$(color yellow)✹$(color off)$STATUS"
    elif $(echo "$INDEX" | grep '^ T ' &> /dev/null); then
        STATUS="$(color yellow)✹$(color off)$STATUS"
    fi
    if $(echo "$INDEX" | grep '^R  ' &> /dev/null); then
        STATUS="$(color white)➜$(color off)$STATUS"
    fi
    if $(echo "$INDEX" | grep '^ D ' &> /dev/null); then
        STATUS="$(color red)✖$(color off)$STATUS"
    elif $(echo "$INDEX" | grep '^AD ' &> /dev/null); then
        STATUS="$(color red)✖$(color off)$STATUS"
    fi
    if $(echo "$INDEX" | grep '^UU ' &> /dev/null); then
        STATUS="$(color magenta)═$(color off)$STATUS"
    fi
    CHERRY=$(git cherry 2> /dev/null)
    if [ -n "$CHERRY" ]; then
        STATUS="$(color cyan)↑$(color off)$STATUS"
    fi
    STASH=$(git stash list 2> /dev/null | tail -n1)
    if [ -n "$STASH" ]; then
        STATUS="$(color red white)↓$(color off)$STATUS"
    fi

    echo $STATUS
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

    autostash alias cleanup="git fsck && git gc"
    autostash alias commit="git commit -s"
    autostash alias dc="d --cached"
    autostash alias l="git log"
    autostash alias lp="l -p"
    autostash alias lss="l --stat --summary"
    autostash alias newbranch="git checkout -b"
    autostash alias pull="git pull"
    autostash alias push="commit ; git push"
    autostash alias revert="git checkout"
}

svn_dir() {
    [ -d ".svn" ] || return 1
    base_dir="."
    while [ -d "$base_dir/../.svn" ]; do base_dir="$base_dir/.."; done
    base_dir=`cd $base_dir; pwd`
    sub_dir="/$(sub_dir "${base_dir}")"
    ref=$(svn info "$base_dir" | awk '/^URL/ { sub(".*/","",$0); r=$0 } /^Revision/ { sub("[^0-9]*","",$0); print r":"$0 }')
    vcs="svn"
    autostash alias pull="svn up"
    autostash alias commit="svn commit"
    autostash alias push="svn ci"
    autostash alias revert="svn revert"
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

  P4="\`if [ \$? -eq 0 ]; then echo $(color green)☺$(color off); else echo $(color red)☹ [ \$? ]$(color off); fi\`"

  # this next bit also ganked from http://muness.blogspot.com/2008/06/stop-presses-bash-said-to-embrace.html
  git_dir || svn_dir

  if [ -n "$vcs" ]; then
      autostash alias st="$vcs status"
      autostash alias d="$vcs diff"
      autostash alias up="pull"
      autostash alias cdb="cd $base_dir"
      base_dir="$(basename "${base_dir}")"
      working_on="$base_dir:"
      __vcs_ref="[$ref]"
      __vcs_sub_dir="${sub_dir}"
      P5="$(git_prompt_status)\[$(color bd)\]$__vcs_ref\[$(color off)\]\[$(color red)\]\[$(color off)\]<\[$(color yellow)\]$working_on$__vcs_sub_dir\[$(color off)\]>"
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

if [ -e $HOME/etc/dataprinter ]; then
    export DATAPRINTERRC="$HOME/etc/dataprinter";
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

if [ -e /opt/perl/etc/bashrc ]; then
    export PERLBREW_ROOT=/opt/perl
    source /opt/perl/etc/bashrc
elif [ -e /opt/perl/bin ]; then
    pathadd "/opt/perl/bin" "fore"
fi
