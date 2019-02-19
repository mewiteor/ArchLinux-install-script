XPTemplate priority=personal

XPT main hint=main\ (argc,\ argv)
int main(int argc, char *argv[])
{
    `cursor^
    return 0;
}

XPT fun wrap=curosr	hint=func..\ (\ ..\ )\ {...
`int^ `name^(`param?^)
{
    `cursor^
}

XPT twmain hint=int APIENTRY _tWinMain...
#include<windows.h>
#include<tchar.h>

#pragma comment(lib,"user32.lib")
#pragma comment(lib,"gdi32.lib")

#pragma comment(linker,"\"/manifestdependency:type='win32' \
name='Microsoft.Windows.Common-Controls' version='6.0.0.0' \
processorArchitecture='*' publicKeyToken='6595b64144ccf1df' language='*'\"")

#ifndef __FUNCSIG__
#define __FUNCSIG__ ""
#endif

#define ERR(fun,code) ErrorMessage(_T(__FILE__),__LINE__,_T(__FUNCSIG__),_T(fun),code)
#define E(fun)  do {\
                    DWORD dw=GetLastError();\
                    if(dw)\
                        ERR(fun,dw);\
                }while(0)


LRESULT CALLBACK WndProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam);
void ErrorMessage(LPCTSTR lpszFileName,DWORD dwLine,LPCTSTR lpszParentFunction,LPCTSTR lpszFunction,DWORD dwCode);       // 输出错误信息

int APIENTRY _tWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPTSTR lpCmdLine, int nCmdShow)
{
    LPCTSTR lpClassName = _T("`className^"),           // 窗口类名
            lpWindowTitle = _T("`windowTitle^");         // 窗口标题
    WNDCLASSEX wcex =
    {
        sizeof(WNDCLASSEX),
        CS_HREDRAW | CS_VREDRAW,
        WndProc,
        0,0,hInstance,NULL,
        LoadCursor(NULL,IDC_ARROW),
        (HBRUSH)GetStockObject(WHITE_BRUSH),
        NULL,lpClassName
    };
    HWND hWnd;
    MSG msg = { 0 };

    if (!RegisterClassEx(&wcex))
    {
        E("RegisterClassEx");
        return 1;
    }

    hWnd = CreateWindow(lpClassName, lpWindowTitle, WS_OVERLAPPEDWINDOW,
        CW_USEDEFAULT, 0, CW_USEDEFAULT, 0, NULL, NULL, hInstance, NULL);
    if (NULL == hWnd)
    {
        E("CreateWindow");
        return 1;
    }
    ShowWindow(hWnd, nCmdShow);
    UpdateWindow(hWnd);
    while (GetMessage(&msg, NULL, 0, 0))
    {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }
    return (int)msg.wParam;
}

LRESULT CALLBACK WndProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
    switch (uMsg)
    {
    `cursor^
    case WM_DESTROY:
        PostQuitMessage(0);
        return 0;
    }
    return DefWindowProc(hWnd, uMsg, wParam, lParam);
}

// Retrieve the system error message for the last-error code
void ErrorMessage(LPCTSTR lpszFileName,DWORD dwLine,LPCTSTR lpszParentFunction,LPCTSTR lpszFunction,DWORD dwCode)
{
    // Retrieve the system error message for the last-error code
    LPTSTR lpMsgBuf = NULL;
    LPTSTR lpDisplayBuf = NULL;

    FormatMessage(
        FORMAT_MESSAGE_ALLOCATE_BUFFER |
        FORMAT_MESSAGE_FROM_SYSTEM |
        FORMAT_MESSAGE_IGNORE_INSERTS|
        FORMAT_MESSAGE_MAX_WIDTH_MASK,
        NULL,
        dwCode,
        MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
        (LPTSTR) &lpMsgBuf,
        0, NULL );
    
    if(lpMsgBuf)
    {
        va_list vas[] =
        {
            (va_list)lpszFileName,
            (va_list)dwLine,
            (va_list)lpszParentFunction,
            (va_list)lpszFunction,
            (va_list)dwCode,
            (va_list)lpMsgBuf
        };
        FormatMessage(
            FORMAT_MESSAGE_ALLOCATE_BUFFER |
            FORMAT_MESSAGE_ARGUMENT_ARRAY |
            FORMAT_MESSAGE_FROM_STRING,
            _T("Filename:%1\n")
            _T("Line:%2!lu!\n")
            _T("Parent function:%3\n")
            _T("Function:%4\n")
            _T("Code:%5!lu!\n")
            _T("Description:%6"),
            0,
            0,
            (LPTSTR)&lpDisplayBuf,
            0,
            vas);
    }

    // Display the error message and exit the process
    if(lpDisplayBuf)
        MessageBox(NULL, lpDisplayBuf, TEXT("Error"), MB_OK);

    if(lpMsgBuf)
        LocalFree(lpMsgBuf);
    if(lpDisplayBuf)
        LocalFree(lpDisplayBuf);
}
