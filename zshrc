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
plugins=(cpanm npm nvm ssh-agent zsh-syntax-highlighting)
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
pathadd "/usr/local/bin" "fore"

for PKG in ctags drafter emacs git gitflow python rust ruby sml subversion tig tmux vim ImageMagick weechat znc; do
    pathadd "/opt/$PKG/bin" "fore"
done

PG_PATH="/Applications/Postgres.app/Contents/Versions/latest/bin"
if [ -e $PG_PATH ]; then
    pathadd "$PG_PATH"
fi

if [ -e /opt/go ]; then
    export GOROOT=/opt/go
    if [ -e $HOME/proj/go ]; then
        export GOPATH=$HOME/proj/go
        pathadd "$GOPATH/bin"
    fi
    pathadd "$GOROOT/bin" "fore"
fi

export NVM_DIR="/opt/nvm"

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
    pathadd "/Library/Frameworks/Mono.framework/Versions/Current/Commands"
fi

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
            keychain -q ~/.ssh/id_rsa ~/.ssh/id_ecdsa 2>/dev/null
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
    pathadd "$PLENV_ROOT/bin" "fore"
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

# Setup fzf path (for Macs with fzf via homebrew)
if [ -e /usr/local/opt/fzf ]; then
    pathadd "/usr/local/opt/fzf/bin/"

    ## FZF
    export FZF_DEFAULT_COMMAND='ag --nocolor -g ""'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_DEFAULT_OPTS='
  --color fg:242,bg:236,hl:65,fg+:15,bg+:239,hl+:108
  --color info:108,prompt:109,spinner:108,pointer:168,marker:168
  '

    # Auto-completion
    [[ $- == *i* ]] && source "/usr/local/opt/fzf/shell/completion.zsh" 2> /dev/null

    # Key bindings
    source "/usr/local/opt/fzf/shell/key-bindings.zsh"
fi
