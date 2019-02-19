@echo off
cd /d %~dp0..\..\vim81
reg add HKCR\*\shell\gvim /f
reg add HKCR\*\shell\gvim /ve /t REG_SZ /d "用GVim编辑(&F)" /f
reg add HKCR\*\shell\gvim /v icon /t REG_SZ /d "%CD%\gvim.exe" /f
reg add HKCR\*\shell\gvim\command /f
reg add HKCR\*\shell\gvim\command /ve /t REG_SZ /d "%CD%\gvim.exe ""%%1""" /f
reg add HKCR\*\shell\gvim_cur /f
reg add HKCR\*\shell\gvim_cur /ve /t REG_SZ /d "在当前GVim中编辑" /f
reg add HKCR\*\shell\gvim_cur /v icon /t REG_SZ /d "%CD%\gvim.exe" /f
reg add HKCR\*\shell\gvim_cur\command /f
reg add HKCR\*\shell\gvim_cur\command /ve /t REG_SZ /d "%CD%\gvim.exe --remote-silent ""%%1""" /f
reg add HKCR\*\shell\gvim_tab /f
reg add HKCR\*\shell\gvim_tab /ve /t REG_SZ /d "在当前GVim中新的tab下编辑(&F)" /f
reg add HKCR\*\shell\gvim_tab /v icon /t REG_SZ /d "%CD%\gvim.exe" /f
reg add HKCR\*\shell\gvim_tab\command /f
reg add HKCR\*\shell\gvim_tab\command /ve /t REG_SZ /d "%CD%\gvim.exe --remote-tab-silent ""%%1""" /f
