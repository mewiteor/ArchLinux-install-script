# 编译**You Complete Me**
## Linux
### 依赖环境
- clang
- [cmake](https://cmake.org/download/)
- [python-dev](https://www.python.org/)
- [git](https://git-scm.com/download/win)
- [vim](https://www.vim.org/download.php)

## Windows

### 依赖环境
- [visual studio](https://www.visualstudio.com/thank-you-downloading-visual-studio/?sku=Community)
- [cmake](https://cmake.org/download/)
- [python](https://www.python.org/)
- [git](https://git-scm.com/download/win)
- [vim](https://github.com/vim/vim-win32-installer/releases)

注: vim与python要同为32位或64位

### 准备工作
- 克隆YouCompleteMe:
```git
git clone --recursive https://github.com/Valloric/YouCompleteMe.git
```
- 从[llvm官网](http://releases.llvm.org/download.html)下载**llvm**源码和**clang**源码
- 解压llvm与clang文件
```shell
tar xpf llvm-版本号.src.tar.xz
tar xpf cfe-版本号.src.tar.xz
```

### 编译 libclang
从开始启动*... Native Tools Command Prompt for VS ...*
```shell
mkdir libclang构建路径
cd /d libclang构建路径
cmake libclang源路径\llvm-版本号.src -G "NMake Makefiles" -DBUILD_SHARED_LIBS=OFF -DLLVM_ENABLE_CXX1Y=ON -DLLVM_ENABLE_CXX1Z=ON -DLLVM_EXTERNAL_CLANG_SOURCE_DIR=libclang源路径\cfe-6.0.0.src -DLLVM_USE_CRT_DEBUG=MTd -DLLVM_USE_CRT_MINSIZEREL=MT -DLLVM_USE_CRT_RELEASE=MT -DLLVM_USE_CRT_RELWITHDEBINFO=MT -DCMAKE_BUILD_TYPE=Release
cmake --build . --target libclang
```

### 编译 YouCompleteMe
从开始启动*... Native Tools Command Prompt for VS ...*
```shell
mkdir YouCompleteMe构建路径
cd /d YouCompleteMe构建路径
cmake -G "NMake Makefiles" -DUSE_PYTHON2=OFF -DEXTERNAL_LIBCLANG_PATH=libclang构建路径\lib\libclang.lib -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS_RELEASE="/MT /O2 /Ob2 /DNDEBUG" -DCMAKE_CXX_FLAGS_RELEASE="/MT /O2 /Ob2 /DNDEBUG" -DBOOST_CONFIG_SUPPRESS_OUTDATED_MESSAGE= . Vim路径\vim\vimfiles\pack\plugins\start\YouCompleteMe\third_party\ycmd\cpp
cmake --build . --target ycm_core
```
复制`libclang构建路径\bin\libclang.dll`到`Vim路径\vim\vimfiles\pack\plugins\start\YouCompleteMe\third_party\ycmd`目录下
