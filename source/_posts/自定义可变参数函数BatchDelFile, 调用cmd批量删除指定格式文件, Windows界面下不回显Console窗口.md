---
title: '自定义可变参数函数BatchDelFile, 调用cmd批量删除指定格式文件, Windows界面下不回显Console窗口'
tags:
id: 93
categories:
  - C/C++
date: 2012-01-03 10:00:00
---

今天在做课设，由于想给程序加上删除以前的配置文件的功能，由于某种原因，同类型的文件比较多，加上暑假实习的时候，做了个用dir命令实现的批量文件修改器，所以决定用del命令，一下子写好后，发现以前由于没有要求做界面，而现在课设我用的是MFC里面的CFormView做的界面，所以会闪烁而过一个console窗口，实在不爽之，所以，找方法去掉它。
网上找来找去，只找到启动cmd，传参数的都很少，传参数时候组合参数的更加少，加上我对dos命令不熟悉，所以实在悲催，浪费了不少时间。
这种东西，一直窃以为有人做好之后，提供比较合格的接口，大家以后都方便，所以贴出来，大家雅俗共赏，批评下。还发现网上的代码有个问题，居然大多把直接cmd路径写上去，其实大家都知道，系统路径是不确定的，所以特定修正了这个bug，而且我也实验了下，无论参数是绝对路径还是相对路径这个函数都是有效的。
大家用这个函数的时候，记得cmd命令都是可以匹配通配符的哦。

函数代码如下:

//批量删除指定格式文件,不显示console窗口

``` stylus
void BatchDelFile(char* pszFile)
{
    char szDelCmd[MAX_INFO_LEN];
    char szCurDir[MAX_PATH];
    char szCmdPath[MAX_PATH];
    SHELLEXECUTEINFO shExecInfo = {0};

    GetCurrentDirectory(MAX_PATH, szCurDir);//获取当前路径
    GetSystemDirectory(szCmdPath, MAX_PATH);//获取cmd路径
    strcat(szCmdPath, "\\cmd.exe");
    sprintf(szDelCmd, "%s /c del /f /q /s %s",
    szCmdPath, pszFile);//格式化出命令字符串, 注意加上/c, 还有那2个""

    shExecInfo.cbSize = sizeof(SHELLEXECUTEINFO);
    shExecInfo.fMask = SEE_MASK_NOCLOSEPROCESS;
    shExecInfo.hwnd = NULL;
    shExecInfo.lpVerb = NULL;
    shExecInfo.lpFile = szCmdPath;//cmd的路径
    shExecInfo.lpParameters = szDelCmd;//程序参数,参数格式必须保证正确
    shExecInfo.lpDirectory = szCurDir;//如果szFile是相对路径,那个这个参数就会起作用
    shExecInfo.nShow = SW_HIDE;//隐藏cmd窗口
    shExecInfo.hInstApp = NULL;
    ShellExecuteEx(&shExecInfo);
    WaitForSingleObject(shExecInfo.hProcess, INFINITE);//无限等待cmd窗口执行完毕
}
```

以下是我在一个消息出来函数的调用：
char szDelFiles[MAX_PATH];
sprintf(szDelFiles, "\"*.tcp.txt\" + \"*.udp.txt\"");
BatchDelFile(szDelFiles);

为了调用方便，我还实现了一个可变参数列表的版本，以及一个传一个文件名数组的版本。

可变参数版本代码如下：
//批量删除指定格式文件,不显示console窗口

