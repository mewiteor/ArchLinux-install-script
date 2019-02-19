if has("multi_byte") && has("Gui")
    " set rop=type:directx,gamma:1.0,contrast:0.5,level:1,geom:1,renmode:4,taamode:1
    source $VIMRUNTIME/delmenu.vim 
    source $VIMRUNTIME/menu.vim 
    language messages zh_CN.utf-8 
endif 

" set pythonthreedll=$VIM/vimfiles/win32exe/python/python36.dll

let s:ctags_path = $VIM."/vimfiles/win32exe/ctags/ctags.exe"

if !has("Gui")
    let g:airline_powerline_fonts=0
endif

" 自动索引
" ludovicchabant/vim-gutentags
    let g:gutentags_ctags_executable= s:ctags_path

    " 将自动生成的 tags 文件全部放入 $TEMP/.cache/tags 目录中，避免污染工程目录
    let s:vim_tags = expand($TEMP.'/.cache/tags')
    let g:gutentags_cache_dir = s:vim_tags

    " 检测 $TEMP/.cache/tags 不存在就新建
    if !isdirectory(s:vim_tags)
       silent! call mkdir(s:vim_tags, 'p')
    endif

" 编译运行
" skywind3000/asyncrun.vim
    " 编译单个文件
    nnoremap <silent> <F11> :AsyncRun gcc -Wall -O2 "$(VIM_FILEPATH)" -o "$(VIM_FILEDIR)/$(VIM_FILENOEXT).exe" <cr>

" Yggdroot/LeaderF
    let g:Lf_Ctags = s:ctags_path
