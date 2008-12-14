# -*- sh -*-
 
# how bash decides which config files to read, from the INVOCATION
# section of the bash(1) man page:

## When  bash is invoked as an interactive login shell, or as a non-inter-
## active shell with the --login option, it first reads and executes  com-
## mands  from  the file /etc/profile, if that file exists.  After reading
## that file, it looks for ~/.bash_profile, ~/.bash_login, and ~/.profile,
## in  that order, and reads and executes commands from the first one that
## exists and is readable.  The --noprofile option may be  used  when  the
## shell is started to inhibit this behavior.
##
## ...
##
## When an interactive shell that is not a login shell  is  started,  bash
## reads  and executes commands from ~/.bashrc, if that file exists.  This
## may be inhibited by using the --norc option.  The --rcfile file  option
## will  force  bash  to  read  and  execute commands from file instead of
## ~/.bashrc.

# so, therefore, in order to ensure that all interactive shells (login
# or no) get the same setup, we put _all_ the setup in .bashrc and
# have a .bash_profile that _only_ sources .bashrc.

### *** SO DON'T PUT ANYTHING ELSE HERE, BOZO!!!! *** ####

if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

