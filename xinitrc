# -*- sh -*-
gnome-settings-daemon &

xmodmap /home/genehack/.Xmodmap &
setxkbmap -option "ctrl:nocaps" &
/home/genehack/bin/rotate-backdrop
#/home/genehack/local/bin/emacs --daemon
#/home/genehack/bin/run-conky &
#exec /opt/awesome/bin/awesome

export LD_LIBRARY_PATH=/opt/awesome-3.1.1/lib
exec /opt/awesome-3.1.1/bin/awesome

