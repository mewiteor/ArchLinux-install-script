#! /bin/bash

source /home/mewiteor/echo_config || exit 1

echo_start "install fonts"
if ! {
    which fc-cache > /dev/null 2>&1 &&
    echo_info "Resetting font cache, this may take a moment..." &&
    fc-cache -f $HOME/.local/share/fonts
}; then
    echo_err "install fonts"
    echo "#install fonts" >> ~/todo
else
    echo_finish "install fonts"
fi

exit 0
