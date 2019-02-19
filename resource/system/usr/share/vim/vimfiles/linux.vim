" 自动索引
" ludovicchabant/vim-gutentags
    " 将自动生成的 tags 文件全部放入 ~/.cache/tags 目录中，避免污染工程目录
    let s:vim_tags = expand($HOME.'/.cache/tags')
    let g:gutentags_cache_dir = s:vim_tags

    " 检测 $HOME/.cache/tags 不存在就新建
    if !isdirectory(s:vim_tags)
       silent! call mkdir(s:vim_tags, 'p')
    endif
