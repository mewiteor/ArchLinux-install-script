#!/bin/bash

source ../config/echo_config || exit 1

echo_start "set"
if ! {
    cp $RESOURCE_DIR/LiveCD_vimrc /etc/vimrc &&
    yes q|passwd &&
    systemctl start sshd &&
    ifconfig | grep 'inet '
}; then
    echo_err "set"
    exit 1
fi
echo_finish "set"
