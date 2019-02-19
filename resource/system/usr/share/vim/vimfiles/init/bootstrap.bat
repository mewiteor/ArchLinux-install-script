@echo off
git submodule init
git submodule update
mkdir ../autoload
mkdir ../plugged
copy ../pack/plugins/start/vim-plug/plug.vim ../autoload/plug.vim
