# -*- sh -*-
### genehack .bashrc

# $Id$
# $URL$

## globals
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

## OS
OS=`uname`
if [ $OS = 'Linux' ]; then
    export OS_TYPE='linux'
elif [ $OS = 'Darwin' ]; then
    export OS_TYPE='darwin'
elif [ $OS = 'FreeBSD' ]; then
    export OS_TYPE='freebsd'
else
    export OS_TYPE='UNKNOWN'
fi

## $HOSTNAME 
if [ $OS_TYPE = 'darwin' -o $OS_TYPE = 'freebsd' ]; then
    export HOSTNAME=`/bin/hostname -s`
    export DOMAIN=`/bin/hostname | cut -f2- -d.`
    export FULL_HOSTNAME=`/bin/hostname`
else
    export HOSTNAME=`hostname`
    export DOMAIN=`hostname -d`
    export FULL_HOSTNAME=`hostname -f`
fi


## SET UP GENEHACK_LOCATION VARIABLE AND OTHER SECRET STUFF
if [ -e $HOME/.bash_private ]; then
    . $HOME/.bash_private
fi

## BASH COMPLETION
if [ -e /etc/bash_completion ]; then 
    . /etc/bash_completion; 
fi
if [ -e $HOME/.bash_completion.d ]; then
    for file in $HOME/.bash_completion.d/* ; do
        . $file
    done
fi


## ALIASES
if [ -e $HOME/.aliases ]; then
    . $HOME/.aliases
fi

## EDITORS
### FIXME should really get things to where these can be set to emacs...
export EDITOR=vim
export VISUAL=vim

## FETCHMAIL
#  if we're on a mail reading machine, set FETCHMAILHOME
if [ -e $HOME/private/fetchmailrc ]; then
    export FETCHMAILHOME=$HOME/private
fi

## FUNCTIONS
# ganked from <http://www.enigmacurry.com/2007/05/24/multi-tty-emacs-on-gentoo-and-ubuntu/>
SERVERNAME=genehack
start_emacs () {
    #Attempt to connect to an existing server
    emacsclient -s $SERVERNAME $*
    if [ $? -ne 0 ]; then
    #Start a new emacs server and connect
        preload_emacs $SERVERNAME 0
        emacsclient -s $SERVERNAME $*
    fi
}


## KEYCHAIN 
if shopt -q login_shell ; then
    `which keychain 2>&1 >/dev/null`
    if [ $? = 0 ]; then
#        if [ $GENEHACK_LOCATION = "HOME" ]; then
#     	    keychain -q B1CFBD6F  2>/dev/null
#        fi
        if [ -e ~/.keychain/${HOSTNAME}-sh-gpg ]; then
    	    . ~/.keychain/${HOSTNAME}-sh-gpg > /dev/null
            export GPG_TTY=`tty`
        fi
        
        if [ -e ~/.ssh/id_dsa ]; then
            keychain -q ~/.ssh/id_dsa 2>/dev/null
        fi
        if [ -e ~/.keychain/${HOSTNAME}-sh ]; then
            . ~/.keychain/${HOSTNAME}-sh > /dev/null
        fi
    fi
fi

## PATHS
if [ $GENEHACK_LOCATION = "LAPTOP" ]; then
    if [ -d /opt/local/bin ]; then
        export PATH=/opt/local/bin:$PATH
    fi
    if [ -e /opt/perl/5.8.8/bin ]; then
        export PATH=/opt/perl/5.8.8/bin:$PATH
    elif [ -e /opt/perl/5.10.0/bin ]; then
        export PATH=/opt/perl/5.10.0/bin:$PATH
    fi
fi
# stack things to get the right order: 
# start with system stuff
# /sw before system stuff
# ~/local before /sw
# ~/bin before ~/local
if [ -e /sw ]; then
    if [ -e /sw/bin ]; then
        export PATH=/sw/bin:$PATH
    fi
    if [ -e /sw/man ]; then
        export MANPATH=/sw/man:$MANPATH
    fi
fi
if [ -e $HOME/local ]; then
    if [ -e $HOME/local/bin ]; then
        export PATH=$HOME/local/bin:$PATH
    fi
    if [ -e $HOME/local/man ]; then
        export MANPATH=$HOME/local/man:$MANPATH
    fi
fi
if [ -e $HOME/bin ]; then
    export PATH=$HOME/bin:$PATH
fi
if [ -e $HOME/man ]; then
    export MANPATH=$HOME/man:$MANPATH
fi


## SET PROMPT
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

## SHELL OPTIONS
export HISTFILESIZE=1000000000
export HISTIGNORE="&:ls:[bf]g:ext"
export HISTSIZE=1000000
export LC_ALL=POSIX
export RI='-f ansi'
shopt -s cdspell
shopt -s dotglob
shopt -s no_empty_cmd_completion

