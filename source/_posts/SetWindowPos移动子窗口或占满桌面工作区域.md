---
title: SetWindowPos移动子窗口或占满桌面工作区域
tags:
  - MFC
  - SetWindowPos
id: 591
categories:
  - UI框架
  - MFC
date: 2012-12-20 17:06:42
---

该函数原型如下，
BOOL SetWindowPos(
HWND hWnd, // handle to window
HWND hWndInsertAfter, // placement-order handle
int X, // horizontal position
int Y, // vertical position
int cx, // width
int cy, // height
UINT uFlags // window-positioning options
);

第一个参数是你要修改的窗口局部，第二个参数是用于修改Z order的，可以用这个参数把你的窗口弄成TopMost之类的窗口，后面四个参数很好理解，最后那个参数是一些标志，具体的请查看msdn。
基本上我觉得使用这个函数有些时候达不到你想要的效果原因是不知道这个函数使用的坐标系其实不是桌面坐标系，也不是当前窗口的客户区坐标系，**而是父窗口的客户区坐标系**。这个点可能在你移动非子窗口的时候没有什么影响，但是你想移动子窗口的时候就会出问题了，老是达不到你想要的效果那是非常烦人的，而你debug进去发现你的数据又都是对的。当你意识到该函数使用的坐标系的时候，对应的问题就都能够解决了。

我列举2个例子，一个是设置窗口为顶级窗口同时修改为覆盖整个桌面工作区，另一个是移动子窗口对话框到主对话框的客户区左上角。2个例子都在我的代码内部，后面我会提供代码下载。

**例子一，设置窗口为顶级窗口同时修改为覆盖整个桌面工作区。**
将下面的代码放在你的主对话框的OnInitDialog()函数内部就能够达到例子一的效果了。

``` stylus
RECT rect;
SystemParametersInfo(SPI_GETWORKAREA, 0, (PVOID)rect, 0);
m_nScreenWidth = rect.right - rect.left;
m_nScreenHeight = rect.bottom - rect.top;
SetWindowPos(wndTop, rect.left, rect.top, m_nScreenWidth, m_nScreenHeight, SWP_SHOWWINDOW);
```

**例子二，移动子窗口对话框到主对话框的客户区左上角。**
这个例子的实现比较麻烦，首先修改子对话框的资源文件里面的属性，一定改成child类型的对话框。其次，用非模式对话框创建出子对话框，同时注意把主对话框最为其父窗口。最后只需要在child对话框的OnInitDialog()函数里面调用SetWindowPos(wndTop, 0, 0, 0, 0, SWP_NOSIZE);//移动子窗口,则坐标是相对于父窗口客户区就能达到效果了。这三个操作是缺一不可的。

代码下载地址，[实验二](https://pan.baidu.com/s/1bpBgvi3)。