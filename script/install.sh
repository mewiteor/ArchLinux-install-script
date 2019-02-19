#! /bin/bash

SD=$1
PARTITION_MODE=$2
VIRTUAL_MACHINE=$3

source ../config/echo_config || exit 1
source ../config/env_config || exit 1

function umount
{
    echo_start "umount"
    if ! ./umount.sh $SD $PARTITION_MODE; then
        echo_err "umount"
        exit 1
    fi
    echo_finish "umount"
}

umount

if ! ./partition.sh $SD $PARTITION_MODE; then
    echo_err "mount"
    umount
    exit 1
fi

echo_start "make mirrors"
install_reflector () {
    # wget -O /tmp/reflector.tar.xz https://xyne.archlinux.ca/projects/reflector/src/reflector-${1}.tar.xz || return 1
    # wget -O /tmp/reflector.tar.xz.sig https://xyne.archlinux.ca/projects/reflector/src/reflector-${1}.tar.xz.sig || return 1
    # if ! gpg --verify /tmp/reflector.tar.xz.sig /tmp/reflector.tar.xz; then
    #     local key=$(gpg --verify /tmp/reflector.tar.xz.sig /tmp/reflector.tar.xz 2>&1 | grep "RSA key" | awk  '{print $NF}') || return 1
    #     gpg --recv-keys $key || return 1
    # fi
    # gpg --verify /tmp/reflector.tar.xz.sig /tmp/reflector.tar.xz || return 1
    # rm -rf /tmp/reflector || return 1
    # mkdir -p /tmp/reflector || return 1
    # tar xpf /tmp/reflector.tar.xz -C /tmp/reflector --strip 1 || return 1
    # pushd /tmp/reflector || return 1
    # python setup.py install || return 1
    # popd || return 1
    pacman -Sy &&
    yes | pacman -S reflector &&
    reflector --verbose --country China -p http --sort rate --save /etc/pacman.d/mirrorlist || return 1
    return 0
}
if ! {
    # install_reflector 2018 &&
    pacman -Syy &&
    pacman -S pacman-contrib --noconfirm &&
    rankmirrors $RESOURCE_DIR/archlinuxcn-mirrorlist > /etc/pacman.d/archlinuxcn-mirrorlist
}; then
    echo_err "make mirrors"
    exit 1
fi
echo_finish "make mirrors"

echo_start "pacstrap"
INSTALL_PACKAGES=(base base-devel grub)
case $PARTITION_MODE in
    MBR | GPT | BtrFS )
        INSTALL_PACKAGES+=(btrfs-progs)
        ;;
esac
case $PARTITION_MODE in
    USB_GPT | USB_Hybrid | GPT)
        INSTALL_PACKAGES+=(efibootmgr)
        ;;
esac
if ! yes ' ' | pacstrap -i $ROOT ${INSTALL_PACKAGES[@]}; then
    echo_err "pacstrap"
    umount
    exit 1
fi
echo_finish "pacstrap"

echo_start "genfstab"
if ! genfstab -U -p $ROOT | sed -e 's#^\(\S\+\)\(\s\+\)/var/lib\(\s\+\)btrfs\(\s\+\)\(\([^,]\+,\)\{4\}\)\([^,]\+\)\S\+\(.*\)$#\1\2/run/f\3btrfs\4\5\7\8\n/run/f/active/ROOT/var/lib\t\t\t/var/lib\tnone\t\tbind 0 0#g' >> $ROOT/etc/fstab; then
    echo_err "genfstab"
    umount
    exit 1
fi
echo_finish "genfstab"

echo_start "rsync"
if [ -f $SCRIPT_DIR/../fonts.tar.xz ]; then
    tar -C $RESOURCE_DIR -xpf $SCRIPT_DIR/../fonts.tar.xz > /dev/null 2>&1
fi
if [ -f $SCRIPT_DIR/../user.tar.xz ]; then
    tar -C $RESOURCE_DIR -xpf $SCRIPT_DIR/../user.tar.xz > /dev/null 2>&1
fi
if ! {
    rsync -avP /etc/pacman.d/mirrorlist $ROOT/etc/pacman.d/mirrorlist &&
    rsync -avP /etc/pacman.d/archlinuxcn-mirrorlist $ROOT/etc/pacman.d/archlinuxcn-mirrorlist &&
    rsync -avP $RESOURCE_DIR/pacman.conf $ROOT/etc/pacman.conf &&
    rsync -avP $SCRIPT_DIR/root_install.sh $ROOT/root/root_install.sh &&
    mkdir -p $ROOT/root/tmp &&
    rsync -avP $SCRIPT_DIR/mew_install.sh $ROOT/root/tmp/mew_install.sh &&
    rsync -avP $RESOURCE_DIR/prev_system/. $ROOT &&
    rsync -avP $RESOURCE_DIR/system $ROOT/root/tmp &&
    rsync -avP $RESOURCE_DIR/user $ROOT/root/tmp &&
    rsync -avP $RESOURCE_DIR/fonts $ROOT/root/tmp &&
    rsync -avP $CONFIG_DIR/echo_config $ROOT/root/tmp/echo_config &&
    rsync -avP $CONFIG_DIR/env_config $ROOT/root/tmp/env_config
}; then
    echo_err "rsync"
    umount
    exit 1
fi
echo_finish "rsync"

if ! arch-chroot $ROOT /bin/bash /root/root_install.sh $SD $PARTITION_MODE $VIRTUAL_MACHINE; then
    echo_err "arch-chroot"
    umount
    exit 1
fi

if ! {
    rm $ROOT/root/root_install.sh &&
    rm -rf $ROOT/root/tmp
}; then
    echo_err "rm"
    umount
    exit 1
fi

umount

exit 0
