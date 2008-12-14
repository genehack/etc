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
fi


if [ -e $HOME/.bash_private ]; then . $HOME/.bash_private; fi

if [ -e /etc/bash_completion ]; then . /etc/bash_completion; fi

if [ -e $HOME/.aliases ]; then . $HOME/.aliases; fi

export EDITOR=/opt/emacs/bin/emacsclient
export GIT_EDITOR=vim
export VISUAL=/opt/emacs/bin/emacsclient

if [ -d /opt/local/bin ]; then
    export PATH=/opt/local/bin:$PATH
fi

if [ -e /opt/perl/bin ];          then export PATH=/opt/perl/bin:$PATH
elif [ -e /opt/local/perl/bin ];  then export PATH=/opt/local/perl/bin:$PATH
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

setprompt() {
  local load etc

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

  P5="<$(color yellow)\w$(color off)>"

  PS1="\n$P1 $P2 $P3 $P4\n$P5 \$ "
}

if [ $OS_TYPE = 'darwin' ]; then
	setprompt
elif [ $TERM = 'dumb' ]; then
    PS1='\n{\T} (\h) -$?-\n<\w> $ '
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

