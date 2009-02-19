# -*- sh -*-
gnome-settings-daemon &

xmodmap /home/genehack/.Xmodmap &
setxkbmap -option "ctrl:nocaps" &
emacs --daemon
/home/genehack/bin/run-conky &
stalonetray &
gnome-do &
/home/genehack/bin/rotate-backdrop
exec /opt/awesome/bin/awesome

#export LD_LIBRARY_PATH=/opt/awesome-3.1.1/lib
#exec /opt/awesome-3.1.1/bin/awesome

