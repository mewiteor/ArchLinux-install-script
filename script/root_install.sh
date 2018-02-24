#! /bin/bash

SD=$1
PARTITION_MODE=$2
VIRTUAL_MACHINE=$3

source /root/tmp/echo_config || exit 1
source /root/tmp/env_config || exit 1

echo_start "set hostname"
echo arch > /etc/hostname
echo_finish "set hostname"

echo_start "set locale"
if ! {
    sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen &&
    sed -i 's/#zh_CN.UTF-8/zh_CN.UTF-8/g' /etc/locale.gen
}; then
    echo_err "sed"
    exit 1
fi
if ! locale-gen; then
    echo_err "locale-gen"
    exit 1
fi
echo LANG=en_US.UTF-8 > /etc/locale.conf
echo_finish "set locale"

echo_start "set localtime"
if ! ln -sf /usr/share/zoneinfo/Asia/Chongqing /etc/localtime; then
    echo_err "ln"
    exit 1
fi
if ! hwclock --systohc --utc; then
    echo_err "hwclock"
    exit 1
fi
echo_finish "set localtime"

echo_start "create ramdisk"
case $PARTITION_MODE in
    USB_MBR | USB_GPT )
        if ! sed -i 's/^HOOKS=(\(.*\)udev \(.*\) block\(.*\))$/HOOKS=(\1udev block \2\3)/g' /etc/mkinitcpio.conf; then
            echo_err "change /etc/mkinitcpio.conf"
            exit 1
        fi
        ;;
esac
if ! mkinitcpio -p linux; then
    echo_err "mkinitcpio"
    exit 1
fi
echo_finish "create ramdisk"

echo_start "passwd"
if ! yes q | passwd; then
    echo_err "passwd"
    exit 1
fi
echo_finish "passwd"

echo_start "grub-install and grub-mkconfig"
GRUB_INSTALL_COMMAND=":"
case $PARTITION_MODE in
    USB_MBR | MBR | BtrFS)
        GRUB_INSTALL_COMMAND="grub-install --target=i386-pc --recheck $SD"
        ;;
    USB_GPT | GPT)
        GRUB_INSTALL_COMMAND="grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub --removable --recheck"
        ;;
    *)
        echo_err "unknown partition mode"
        exit 1
        ;;
esac
if ! $($GRUB_INSTALL_COMMAND); then
    echo_err "grub-install"
    exit 1
fi
case $VIRTUAL_MACHINE in
    Hyper-V )
        if ! sed -i 's/^\(GRUB_CMDLINE_LINUX_DEFAULT="\)\(.*\)"$/\1\2 video=hyperv_fb:'$VIRTUAL_MACHINE_RESOLUTION_RATIO'"/g' /etc/default/grub; then
            echo_err "grub config for $VIRTUAL_MACHINE"
            exit 1
        fi
        ;;
    Virtual-Box )
        # load mod: vboxguest vboxsf vboxvideo
        ;;
esac
if ! grub-mkconfig -o /boot/grub/grub.cfg; then
    echo_err "grub-mkconfig"
    exit 1
fi
echo_finish "grub-install and grub-mkconfig"

echo_start "pacman"
INSTALL_PACKAGES=(zsh sudo vim vimpager git openssh networkmanager net-tools gnu-netcat tmux htop ranger moc mplayer wget ctags yaourt)

#for X
INSTALL_PACKAGES+=(xorg-server xorg-xinit rxvt-unicode i3-gaps i3lock i3status feh conky fcitx fcitx-table-extra fcitx-configtool fcitx-gtk2 fcitx-gtk3 fcitx-qt4 fcitx-qt5 google-chrome dmenu otf-font-awesome compton)

case $VIRTUAL_MACHINE in
    Hyper-V )
        INSTALL_PACKAGES+=(xf86-video-fbdev)
        ;;
    * )
        INSTALL_PACKAGES+=(xf86-video-vesa)
        ;;
esac
case $VIRTUAL_MACHINE in
    Virtual-Box )
        INSTALL_PACKAGES+=(virtualbox-guest-utils)
        ;;
esac
if ! {
    pacman -Syu &&
    yes ' ' | pacman -S ${INSTALL_PACKAGES[@]}
}; then
    echo_err "pacman"
    exit 1
