divert(-1)
divert(0)dnl
#!/bin/sh
# cvt 1920 1080|grep "^[^#]"|sed -e 's/Modeline //g'|xargs xrandr --newmode
# xrandr --addmode VGA-0 1920x1080_60.00
# xrandr --output VGA-0 --mode 1920x1080_60.00
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export LANG="zh_CN.UTF-8"
xrdb -merge ~/.Xresources
ifdef(`VIRTUAL_MACHINE',exec compton ifelse(VIRTUAL_MACHINE,`Virtual-Box',--shadow-exclude 'class_g = "VirtualBox" && name = "VirtualBox" && bounding_shaped && (_NET_WM_STATE@[0]:a = "_NET_WM_STATE_MAXIMIZED_VERT" && _NET_WM_STATE@[1]:a = "_NET_WM_STATE_MAXIMIZED_HORZ" || _NET_WM_STATE@[0]:a = "_NET_WM_STATE_MAXIMIZED_HORZ" && _NET_WM_STATE@[1]:a = "_NET_WM_STATE_MAXIMIZED_VERT") && _NET_WM_WINDOW_TYPE@[0]:a = "_KDE_NET_WM_WINDOW_TYPE_OVERRIDE"' , -CGb) &)
exec fcitx&
exec VBoxClient-all&
exec i3