``` stylus
void BatchDelFile(int nNum, ...)
{
    va_list argPtr;
    int i;
    char* pszDelCmd;
    char szCurDir[MAX_PATH];
    char szCmdPath[MAX_PATH];
    SHELLEXECUTEINFO shExecInfo = {0};

    pszDelCmd = (char*)malloc((nNum + 2)* MAX_PATH);
    GetCurrentDirectory(MAX_PATH, szCurDir);//获取当前路径
    GetSystemDirectory(szCmdPath, MAX_PATH);//获取cmd路径
    strcat(szCmdPath, "\\cmd.exe");
    sprintf(pszDelCmd, "%s /c del /f /q /s ", szCmdPath);//格式化出命令字符串, 注意加上/c
    va_start(argPtr, nNum);
    for(i = 0; i < nNum; ++i)
    {
        strcat(pszDelCmd, "\"");
        strcat(pszDelCmd, *(char**)argPtr);
        strcat(pszDelCmd, "\"");
        if (i != nNum - 1)
        {
            strcat(pszDelCmd, " + ");
        }
        va_arg(argPtr, char**);
    }
    va_end(argPtr);
    shExecInfo.cbSize = sizeof(SHELLEXECUTEINFO);
    shExecInfo.fMask = SEE_MASK_NOCLOSEPROCESS;
    shExecInfo.hwnd = NULL;
    shExecInfo.lpVerb = NULL;
    shExecInfo.lpFile = szCmdPath;//cmd的路径
    shExecInfo.lpParameters = pszDelCmd;//程序参数,参数格式必须保证正确
    shExecInfo.lpDirectory = szCurDir;//如果szFile是相对路径,那个这个参数就会起作用
    shExecInfo.nShow = SW_HIDE;//隐藏cmd窗口
    shExecInfo.hInstApp = NULL;
    ShellExecuteEx(&shExecInfo);
    WaitForSingleObject(shExecInfo.hProcess, INFINITE);//无限等待cmd窗口执行完毕
    free(pszDelCmd);
}
```

调用方法：
BatchDelFile(2, "*.tcp.txt", "*.udp.txt");//第一个是文件个数，后面依次是文件路径，文件路径可以是相对路径也可以是绝对路径。

文件名数组的版本代码如下：

``` stylus
void BatchDelFile(int nNum, char** pszFiles)
{
    int i;
    char* pszDelCmd;
    char szCurDir[MAX_PATH];
    char szCmdPath[MAX_PATH];
    SHELLEXECUTEINFO shExecInfo = {0};

    pszDelCmd = (char*)malloc((nNum + 2)* MAX_PATH);
    GetCurrentDirectory(MAX_PATH, szCurDir);//获取当前路径
    GetSystemDirectory(szCmdPath, MAX_PATH);//获取cmd路径
    strcat(szCmdPath, "\\cmd.exe");
    sprintf(pszDelCmd, "%s /c del /f /q /s ", szCmdPath);//格式化出命令字符串, 注意加上/c

    for(i = 0; i < nNum; ++i)
    {
        strcat(pszDelCmd, "\"");
        strcat(pszDelCmd, *(pszFiles + i));
        strcat(pszDelCmd, "\"");
        if (i != nNum - 1)
        {
            strcat(pszDelCmd, " + ");
        }
    }
    shExecInfo.cbSize = sizeof(SHELLEXECUTEINFO);
    shExecInfo.fMask = SEE_MASK_NOCLOSEPROCESS;
    shExecInfo.hwnd = NULL;
    shExecInfo.lpVerb = NULL;
    shExecInfo.lpFile = szCmdPath;//cmd的路径
    shExecInfo.lpParameters = pszDelCmd;//程序参数,参数格式必须保证正确
    shExecInfo.lpDirectory = szCurDir;//如果szFile是相对路径,那个这个参数就会起作用
    shExecInfo.nShow = SW_HIDE;//隐藏cmd窗口
    shExecInfo.hInstApp = NULL;
    ShellExecuteEx(& shExecInfo);
    WaitForSingleObject(shExecInfo.hProcess, INFINITE);//无限等待cmd窗口执行完毕
    free(pszDelCmd);
}
```

调用方法：
``` stylus
char* szFiles[2];
szFiles[0] = "*.tcp.txt";
szFiles[1] = "*.udp.txt";
BatchDelFile(2, szFiles);
```
