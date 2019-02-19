" Vim plugin to translate

if exists("g:loaded_translate")
    finish
endif
let g:loaded_translate = 1

fun! translate#youdao(word, from, to) "{{{
    let type='AUTO'
    if toupper(a:from) != 'AUTO' || toupper(a:to) != 'AUTO'
        let type='AUTO'
    endif
    let url="http://fanyi.youdao.com/translate?&doctype=json&type=".type."&i=".a:word
    let trans_word=json_decode(download#get(url))
    for transes in trans_word["translateResult"]
        for tran in transes
            echo tran['tgt']
        endfor
    endfor
endfun "}}}

command! -nargs=1 Trans call translate#youdao(expand("<args>"),"AUTO","AUTO")
