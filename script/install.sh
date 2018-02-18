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

echo_start "rankmirrors"
if ! {
    rankmirrors $RESOURCE_DIR/mirrorlist > /etc/pacman.d/mirrorlist &&
    rankmirrors $RESOURCE_DIR/archlinuxcn-mirrorlist > /etc/pacman.d/archlinuxcn-mirrorlist
}; then
    echo_err "rankmirrors"
    exit 1
fi
echo_finish "rankmirrors"

echo_start "pacstrap"
INSTALL_PACKAGES=(base base-devel btrfs-progs grub)
case $PARTITION_MODE in
    USB_GPT | GPT)
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

echo_start "cp"
if [ -f $SCRIPT_DIR/../fonts.tar.xz ]; then
    tar -C $RESOURCE_DIR -xpf $SCRIPT_DIR/../fonts.tar.xz > /dev/null 2>&1
fi
if ! {
    cp /etc/pacman.d/mirrorlist $ROOT/etc/pacman.d/mirrorlist &&
    cp /etc/pacman.d/archlinuxcn-mirrorlist $ROOT/etc/pacman.d/archlinuxcn-mirrorlist &&
    cp $RESOURCE_DIR/pacman.conf $ROOT/etc/pacman.conf &&
    cp $SCRIPT_DIR/root_install.sh $ROOT/root/root_install.sh &&
    mkdir -p $ROOT/root/tmp &&
    mkdir -p $ROOT/root/tmp/x &&
    mkdir -p $ROOT/root/tmp/fonts &&
    cp $RESOURCE_DIR/zshrc $ROOT/root/tmp/zshrc &&
    cp $RESOURCE_DIR/gitconfig $ROOT/root/tmp/gitconfig &&
    cp $SCRIPT_DIR/mew_install.sh $ROOT/root/tmp/mew_install.sh &&
    cp $RESOURCE_DIR/arch_vimrc $ROOT/root/tmp/vimrc &&
    cp $RESOURCE_DIR/root_vimrc $ROOT/root/tmp/vrc &&
    cp $RESOURCE_DIR/x/* $ROOT/root/tmp/x/ &&
    cp $RESOURCE_DIR/fonts/* $ROOT/root/tmp/fonts/ &&
    cp $CONFIG_DIR/echo_config $ROOT/root/tmp/echo_config &&
    cp $CONFIG_DIR/env_config $ROOT/root/tmp/env_config
}; then
    echo_err "cp"
    umount
    exit 1
fi
echo_finish "cp"

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
