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
    USB_MBR | USB_GPT | USB_Hybrid )
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
        if ! grub-install --target=i386-pc --recheck $SD; then
            echo_err "grub-install"
            exit 1
        fi
        ;;
    USB_GPT | GPT)
        if ! grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub --removable --recheck; then
            echo_err "grub-install"
            exit 1
        fi
        ;;
    USB_Hybrid)
        if ! {
            echo_info "install efi" &&
            grub-install --target=x86_64-efi --efi-directory=/efi --boot-directory=/boot --removable --recheck &&
            echo_info "install bios_grub" &&
            grub-install --target=i386-pc --boot-directory=/boot --recheck $SD
        }; then
            echo_err "grub-install"
            exit 1
        fi
        ;;
    *)
        echo_err "unknown partition mode"
        exit 1
        ;;
esac
case $VIRTUAL_MACHINE in
    Hyper-V )
        if ! sed -i 's/^\(GRUB_CMDLINE_LINUX_DEFAULT="\)\(.*\)"$/\1\2 video=hyperv_fb:'$VIRTUAL_MACHINE_RESOLUTION_RATIO'"/g' /etc/default/grub; then
            echo_err "grub config for $VIRTUAL_MACHINE"
            exit 1
        fi
        ;;
    Virtual-Box )
        # load mod: vboxguest vboxsf vboxvideo
        if ! sed -i 's/^\(GRUB_PRELOAD_MODULES="\)\(.*\)"$/\1\2 vboxguest vboxsf vboxvideo"/g' /etc/default/grub; then
            echo_err "grub config for $VIRTUAL_MACHINE"
            exit 1
        fi
        ;;
esac
if ! echo 'GRUB_FORCE_HIDDEN_MENU="true"' >> /etc/default/grub; then
    echo_err "grub config"
    exit 1
fi
if ! grub-mkconfig -o /boot/grub/grub.cfg; then
    echo_err "grub-mkconfig"
    exit 1
fi
echo_finish "grub-install and grub-mkconfig"

echo_start "pacman"
INSTALL_PACKAGES=(zsh sudo vim vimpager git openssh networkmanager net-tools gnu-netcat tmux htop ranger moc mplayer wget ctags yaourt rsync cmake clang python-pip tree proxychains ntfs-3g alsa-utils)

#for X
INSTALL_PACKAGES+=(xorg-server xorg-xinit rxvt-unicode i3-gaps i3lock feh conky fcitx fcitx-table-extra fcitx-configtool fcitx-gtk2 fcitx-gtk3 fcitx-qt4 fcitx-qt5 google-chrome dmenu otf-font-awesome compton qtcreator netease-cloud-music youdao-dict)

case $VIRTUAL_MACHINE in
    Hyper-V )
        INSTALL_PACKAGES+=(xf86-video-fbdev)
        ;;
    VMWare )
        INSTALL_PACKAGES+=(xf86-input-vmmouse xf86-video-vmware)
        ;;
    * )
        INSTALL_PACKAGES+=(xf86-video-vesa)
        ;;
esac
case $VIRTUAL_MACHINE in
    Virtual-Box )
        INSTALL_PACKAGES+=(virtualbox-guest-modules-arch virtualbox-guest-utils)
        ;;
    VMWare )
        INSTALL_PACKAGES+=(open-vm-tools)
        ;;
esac
if ! {
    pacman -Syu &&
    pacman -S ${INSTALL_PACKAGES[@]} --noconfirm
}; then
    echo_err "pacman"
    exit 1
fi
echo "source \$VIM/vimrc" >> /etc/vimrc
echo_finish "pacman"

echo_start "pip"
if ! pip install future frozendict requests certifi; then
    echo_err "pip"
    exit 1
fi
ecno_end "pip"

echo_start "useradd"
if ! useradd -m -g users -G wheel -s /bin/zsh mewiteor; then
    echo_err "useradd"
    exit 1
fi
echo_finish "useradd"

echo_start "set sudo"
echo "mewiteor ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo_finish "set sudo"

echo_start "systemctl"
services=(NetworkManager sshd)
case $VIRTUAL_MACHINE in
    Virtual-Box )
        services+=(vboxservice.service)
        ;;
    VMWare )
        services+=(vmtoolsd.service vmware-vmblock-fuse.service)
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
    rsync -avP /root/tmp/echo_config /home/mewiteor/echo_config &&
    rsync -avP /root/tmp/mew_install.sh /home/mewiteor/mew.sh &&
    chown mewiteor:users /home/mewiteor/mew.sh &&
    chmod u+x /home/mewiteor/mew.sh &&
    rsync -avP --exclude "*.un~" /root/tmp/system/. / &&
    pushd /usr/share/vim/vimfiles/init &&
    bash bootstrap.sh &&
    popd &&
    rsync -avP --exclude "*.un~"  /root/tmp/user/. /home/mewiteor &&
    mkdir -p /home/mewiteor/.local/share &&
    rsync -avP --exclude "*.un~"  /root/tmp/fonts /home/mewiteor/.local/share &&
    for file in $(find /home/mewiteor -iname "*.m4"); do
        if ! m4 -DVIRTUAL_MACHINE=$VIRTUAL_MACHINE $file > ${file%.*}; then
            echo_err "m4 $file"
            exit 1
        else
            rm -f $file
        fi
    done &&
    chown -R mewiteor:users /home/mewiteor &&
    yes q | passwd mewiteor &&
    su mewiteor -c /home/mewiteor/mew.sh &&
    rm /home/mewiteor/mew.sh &&
    rm /home/mewiteor/echo_config
}; then
    echo_err "su"
    exit 1
fi
echo_finish "su"

exit 0
