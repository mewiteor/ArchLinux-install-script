#! /bin/bash

source /home/mewiteor/echo_config || exit 1

echo_start "get oh-my-zsh"
if ! {
    sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh|sed -e '/^\s\+env\s\+zsh\s*$/d')"
}; then
    echo_err "get oh-my-zsh"
    echo 'sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"' > ~/todo
else
    echo_finish "get oh-my-zsh"
fi

echo_start "config oh-my-zsh"
mv ~/zshrc ~/.zshrc
echo_finish "config oh-my-zsh"

echo_start "get powerlevel9k"
if ! git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k; then
    echo_err "get powerlevel9k"
    echo "git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k" >> ~/todo
else
    echo_finish "get powerlevel9k"
fi

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

echo_start "get zsh-syntax-highlighting"
if ! git clone git://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting; then
    echo_err "get zsh-syntax-highlighting"
    echo "git clone git://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" >> ~/todo
else
    echo_finish "get zsh-syntax-highlighting"
fi

exit 0
