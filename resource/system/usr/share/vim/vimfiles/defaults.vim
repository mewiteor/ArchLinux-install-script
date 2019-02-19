if has("multi_byte") 
    " UTF-8 编码 
    set encoding=utf-8 
    set termencoding=utf-8 
    set formatoptions+=mM 
    set fencs=ucs-bom,utf-8,gbk,latin1
    if v:lang =~? '^/(zh/)/|/(ja/)/|/(ko/)' 
        set ambiwidth=double 
    endif 
else 
    echoerr "Sorry, this version of (g)vim was not compiled with +multi_byte" 
endif
set number
set tabstop=4
set expandtab
set cursorline
set shiftwidth=4
set softtabstop=4
set nobackup
set autochdir
set statusline=2

" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('$VIM/vimfiles/plugged')

" 代码片段
Plug 'drmingdrmer/xptemplate'
    " 设置ID和E-mail
    let g:xptemplate_vars = "author=mewiteor&email=mewiteor@hotmail.com&PYTHON_EXC=python"
    set rtp+=$VIM/vimfiles/snippets

    " airline
    Plug 'bling/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    let g:airline_theme='molokai'
    let g:airline_powerline_fonts=1
    let g:airline#extensions#tabline#enabled=1
    let g:airline_detect_modified=1
    let g:airline_detect_paste=1
    let g:airline_detect_crypt=1
    let g:airline_inactive_collapse=1

" 配色
Plug 'tomasr/molokai'
    let g:molokai_original = 1
    let g:rehash256 = 1
    silent! colorscheme molokai

" 高亮缩进
Plug 'nathanaelkane/vim-indent-guides', { 'on': 'IndentGuidesToggle' }
    nmap <F9> :IndentGuidesToggle<cr>

" set rtp+=$VIM/vimfiles/win32exe/ctags
" 依赖:
"   ctags(
"       http://sourceforge.net/projects/ctags/files/latest/download?source=directory
"    or https://github.com/universal-ctags/ctags-win32/releases)
" Plug 'majutsushi/tagbar', { 'on': 'TagbarToggle' }
"    if has("Win32")
"        let g:tagbar_ctags_bin=$VIM."/vimfiles/win32exe/ctags/ctags.exe"
"    endif
"    nmap <F8> :TagbarToggle<cr>

Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
    nmap <F7> :NERDTreeToggle<cr>
    let g:NERDTreeDirArrows=0

" You Complete Me
function! BuildYCM(info)
    " info is a dictionary with 3 fields
    " - name:   name of the plugin
    " - status: 'installed', 'updated', or 'unchanged'
    " - force:  set on PlugInstall! or PlugUpdate!
    if a:info.status == 'installed' || a:info.force
        if has('win32')
            echo 'install YCM youself please'
        elseif has('unix')
            !./install.py
        else
            echo 'unknown system'
        endif
    endif
endfunction
Plug 'Valloric/YouCompleteMe', { 'do': function('BuildYCM') }
    let g:ycm_global_ycm_extra_conf=$VIM."/vimfiles/ycm_extra_conf.py"
    let g:ycm_add_preview_to_completeopt=0
    let g:ycm_show_diagnostics_ui=0
    let g:ycm_server_log_level = 'info' " ???
    let g:ycm_min_num_identifier_candidate_chars = 2
    let g:ycm_collect_identifiers_from_comments_and_strings = 1
    let g:ycm_complete_in_strings=1
    let g:ycm_key_invoke_completion = '<c-j>'
    set completeopt=menu,menuone
    let g:ycm_semantic_triggers = {
			\ 'c,cpp,python,java,go,erlang,perl': ['re!\w{2}'],
			\ 'cs,lua,javascript': ['re!\w{2}'],
			\ }

Plug 'rkulla/pydiction'
    let g:pydiction_location = $VIM."/vimfiles/plugged/pydiction/complete-dict"

" let g:netrw_altv          = 1
" let g:netrw_fastbrowse    = 2
" let g:netrw_keepdir       = 0
let g:netrw_liststyle     = 0
" let g:netrw_retmap        = 1
" let g:netrw_silent        = 1
let g:netrw_special_syntax= 1
" let g:netrw_ftp_list_cmd="ls -F"

