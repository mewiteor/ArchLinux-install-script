XPTemplate priority=personal

XPTinclude
      \ _common/common.arg.xpt.vim
      \ _condition/c.like.vim
      \ _loop/c.like.vim
      \ _func/c.like.vim

XPT #inc    " include <>
#include <`^>

XPT un " using namespace ;
using namespace `std^;
