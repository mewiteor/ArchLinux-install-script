if has("multi_byte") 
    " UTF-8 编码 
    set encoding=utf-8 
    set termencoding=utf-8 
    set formatoptions+=mM 
    set fencs=utf-8,gbk 
    if v:lang =~? '^/(zh/)/|/(ja/)/|/(ko/)' 
        set ambiwidth=double 
    endif 
    if has("win32") && has("Gui")
        set rop=type:directx,gamma:1.0,contrast:0.5,level:1,geom:1,renmode:4,taamode:1
        source $VIMRUNTIME/delmenu.vim 
        source $VIMRUNTIME/menu.vim 
        language messages zh_CN.utf-8 
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

" github
" 'drmingdrmer/xptemplate'
if has("Gui") || has("unix")
    " 'bling/vim-airline'
    " 'vim-airline/vim-airline-themes'

    let g:airline_theme='molokai'
    let g:airline_powerline_fonts=1
    let g:airline#extensions#tabline#enabled=1
    let g:airlie_detect_modified=1
    let g:airline_detect_paste=1
    let g:airline_detect_crypt=1
    let g:airline_inactive_collapse=1
endif

" need:
" 'tomasr/molokai'
let g:molokai_original = 1
let g:rehash256 = 1
color molokai

" vim-scripts repos
" 'nathanaelkane/vim-indent-guides'
nmap <F9> :IndentGuidesToggle<cr>

" need:
"   ctags(http://sourceforge.net/projects/ctags/files/latest/download?source=directory)
" 'majutsushi/tagbar'
nmap <F8> :TagbarToggle<cr>

" 'scrooloose/nerdtree'
nmap <F7> :NERDTreeToggle<cr>

" 'antoyo/vim-licenses'
let g:licenses_copyright_holders_name = 'Mewiteor <mewiteor@hotmail.com>'
let g:licenses_authors_name = 'Mewiteor <mewiteor@hotmail.com>'
let g:licenses_default_commands = ['gpl']

" You Complete Me
let g:ycm_global_ycm_extra_conf=$VIM."/vimfiles/.ycm_extra_conf.py"

if !exists("my_auto_commands_loaded")
    let my_auto_commands_loaded=1
    let g:LargeFile=1024*1024*10
    augroup LargeFile
        autocmd BufReadPre * let f=expand("<afile>")|if getfsize(f)>g:LargeFile|set  eventignore+=FileType | setlocal noswapfile bufhidden=unload buftype=nowrite undolevels=-1 | else | set eventignore-=FileType | endif
    augroup END
endif

inoremap <A-p> +
inoremap <A-o> _
inoremap <A-;> =
inoremap <A-l> -
nnoremap <A-p> +
nnoremap <A-o> _
nnoremap <A-;> =
nnoremap <A-l> -
cnoremap <A-p> +
cnoremap <A-o> _
cnoremap <A-;> =
cnoremap <A-l> -
if has('clipboard')
    nnoremap <A-c> :let @*=expand('<cword>')<cr>
    vnoremap <A-c> "*y
    vnoremap <A-x> "*d
    nnoremap <A-v> "*p
endif
let g:ycm_global_ycm_extra_conf=$VIM."/vimfiles/.ycm_extra_conf.py"
set rtp+=$VIM/vimfiles/snippets