" 自动索引
Plug 'ludovicchabant/vim-gutentags'
    " gutentags 搜索工程目录的标志，碰到这些文件/目录名就停止向上一级目录递归
    let g:gutentags_project_root = ['.root', '.svn', '.git', '.hg', '.project']

    " 所生成的数据文件的名称
    let g:gutentags_ctags_tagfile = '.tags'

    " 配置 ctags 的参数
    let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
    let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
    let g:gutentags_ctags_extra_args += ['--c-kinds=+px']


" 编译运行
Plug 'skywind3000/asyncrun.vim'
    " 自动打开 quickfix window ，高度为 6
    let g:asyncrun_open = 6

    " 任务结束时候响铃提醒
    let g:asyncrun_bell = 1

    " 设置 F10 打开/关闭 Quickfix 窗口
    nnoremap <F10> :call asyncrun#quickfix_toggle(6)<cr>

" 动态检查
Plug 'w0rp/ale'

" 修改比较

" 编辑辅助
" 文件切换
Plug 'octol/vim-cpp-enhanced-highlight'

if exists('win32')
    Plug 'Yggdroot/LeaderF', { 'do': '.\install.bat' }
elseif exists('unix')
    Plug 'Yggdroot/LeaderF', { 'do': '.\install.sh' }
else
    Plug 'Yggdroot/LeaderF'
endif
    nnoremap <A-P> :LeaderfFunction!<cr>
    " let g:Lf_ShortcutF = '<c-p>'
    " let g:Lf_ShortcutB = '<m-n>'
    " noremap <c-n> :LeaderfMru<cr>
    " noremap <m-p> :LeaderfFunction!<cr>
    " noremap <m-n> :LeaderfBuffer<cr>
    " noremap <m-m> :LeaderfTag<cr>
    " let g:Lf_StlSeparator = { 'left': '', 'right': '', 'font': '' }

    " let g:Lf_RootMarkers = ['.project', '.root', '.svn', '.git']
    " let g:Lf_WorkingDirectoryMode = 'Ac'
    " let g:Lf_WindowHeight = 0.30
    " let g:Lf_CacheDirectory = expand('~/.vim/cache')
    " let g:Lf_ShowRelativePath = 0
    " let g:Lf_HideHelp = 1
    " let g:Lf_StlColorscheme = 'powerline'
    " let g:Lf_PreviewResult = {'Function':0, 'BufTag':0}

" 
Plug 'Shougo/echodoc.vim'
    set noshowmode
    let g:echodoc#enable_at_startup=1

Plug 'mhinz/vim-startify'

" 中文文档
Plug 'yianwillis/vimcdoc'

" Initialize plugin system
call plug#end()

if !exists("my_auto_commands_loaded")
    let my_auto_commands_loaded=1
    let g:LargeFile=1024*1024*10
    augroup LargeFile
        autocmd BufReadPre * let f=expand("<afile>")|if getfsize(f)>g:LargeFile|set  eventignore+=FileType | setlocal noswapfile bufhidden=unload buftype=nowrite undolevels=-1 | else | set eventignore-=FileType | endif
    augroup END

    " make
    " let $PATH=$VIM."/mingw64/bin;".$PATH
    if has('autocmd')
        " autocmd BufReadPost *.c setlocal makeprg=gcc\ -o\ %<\ %\ -std=c11
        " autocmd BufReadPost *.cpp setlocal makeprg=g++\ -o\ %<\ %\ -std=c++1z
        " autocmd BufReadPost *.cxx setlocal makeprg=g++\ -o\ %<\ %\ -std=c++1z

        function! QfMakeConv()
            let qflist = getqflist()
            for i in qflist
                let i.text = iconv(i.text, "cp936", "utf-8")
            endfor
            call setqflist(qflist)
        endfunction

        autocmd QuickFixCmdPost make call QfMakeConv()
    endif
endif

if has('clipboard')
    nnoremap <A-c> :let @*=expand('<cword>')<cr>
    nnoremap <A-f> :let @/=expand('<cword>')<cr>
    vnoremap <A-c> "*y
    vnoremap <A-x> "*d
    nnoremap <A-v> "*p
endif

if has('win32')
    source $VIM/vimfiles/win32.vim
endif
