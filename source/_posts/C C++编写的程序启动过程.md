---
title: C/C++编写的程序启动过程
tags:
  - 程序启动
id: 1754
categories:
  - C/C++
date: 2016-01-16 17:21:46
---

记得以前学汇编和PE文件的时候知道，系统不会直接调用我们编写的main，而是调用指定的入口地址。实际上这个入口地址，是在链接时候指定的，MS C/C++中使用链接命令/entry:function可以修改默认设置。

那么，默认情况下，我们使用VC编写的应用程序使用的是什么入口函数了？

|  函数   |  默认   |
| --- | --- |
| **mainCRTStartup** (or **wmainCRTStartup**)    |   An application using /SUBSYSTEM:**CONSOLE**; calls **main** (or **wmain**)  |
| **WinMainCRTStartup** (or **wWinMainCRTStartup**)    |    An application using /SUBSYSTEM:**WINDOWS**; calls **WinMain** (or **wWinMain**), which must be defined with **__stdcall** |

注意，区分入口函数和主函数（main，WinMain）。

默认情况下，控制台程序使用**mainCRTStartup**作为入口函数，窗口程序使用**WinMainCRTStartup**作为入口函数。同时，这两个函数都有对应的Unicode版本（前缀加w)。

现在要考虑的是，这些启动函数都做了什么事情？

在crtexe.c文件中可以找到这几个启动函数的定义，如下：

``` cpp?linenums
#ifdef _WINMAIN_

#ifdef WPRFLAG
int wWinMainCRTStartup(
#else  /* WPRFLAG */
int WinMainCRTStartup(
#endif  /* WPRFLAG */

#else  /* _WINMAIN_ */

#ifdef WPRFLAG
int wmainCRTStartup(
#else  /* WPRFLAG */
int mainCRTStartup(
#endif  /* WPRFLAG */

#endif  /* _WINMAIN_ */
        void
        )
{
        /*
         * The /GS security cookie must be initialized before any exception
         * handling targetting the current image is registered.  No function
         * using exception handling can be called in the current image until
         * after __security_init_cookie has been called.
         */
        __security_init_cookie();

        return __tmainCRTStartup();
}

```

因此，实际上是根据平台（Windows或者Console），多字节还是Unicode，生成不同的默认入口函数。

``` cpp?linenums
__declspec(noinline)
int
__tmainCRTStartup(
         void
         )
{
        int initret;
        int mainret=0;
        int managedapp;
#ifdef _WINMAIN_
        _TUCHAR *lpszCommandLine;
        STARTUPINFO StartupInfo;

        __try {
            /*
            Note: MSDN specifically notes that GetStartupInfo returns no error, and throws unspecified SEH if it fails, so
            the very general exception handler below is appropriate
            */
            GetStartupInfo( amp;StartupInfo );
        } __except(EXCEPTION_EXECUTE_HANDLER) {
            return 255;
        }
#endif  /* _WINMAIN_ */
        /*
         * Determine if this is a managed application
         */
        managedapp = check_managed_app();

        if ( !_heap_init(1) )               /* initialize heap */
            fast_error_exit(_RT_HEAPINIT);  /* write message and die */

        if( !_mtinit() )                    /* initialize multi-thread */
            fast_error_exit(_RT_THREAD);    /* write message and die */

        /* Enable buffer count checking if linking against static lib */
        _CrtSetCheckCount(TRUE);

        /*
         * Initialize the Runtime Checks stuff
         */
#ifdef _RTC
        _RTC_Initialize();
#endif  /* _RTC */
        /*
         * Guard the remainder of the initialization code and the call
         * to user's main, or WinMain, function in a __try/__except
         * statement.
         */

        __try {

            if ( _ioinit() lt; 0 )            /* initialize lowio */
                _amsg_exit(_RT_LOWIOINIT);

            /* get wide cmd line info */
            _tcmdln = (_TSCHAR *)GetCommandLineT();

            /* get wide environ info */
            _tenvptr = (_TSCHAR *)GetEnvironmentStringsT();

            if ( _tsetargv() lt; 0 )
                _amsg_exit(_RT_SPACEARG);
            if ( _tsetenvp() lt; 0 )
                _amsg_exit(_RT_SPACEENV);

            initret = _cinit(TRUE);                  /* do C data initialize */
            if (initret != 0)
                _amsg_exit(initret);

#ifdef _WINMAIN_

            lpszCommandLine = _twincmdln();
            mainret = _tWinMain( (HINSTANCE)amp;__ImageBase,
                                 NULL,
                                 lpszCommandLine,
                                 StartupInfo.dwFlags amp; STARTF_USESHOWWINDOW
                                      ? StartupInfo.wShowWindow
                                      : SW_SHOWDEFAULT
                                );
#else  /* _WINMAIN_ */
            _tinitenv = _tenviron;
            mainret = _tmain(__argc, _targv, _tenviron);
#endif  /* _WINMAIN_ */

            if ( !managedapp )
                exit(mainret);

            _cexit();

        }
        __except ( _XcptFilter(GetExceptionCode(), GetExceptionInformation()) )
        {
            /*
             * Should never reach here
             */

            mainret = GetExceptionCode();

            if ( !managedapp )
                _exit(mainret);

            _c_exit();

        } /* end of try - except */

        return mainret;
}
```

