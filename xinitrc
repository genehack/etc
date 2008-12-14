# -*- sh -*-

xmodmap /home/genehack/.Xmodmap &
setxkbmap -option "ctrl:nocaps" &
/home/genehack/bin/rotate-backdrop
/home/genehack/local/bin/emacs --daemon
/home/genehack/bin/run-conky &
exec /opt/awesome/bin/awesome
