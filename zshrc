# Path to your oh-my-zsh configuration.
ZSH=$HOME/src/oh-my-zsh

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(cpanm git osx perl ssh-agent)

COMPLETION_WAITING_DOTS="true"
ZSH_THEME="sunrise"

OS=`uname`
if [ $OS = 'Linux' ];     then export OS_TYPE='linux'
elif [ $OS = 'Darwin' ];  then export OS_TYPE='darwin'
elif [ $OS = 'FreeBSD' ]; then export OS_TYPE='freebsd'
else                           export OS_TYPE='UNKNOWN'
fi

if [ -e $HOME/.aliases ]; then . $HOME/.aliases; fi

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

export LC_ALL=en_US.UTF-8
export RI='-f ansi'

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
    if [[ -d $1 && ${path[(i)$1]} -gt ${#path} ]]; then
        if [ "$2" ] && [ "$2" = "fore" ]; then
            PATH="$1:$PATH"
        else
            PATH="$PATH:$1"
        fi
    fi
}

source $ZSH/oh-my-zsh.sh

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

export ALTERNATE_EDITOR=""
export EDITOR="e"
export GIT_EDITOR="e"
export VISUAL="e"

## KEYCHAIN
if [[ $0 == -* ]]; then
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


[[ -r "$HOME/.smartcd_config" ]] && source ~/.smartcd_config

chpwd () {
    if [[ -d .git ]]; then
        autostash alias st="git status"
        autostash alias d="git diff"
        autostash alias up="pull"
        autostash alias cdb="cd $PWD"
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
    fi
}
