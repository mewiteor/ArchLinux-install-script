@echo off
reg delete HKCR\*\shell\gvim /f
reg delete HKCR\*\shell\gvim_cur /f
reg delete HKCR\*\shell\gvim_tab /f
