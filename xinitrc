# $Id: xinitrc 851 2007-10-01 00:07:47Z genehack $
# $URL: svn+ssh://genehack.org/home/genehack/svn/svnhome/x-conf/etc/xinitrc $

## KEYMAP
#xmodmap /home/jacobs/lib/kmp/dvorak.keymap

## OpenGL options
#export __GL_FSSA_MDOE=2
#export __GL_LOG_MAX_ANISO=1

## DWM
#export PATH=$PATH:/opt/local/dwm-4.3/bin
#exec dwm

## KDE 
#export QT_XFT=1
#exec startkde

## GNOME
#export WINDOW_MANAGER="/usr/bin/metacity"
#exec gnome-session

### WINDOW MAKER
#exec wmaker

## ENLIGHTENMENT
#exec enlightenment
#exec /usr/bin/enlightenment-0.17

## XFCE4
#exec startxfce4

## RATPOISON
#exec ratpoison

## FVWM-CRYSTAL
#exec fvwm-crystal

## FLUXBOX
#exec fluxbox

## BLACKBOX
#exec blackbox
#

## OPENBOX
#exec openbox-session
#

## AWESOME
xmodmap /home/genehack/.Xmodmap &
setxkbmap -option "ctrl:nocaps" &
/home/genehack/bin/rotate-backdrop
/home/genehack/bin/run-conky &
exec /usr/local/bin/awesome
