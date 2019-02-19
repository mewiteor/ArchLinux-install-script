@echo on
set ROOT_PATH=%CD%
python %~dp0win_get_llvm_clang.py || goto Err

call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" %*

REM make libclang
mkdir "%ROOT_PATH%\libclang_build"
cd /d "%ROOT_PATH%\llvm"
for /f %%i in ('dir /b llvm-*') do ren "%%i" llvm
cd /d "%ROOT_PATH%\clang"
for /f %%i in ('dir /b cfe-*') do ren "%%i" cfe
cd /d "%ROOT_PATH%\libclang_build"

cmake "%ROOT_PATH%\llvm\llvm" -G "NMake Makefiles" -DBUILD_SHARED_LIBS=OFF -DLLVM_ENABLE_CXX1Y=ON -DLLVM_ENABLE_CXX1Z=ON -DLLVM_EXTERNAL_CLANG_SOURCE_DIR="%ROOT_PATH%\clang\cfe" -DLLVM_USE_CRT_DEBUG=MTd -DLLVM_USE_CRT_MINSIZEREL=MT -DLLVM_USE_CRT_RELEASE=MT -DLLVM_USE_CRT_RELWITHDEBINFO=MT -DCMAKE_BUILD_TYPE=Release && cmake --build . --target libclang || goto Err

REM make ycm
mkdir "%ROOT_PATH%\ycm_build"
mkdir "%ROOT_PATH%\third_party\ycmd\cpp"
cd /d "%ROOT_PATH%\ycm_build"
cmake -G "NMake Makefiles" -DUSE_PYTHON2=OFF -DEXTERNAL_LIBCLANG_PATH="%ROOT_PATH%\libclang_build\lib\libclang.lib" -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS_RELEASE="/MT /O2 /Ob2 /DNDEBUG" -DCMAKE_CXX_FLAGS_RELEASE="/MT /O2 /Ob2 /DNDEBUG" -DBOOST_CONFIG_SUPPRESS_OUTDATED_MESSAGE= . "%ROOT_PATH%\third_party\ycmd\cpp" && cmake --build . --target ycm_core

if not exist "%ROOT_PATH%\libclang_build\bin\libclang.dll" goto Err
del /q /f "%ROOT_PATH%\third_party\ycmd\libclang.dll"
copy "%ROOT_PATH%\libclang_build\bin\libclang.dll" "%ROOT_PATH%\third_party\ycmd\libclang.dll" || goto Err

cd /d %ROOT_PATH%
del /s /q /f %ROOT_PATH%\libclang_build\*
del /s /q /f %ROOT_PATH%\ycm_build\*
del /s /q /f %ROOT_PATH%\llvm\*
del /s /q /f %ROOT_PATH%\clang\*
rmdir /s /q %ROOT_PATH%\libclang_build
rmdir /s /q %ROOT_PATH%\ycm_build
rmdir /s /q %ROOT_PATH%\llvm
rmdir /s /q %ROOT_PATH%\clang

echo success
exit 0
:Err
echo error
exit 1
