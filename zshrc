# -*- sh -*-
# Path to your oh-my-zsh configuration.
ZSH=$HOME/src/oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="kolo"
COMPLETION_WAITING_DOTS="true"
plugins=(cpanm git ssh-agent)
zstyle :omz:plugins:ssh-agent agent-forwarding on


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

# ganked from http://superuser.com/questions/39751/
pathadd() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        if [ "$2" ] && [[ "$2" == "fore" ]]; then
            PATH="$1:$PATH"
        else
            PATH="$PATH:$1"
        fi
    fi
}

if [ -e $HOME/.aliases ]; then source $HOME/.aliases; fi

source $ZSH/oh-my-zsh.sh

pathadd "/opt/local/bin" "fore"

for PKG in ctags emacs git node perl python ruby subversion tig tmux vim ImageMagick; do
    pathadd "/opt/$PKG/bin" "fore"
done

if [ -e /opt/scala ]; then
    export SCALA_HOME=/opt/scala
    pathadd "$SCALA_HOME/bin" "fore"
    pathadd "/opt/sbt" "fore"
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

# 'e' lives in my emacs repo
export ALTERNATE_EDITOR=""
export EDITOR="e"
export GIT_EDITOR="e"
export VISUAL="e"

## KEYCHAIN
# if shopt -q login_shell ; then
#     `which keychain 2>&1 >/dev/null`
#     if [ $? = 0 ]; then
#         if [ -e ~/.ssh/id_dsa ]; then
#             keychain -q ~/.ssh/id_dsa 2>/dev/null
#         fi
#         if [ -e ~/.keychain/${HOSTNAME}-sh ]; then
#             . ~/.keychain/${HOSTNAME}-sh > /dev/null
#         fi
#     fi
# fi

### FIXME this puts zsh into somesort of recursive subshell tailspin
#[[ -r "$HOME/.smartcd_config" ]] && source ~/.smartcd_config
alias st="git status"
alias d="git diff"
alias up="pull"
alias cdb="cd __PATH__"
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
### FIXME remove the above aliases once you fix the smartcd issue...

#export LC_ALL=en_US.UTF-8

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