fi
mv /root/tmp/vimrc /etc/vimrc
echo_finish "pacman"

echo_start "useradd"
if ! useradd -m -g users -G wheel -s /bin/zsh mewiteor; then
    echo_err "useradd"
    exit 1
fi
echo_finish "useradd"

echo_start "set sudo"
echo "mewiteor ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo_finish "set sudo"

echo_start "Vundle"
if ! {
    git clone https://github.com/VundleVim/Vundle.vim.git /usr/share/vim/vimfiles/bundle/Vundle.vim &&
    vim -u /root/tmp/vrc "+BundleInstall" "+q" "+q" &&
    echo "hi Normal ctermbg=none" >> /usr/share/vim/vimfiles/bundle/molokai/colors/molokai.vim
    echo "hi LineNr ctermbg=none" >> /usr/share/vim/vimfiles/bundle/molokai/colors/molokai.vim
}; then
    echo_err "Vundle"
    echo "git clone https://github.com/VundleVim/Vundle.vim.git /usr/share/vim/vimfiles/bundle/Vundle.vim &&" > /root/todo
    echo 'vim -u /root/tmp/vrc "+BundleInstall" "+q" "+q"' >> /root/todo
else
    echo_finish "Vundle"
fi

echo_start "systemctl"
services=(NetworkManager sshd)
case $VIRTUAL_MACHINE in
    Virtual-Box )
        services+=(vboxservice.service)
        ;;
esac
for serv in ${services[@]}; do
    if ! {
        systemctl enable $serv &&
        systemctl start $serv
    }; then
        echo_err "systemctl $serv"
        exit 1
    fi
done
echo_finish "systemctl"

echo_start "su"
if ! {
    cp /root/tmp/echo_config /home/mewiteor/echo_config &&
    chown mewiteor:users /home/mewiteor/echo_config &&
    mv /root/tmp/mew_install.sh /home/mewiteor/mew.sh &&
    chown mewiteor:users /home/mewiteor/mew.sh &&
    chmod u+x /home/mewiteor/mew.sh &&
    mv /root/tmp/zshrc /home/mewiteor/zshrc &&
    chown mewiteor:users /home/mewiteor/zshrc &&
    mkdir -p /home/mewiteor/.config/i3 &&
    mkdir -p /home/mewiteor/.config/conky &&
    mkdir -p /home/mewiteor/.local/share/fonts &&
    mv /root/tmp/x/xinitrc /home/mewiteor/.xinitrc &&
    mv /root/tmp/x/config /home/mewiteor/.config/i3/config &&
    mv /root/tmp/x/conky-down.conf /home/mewiteor/.config/conky/conky-down.conf &&
    mv /root/tmp/x/conky-up.conf /home/mewiteor/.config/conky/conky-up.conf &&
    mv /root/tmp/x/conky-down.lua /home/mewiteor/.config/conky/conky-down.lua &&
    mv /root/tmp/x/conky-up.lua /home/mewiteor/.config/conky/conky-up.lua &&
    mv /root/tmp/x/Xresources /home/mewiteor/.Xresources &&
    mv /root/tmp/x/launch.sh /home/mewiteor/.config/i3/launch.sh &&
    mv /root/tmp/x/bg.png /home/mewiteor/.config/i3/bg.png &&
    mv /root/tmp/fonts/* /home/mewiteor/.local/share/fonts/ &&
    mv /root/tmp/gitconfig /home/mewiteor/.gitconfig &&
    mv /root/tmp/x/fcitx.tar.xz /home/mewiteor/fcitx.tar.xz &&
    chown mewiteor:users /home/mewiteor/.xinitrc &&
    chown -R mewiteor:users /home/mewiteor/.config &&
    chown -R mewiteor:users /home/mewiteor/.Xresources &&
    chown -R mewiteor:users /home/mewiteor/.local &&
    chown mewiteor:users /home/mewiteor/.gitconfig &&
    chmod u+x /home/mewiteor/.config/i3/launch.sh &&
    yes q | passwd mewiteor &&
    su mewiteor -c /home/mewiteor/mew.sh &&
    rm /home/mewiteor/mew.sh &&
    rm /home/mewiteor/echo_config &&
    rm /home/mewiteor/fcitx.tar.xz
}; then
    echo_err "su"
    exit 1
fi
echo_finish "su"

exit 0
