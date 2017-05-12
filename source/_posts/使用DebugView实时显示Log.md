---
title: 使用DebugView实时显示Log
tags:
  - DebugView
  - Log
  - 调试
id: 2081
categories:
  - 编程语言
date: 2016-08-15 20:48:18
---

## DebugView简介

DebugView是一个监视本地系统或者通过tcp/ip连接的网络系统的OutputDebugString输出的应用程序。DebugView不仅能够监视Win32应用的debug输出，还可以监视内核模型的debug输出。因此，如果使用OutputDebugString来打印调试信息的话，就可以在程序运行时候通过DebugView来实时显示程序的调试信息。
这种方式在某种意义上，比将Log打印到文件中，关闭程序后再查看Log输出的方式更加方便。而且可以将这两种调试程序的方式结合起来，既使用DebugView来实时显示调试信息，又将调试信息输出到Log文件中，方便以后分析。

# 安装DebugView

下载地址：[DebugView](https://technet.microsoft.com/en-us/sysinternals/debugview.aspx)
下载后面后解压压缩包，发现里面有三个文件：Dbgview.exe、dbgview.chm、Eula.txt。
Dbgview.exe就是我们要使用的实时显示Log工具。dbgview.chm是自带的文档，有不懂的地方可以查阅该文档。
现在可以将DebugView.exe放到任何你喜欢的目录，比如桌面。

# 配置DebugView

## 配置Capture

如下图所示，要记得勾选Capture Win32和Capture Global Win32。Capture Global Win32用于网络模式下捕获网络主机的Debug输出的时候。如果需要捕获内核模式的调试输出，记得勾选Capture Kernel Win32。
![enter description here](https://c1.staticflickr.com/9/8750/28713108000_0384dfb06a_o.png)
如果点击Capture Global Win32菜单出现提示：
![enter description here](https://c1.staticflickr.com/9/8315/28999300555_61681b6880_o.png)
重新以管理员的身份启动DebugView。
![enter description here](https://c1.staticflickr.com/9/8897/28999300535_075a591b02_o.png)

## 配置Filter

如下图所示，打开Filter对话框，
![enter description here](https://c2.staticflickr.com/8/7507/28923046321_72cd949daa_o.png)![enter description here](https://c1.staticflickr.com/9/8744/28713274070_2809e64189_o.png)
然后在Include中输入要包含的字符串，比如"hankpcxiao"，多个字符串用;分隔，比如"hankpcxiao;xpc"。
这样就只会捕获包括过滤字符串hankpcxiao或者xpc的OutputDebugString输出。
如果我们在每个OutputDebugString输出前自动加上过滤字符串，那么DebugView就只会输出我们的Log信息了。

## 开启捕获

最后确保开启了捕获，如下图所示：
![enter description here](https://c1.staticflickr.com/9/8842/28999300405_0355a4405f_o.png)

# 如何在程序中输出Log信息？

默认情况下，DebugView会捕获函数OutputDebugString的输出，但是这个函数的参数是个字符串指针，不太方便。下面我们通过一些列步骤来创建一个方便使用的Log类。

## 格式化输出

我们习惯使用printf这样的函数来格式化输出信息，因此这次我们也把OutputDebugString包装成可变参数形式的格式化输出函数。

``` cpp
    void DebugViewOutput(const char* fm, ...)
    {
        static char szMsg[MAX_PATH];

        va_list argList;
        va_start(argList, fm);
        vsprintf_s(szMsg, fm, argList);
        va_end(argList);

        OutputDebugString(szMsg);
    }
```

## 让DebugView在VS调试程序时候也能够捕获Log

网上有不少介绍DebugView使用的文章，但是都忽略了一个事实，那就是默认情况下，使用VS运行程序时候，OutputDebugString的输出是到VS的输出窗口中，DebugView中并没有任何信息。只有单独运行程序的时候，DebugView才能够捕捉到信息。
但是这样就不能结合打断点调试和DebugView两个强大的调试方法了。不过，还是有解决办法的。通过一个叫做DBWin通信机制可以实现调试程序时候，把OutputDebugString的输出信息显示到DebugView窗口中。这套机制的本质是通过内存映射文件来跨进程交换数据。
具体参考以下的类代码：

``` cpp
    class XpcDebugView
    {
    public:
        XpcDebugView() {}
        ~XpcDebugView() {}
        void XpcDebugViewOutput(const char* fm, ...);

    private:
        struct DBWinBuffer
        {
            DWORD ProcessId;
            char Data[4096 - sizeof(DWORD)];
        };
        bool Initialize();
        void UnInitialize();

        HANDLE m_mutex;
        HANDLE m_fileMapping;
        HANDLE m_bufferReadyEvent;
        HANDLE m_dataReadyEvent;
        DBWinBuffer* m_buffer;
    };

    bool XpcDebugView::Initialize()
    {
        m_mutex = OpenMutex(SYNCHRONIZE, FALSE, TEXT("DBWinMutex"));

        //打开DBWIN_BUFFER
        m_fileMapping = OpenFileMapping(FILE_MAP_WRITE, FALSE, TEXT("DBWIN_BUFFER"));

        if (m_fileMapping == NULL) return false;

        //打开DBWIN_BUFFER_READY
        m_bufferReadyEvent = OpenEvent(SYNCHRONIZE, FALSE, TEXT("DBWIN_BUFFER_READY"));

        //打开DBWIN_DATA_READY
        m_dataReadyEvent = OpenEvent(EVENT_MODIFY_STATE, FALSE, TEXT("DBWIN_DATA_READY"));

        //等待DBWIN_BUFFER就绪
        WaitForSingleObject(m_bufferReadyEvent, INFINITE);

        //把DBWIN_BUFFER映射到某个地址
        m_buffer = (DBWinBuffer*)MapViewOfFile(m_fileMapping, FILE_MAP_WRITE, 0, 0, 0);
        m_buffer->ProcessId = GetCurrentProcessId();
    }

    void XpcDebugView::UnInitialize()
    {
        //释放和关闭DBWIN_BUFFER
        FlushViewOfFile(m_buffer, 0);
        UnmapViewOfFile(m_buffer);

        //触发DBWIN_DATA_READY
        SetEvent(m_dataReadyEvent);

        CloseHandle(m_fileMapping);

        //清理
        CloseHandle(m_dataReadyEvent);
        CloseHandle(m_bufferReadyEvent);
        ReleaseMutex(m_mutex);
        CloseHandle(m_mutex);
    }

    void XpcDebugView::XpcDebugViewOutput(const char* fm, ...)
    {
        if (Initialize() == false) return;

        static char szMsg[MAX_PATH];

        va_list argList;
        va_start(argList, fm);
        vsprintf_s(szMsg, fm, argList);
        va_end(argList);

#pragma warning( push )
#pragma warning( disable: 4996 )
        //向DBWIN_BUFFER写入数据
        strcpy(m_buffer->Data, szMsg);
        printf(szMsg);
#pragma warning( pop )

        UnInitialize();
    }
```

使用的时候直接调用类成员函数XpcDebugViewOutput即可。
关于这部分的内容更具体的可以参考文章，[如何让OutputDebugString绕过调试器](http://dooof.lofter.com/tag/DebugView)

## 输出到DebugView的同时输出到Log文件

我将上面的类改造成下面的样子，在初始化时候创建一个Log文件，在反初始化时候关闭Log文件，每次调用XpcDebugViewOutput使用调用fprintf将格式化字符串输出到文件中。这样就能达到输出Log信息到DebugView中的同时，又能够将Log信息持久化保存了。

``` cpp
    class XpcDebugView
    {
    public:
        XpcDebugView() { m_pszLogName = "DefaultLog.txt"; Initialize();  }
        XpcDebugView(const char* pszLogName) { m_pszLogName = pszLogName; Initialize();}
        ~XpcDebugView() { UnInitialize(); }
        void XpcDebugViewOutput(const char* fm, ...);

    private:
        struct DBWinBuffer
        {
            DWORD ProcessId;
            char Data[4096 - sizeof(DWORD)];
        };

        bool Initialize();
        void UnInitialize();

        bool InitializeDBWin();
        void UnInitializeDBWin();

        HANDLE m_mutex;
        HANDLE m_fileMapping;
        HANDLE m_bufferReadyEvent;
        HANDLE m_dataReadyEvent;
        DBWinBuffer* m_buffer;
        const char* m_pszLogName;
        FILE* m_pFileLog;
    };

#pragma warning( push )
#pragma warning( disable: 4996 )
    bool XpcDebugView::Initialize()
    {
        m_pFileLog = fopen(m_pszLogName, "w");
        return m_pFileLog != NULL;
    }

    void XpcDebugView::UnInitialize()
    {
        if (m_pFileLog)
        {
            fclose(m_pFileLog);
        }
    }

    bool XpcDebugView::InitializeDBWin()
    {
        m_mutex = OpenMutex(SYNCHRONIZE, FALSE, TEXT("DBWinMutex"));

        //打开DBWIN_BUFFER
        m_fileMapping = OpenFileMapping(FILE_MAP_WRITE, FALSE, TEXT("DBWIN_BUFFER"));

        if (m_fileMapping == NULL) return false;

        //打开DBWIN_BUFFER_READY
        m_bufferReadyEvent = OpenEvent(SYNCHRONIZE, FALSE, TEXT("DBWIN_BUFFER_READY"));

        //打开DBWIN_DATA_READY
        m_dataReadyEvent = OpenEvent(EVENT_MODIFY_STATE, FALSE, TEXT("DBWIN_DATA_READY"));

        //等待DBWIN_BUFFER就绪
        WaitForSingleObject(m_bufferReadyEvent, INFINITE);

        //把DBWIN_BUFFER映射到某个地址
        m_buffer = (DBWinBuffer*)MapViewOfFile(m_fileMapping, FILE_MAP_WRITE, 0, 0, 0);
        m_buffer->ProcessId = GetCurrentProcessId();
    }

    void XpcDebugView::UnInitializeDBWin()
    {
        //释放和关闭DBWIN_BUFFER
        FlushViewOfFile(m_buffer, 0);
        UnmapViewOfFile(m_buffer);

        //触发DBWIN_DATA_READY
        SetEvent(m_dataReadyEvent);

        CloseHandle(m_fileMapping);

        //清理
        CloseHandle(m_dataReadyEvent);
        CloseHandle(m_bufferReadyEvent);
        ReleaseMutex(m_mutex);
        CloseHandle(m_mutex);
    }

    void XpcDebugView::XpcDebugViewOutput(const char* fm, ...)
    {
        if (InitializeDBWin() == false) return;

        static char szMsg[MAX_PATH];

        va_list argList;
        va_start(argList, fm);
        vsprintf_s(szMsg, fm, argList);
        va_end(argList);

        //向DBWIN_BUFFER写入数据
        strcpy(m_buffer->Data, szMsg);
        if (m_pFileLog)
        {
            fprintf(m_pFileLog, szMsg);
        }

        UnInitializeDBWin();
    }
#pragma warning( pop )
```

## 如何使用XpcDebugView类

最简单的方式是定义一个XpcDebugView的全局变量，比如：
XpcDebugView myDebugview("myLog.txt");
输出Log信息的时候调用函数myDebugview.XpcDebugViewOutput("%d %d %s\n", 1, 2, "log"):
为了方便使用，可以在XpcDebugViewOutput的输出后面添加换行符，这样每次调用后就会自动换行了。
并且加上过滤字符串前缀，这样DebugView就只会捕获我们的输出了。

``` cpp
    void XpcDebugView::XpcDebugViewOutput(const char* fm, ...)
    {
        static char szMsg[MAX_PATH];
        static char szOutput[MAX_PATH];

        va_list argList;
        va_start(argList, fm);
        vsprintf_s(szMsg, fm, argList);
        va_end(argList);

        strcpy(szOutput, "[hankpcxiao] ");
        strcat(szOutput, szMsg);
        strcat(szOutput, "\n");
        if (m_pFileLog)
        {
            fprintf(m_pFileLog, szOutput);
        }

        //向DBWIN_BUFFER写入数据
        if (InitializeDBWin())
        {
            strcpy(m_buffer->Data, szOutput);
            UnInitializeDBWin();
        }
    }
```

# 总结

首先需要下载好DebugView程序，然后配置capture选项，另外是Filter字符串。最后为了保证在VS中调试程序时候，能够将调试信息输出到DebugView，需要使用DBWin通信进制。为此，我封装了一个Log类，在将Log输出到DebugView的同时也将Log输出到日志文件中。

## 参考资料：

&#91;1]    [Frequently asked questions on the Microsoft application DebugView.exe](https://community.sophos.com/kb/en-us/119577)
&#91;2]    [如何让OutputDebugString绕过调试器](http://dooof.lofter.com/tag/DebugView)