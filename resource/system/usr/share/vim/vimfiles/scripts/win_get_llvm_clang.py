llvm_url='http://releases.llvm.org/download.html'
def main():
    import re, six, logging, sys, lzma, tarfile, shutil, os
    from contextlib import closing
    from io import BytesIO
    content=''

    if os.path.exists('llvm') and os.path.exists('clang'):
        return

    try:
        with six.moves.urllib.request.urlopen(llvm_url) as f:
            content=f.read().decode('utf-8')
    except Exception as e:
        sys.stderr.write('get llvm download page error:\n')
        logging.exception(e)
        exit(1)
    if content:
        llvm_links=[]
        clang_links=[]
        for ver in re.findall(r'<a href="([\w|\.]+)/llvm-\1\.src\.tar\.xz">',content):
            llvm_links.append((ver,r'http://releases.llvm.org/{0}/llvm-{0}.src.tar.xz'.format(ver)))
        for ver in re.findall(r'<a href="([\w|\.]+)/cfe-\1\.src\.tar\.xz">',content):
            clang_links.append((ver,r'http://releases.llvm.org/{0}/cfe-{0}.src.tar.xz'.format(ver)))
        common_links=set([x[0] for x in llvm_links])&set([x[0] for x in clang_links])
        llvm_link=None
        clang_link=None
        llvm_ver=None
        clang_ver=None
        for link in llvm_links:
            if link[0] in common_links:
                llvm_ver=link[0]
                llvm_link=link[1]
                break
        for link in clang_links:
            if link[0] in common_links:
                clang_ver=link[0]
                clang_link=link[1]
                break
        if llvm_link is None:
            sys.stderr.write('Error: get llvm link failed!\n')
            exit(1)
        if clang_link is None:
            sys.stderr.write('Error: get clang link failed!\n')
            exit(1)
        if llvm_ver is None or clang_ver is None or llvm_ver != clang_ver:
            sys.stderr.write('Error: version error!\n')
            exit(1)
        print('version: {}'.format(llvm_ver))
        try:
            print('download {}...'.format(llvm_link))
            datas=None
            with six.moves.urllib.request.urlopen(llvm_link) as f:
                datas = f.read()
            if datas is None:
                sys.stderr.write('get llvm error:\n')
                exit(1)
        except Exception as e:
            sys.stderr.write('get llvm error:\n')
            logging.exception(e)
            exit(1)
        print('extract {}...'.format(llvm_link))
        try:
            shutil.rmtree('llvm', True)
            with BytesIO(datas) as data:
                with lzma.open(data) as xz:
                    with tarfile.open(fileobj=xz) as tar:
                        tar.extractall('llvm')
        except Exception as e:
            sys.stderr.write('extract llvm error:\n')
            logging.exception(e)
            exit(1)
        try:
            print('download {}...'.format(clang_link))
            datas=None
            with six.moves.urllib.request.urlopen(clang_link) as f:
                datas = f.read()
            if datas is None:
                sys.stderr.write('get clang error:\n')
                exit(1)
        except Exception as e:
            sys.stderr.write('get clang error:\n')
            logging.exception(e)
            exit(1)
        print('extract {}...'.format(clang_link))
        try:
            shutil.rmtree('clang', True)
            with BytesIO(datas) as data:
                with lzma.open(data) as xz:
                    with tarfile.open(fileobj=xz) as tar:
                        tar.extractall('clang')
        except Exception as e:
            sys.stderr.write('extract clang error:\n')
            logging.exception(e)
            exit(1)

if __name__ == "__main__":
    main()
