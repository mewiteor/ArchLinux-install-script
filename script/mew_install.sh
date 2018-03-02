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

echo_start "cmake ycmd"
if ! {
    mkdir -p /dev/shm/build &&
    pushd /dev/shm/build
}; then
    echo_err "cmake ycmd"
else
    CPU_COUNT=$(($(cat /proc/cpuinfo | grep processor | wc -l) - 1))
    if [ -n "$CPU_COUNT" ] && [ $CPU_COUNT -gt 0 ]; then
        export MAKEFLAGS="-j$CPU_COUNT"
    fi
    if ! {
        cmake -G "Unix Makefiles" -DUSE_SYSTEM_LIBCLANG=ON -DUSE_PYTHON2=OFF . /usr/share/vim/vimfiles/pack/plugins/start/YouCompleteMe/third_party/ycmd/cpp &&
        cmake --build . --target ycm_core
    }; then
        echo_err "cmake ycmd"
    else
        echo_finish "cmake ycmd"
    fi
    popd
fi

exit 0
