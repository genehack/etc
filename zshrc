# -*- sh -*-
# Path to your oh-my-zsh configuration.
ZSH=$HOME/proj/oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="genehack"
COMPLETION_WAITING_DOTS="true"
DISABLE_AUTO_TITLE="true"
plugins=(cpanm npm ssh-agent)
zstyle :omz:plugins:ssh-agent agent-forwarding on
setopt DVORAK

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

if [ -e $HOME/.zsh_private ]; then . $HOME/.zsh_private; fi

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

pathadd "/opt/local/bin" "fore"

for PKG in ctags emacs git python rust ruby sml subversion tig tmux vim ImageMagick weechat znc; do
    pathadd "/opt/$PKG/bin" "fore"
done

if [ -e /opt/go ]; then
    export GOROOT=/opt/go
    if [ -e $HOME/proj/go ]; then
        export GOPATH=$HOME/proj/go
        pathadd "$GOPATH/bin"
    fi
    pathadd "$GOROOT/bin" "fore"
fi

if [ -e /opt/nvm ]; then
    . /opt/nvm/nvm.sh
elif [ -e /opt/node ]; then
    pathadd "/opt/node/bin" "fore"
fi

if [ -e /opt/play ]; then
    pathadd "/opt/play" "fore"
fi
if [ -e /opt/scala ]; then
    export SCALA_HOME=/opt/scala
    pathadd "$SCALA_HOME/bin" "fore"
    pathadd "/opt/sbt/bin" "fore"
fi

if [ -e /opt/swift/usr/bin/ ]; then
    pathadd "/opt/swift/usr/bin"
fi

if [ -e /usr/local/share/dotnet ]; then
    export DOTNET_CLI_TELEMETRY_OPTOUT=1
    pathadd "/usr/local/share/dotnet"
fi

pathadd "$HOME/local/bin"
if [ -e $HOME/local/man ]; then MANPATH=$HOME/local/man:$MANPATH; fi

pathadd "$HOME/bin" "fore"
if [ -e $HOME/man ]; then MANPATH=$HOME/man:$MANPATH; fi

export PERL_CPANM_OPT="--skip-installed --prompt"
if [ -e $HOME/etc/dataprinter ]; then export DATAPRINTERRC=$HOME/etc/dataprinter; fi

# 'e' lives in my emacs repo
export ALTERNATE_EDITOR=""
export EDITOR="e"
export GIT_EDITOR="e"
export VISUAL="e"

## KEYCHAIN
if [[ $- == *l* ]]; then
    `which keychain 2>&1 >/dev/null`
    if [ $? = 0 ]; then
        if [ -e ~/.ssh/id_rsa ]; then
            keychain -q ~/.ssh/id_rsa 2>/dev/null
        fi
        if [ -e ~/.ssh/id_ecdsa ]; then
            keychain -q ~/.ssh/id_ecdsa 2>/dev/null
        fi
        if [ -e ~/.keychain/${HOSTNAME}-sh ]; then
            . ~/.keychain/${HOSTNAME}-sh > /dev/null
        fi
    fi
fi

[[ -r "$HOME/.smartcd_config" ]] && source ~/.smartcd_config

export LC_ALL=en_US.UTF-8

# start up dropbox on Linux hosts that have it installed
if [ -e $HOME/Dropbox ] && [ $OS_TYPE = 'linux' ]; then
    $(dropbox running)
    if [[ $? == 0 ]]; then
        dropbox start
    fi
fi

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

source $ZSH/oh-my-zsh.sh

if [ -e $HOME/.aliases ]; then . $HOME/.aliases; fi

# perl environment
if [ -e /opt/plenv ]; then
    export PLENV_ROOT=/opt/plenv
    export PATH="$PLENV_ROOT/bin:$PATH"
    eval "$(plenv init -)"
elif [ -e /opt/perl/etc/bashrc ]; then
    export PERLBREW_ROOT=/opt/perl
    source /opt/perl/etc/bashrc
elif [ -e /opt/perl/bin ]; then
    pathadd "/opt/perl/bin" "fore"
fi

cpanm () {
    command cpanm $@;
    cpanm-reporter;
}

of() {
    if [ $OS_TYPE = 'darwin' ]; then
        osascript <<EOT
      tell application "OmniFocus"
        parse tasks into default document with transport text "$@"
      end tell
EOT
    else
        echo "Only works on Mac!"
    fi
}