从上面代码，可以很清晰了解启动函数到底做了什么事情。

Console版本

1.初始化C的堆申请（_heap_init(1)）

2.初始化多线程（_mtinit()）

3.获取命令行（GetCommandLineT()）

4.获取环境变量（GetEnvironmentStringsT()）

5.初始化C和C++的全局变量（_cinit(TRUE)）

6.调用main函数（_tmain(__argc, _targv, _tenviron)）

Windows版本

1.获取StartupInfo（GetStartupInfo( StartupInfo )）

2.初始化C的堆申请（_heap_init(1)）

3.初始化多线程（_mtinit()）

4.获取命令行（GetCommandLineT()）

5.获取环境变量（GetEnvironmentStringsT()）

6.初始化C和C++的全局变量（_cinit(TRUE)）

7.调用WinMain函数



最后再看看_cinit(TRUE)到底做了什么事情？

``` cpp?linenums
int __cdecl _cinit (
        int initFloatingPrecision
        )
{
        int initret;

        /*
         * initialize floating point package, if present
         */
#ifdef CRTDLL
        _fpmath(initFloatingPrecision);
#else  /* CRTDLL */
        if (_FPinit != NULL amp;amp;
            _IsNonwritableInCurrentImage((PBYTE)amp;_FPinit))
        {
            (*_FPinit)(initFloatingPrecision);
        }
        _initp_misc_cfltcvt_tab();
#endif  /* CRTDLL */

        /*
         * do initializations
         */
        initret = _initterm_e( __xi_a, __xi_z );
        if ( initret != 0 )
            return initret;

#ifdef _RTC
        atexit(_RTC_Terminate);
#endif  /* _RTC */
        /*
         * do C++ initializations
         */
        _initterm( __xc_a, __xc_z );

#ifndef CRTDLL
        /*
         * If we have any dynamically initialized __declspec(thread)
         * variables, then invoke their initialization for the thread on
         * which the DLL is being loaded, by calling __dyn_tls_init through
         * a callback defined in tlsdyn.obj.  We can't rely on the OS
         * calling __dyn_tls_init with DLL_PROCESS_ATTACH because, on
         * Win2K3 and before, that call happens before the CRT is
         * initialized.
         */
        if (__dyn_tls_init_callback != NULL amp;amp;
            _IsNonwritableInCurrentImage((PBYTE)amp;__dyn_tls_init_callback))
        {
            __dyn_tls_init_callback(NULL, DLL_THREAD_ATTACH, NULL);
        }
#endif  /* CRTDLL */

        return 0;
}
```

最重要的两行，initret = _initterm_e( __xi_a, __xi_z )和_initterm( __xc_a, __xc_z )。这两行的作用分别是初始化C标准库中的全局变量和初始化C++的全局变量。

至此，对C++程序的默认启动函数的基本过程有个了解了。

