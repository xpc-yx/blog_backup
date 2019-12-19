---
title: MFC的单文档(SDI)的CMainFrame中添加托盘
tags:
  - 系统托盘
id: 1096
categories:
  - MFC
date: 2014-02-26 17:32:31
---

第一步，在CMainFrame中定义NOTIFYICONDATA结构m_notify。

第二步，在OnCreate中添加下面的代码。代码的解释参见注释。

``` stylus
    m_notify.cbSize = sizeof(NOTIFYICONDATA);//结构体大小
    m_notify.hWnd = m_hWnd;//对应窗口
    m_notify.uID = IDR_MAINFRAME;//托盘id
    m_notify.hIcon = LoadIcon(AfxGetInstanceHandle(), MAKEINTRESOURCE(IDR_MAINFRAME));//图标
    strcpy(m_notify.szTip, "ConuterPerDay");//提示字符
    m_notify.uCallbackMessage = WM_USER_NOTIFYICON;//处理消息
    m_notify.uFlags = NIF_ICON | NIF_MESSAGE | NIF_TIP; //有效标志
    Shell_NotifyIcon(NIM_ADD, m_notify);//添加托盘
```

需要注意的是，m_notify.uFlags必须设置正确，如果不正确，那么有些功能是不会有效的，还有m_notify.cbSize也是必须设置的。
第三步，在MainFrame.h中添加宏定义#define WM_USER_NOTIFYICON (WM_USER + 100)，再定义对应的消息处理函数，afx_msg LRESULT OnNotifyMsg(WPARAM wparam, LPARAM lparam);注意该函数的格式。这是普通的消息处理函数，消息的参数必须带全。再在源文件中的BEGIN_MESSAGE_MAP和END_MESSAGE_MAP()之间添加消息映射ON_MESSAGE(WM_USER_NOTIFYICON, OnNotifyMsg)。
第四步，实现OnNotifyMsg。我的OnNotifyMsg实现如下：

``` stylus
// CMainFrame 消息处理程序
LRESULT  CMainFrame::OnNotifyMsg(WPARAM wparam, LPARAM lparam)//wParam接收的是图标的ID，而lParam接收的是鼠标的行为
{
    if (wparam != IDR_MAINFRAME) return  1;

    CPoint pos;
    CMenu    menu;
    switch (lparam)
    {
    case  WM_RBUTTONUP://右键起来时弹出快捷菜单，这里只有一个“关闭”
        GetCursorPos(pos);
        menu.CreatePopupMenu();//声明一个弹出式菜单
        //增加菜单项“关闭”，点击则发送消息WM_DESTROY给主窗口（已
        //隐藏），将程序结束。
        menu.AppendMenu(MF_STRING, WM_USER_EXIT, "关闭");
        //确定弹出式菜单的位置
        SetForegroundWindow();
        menu.TrackPopupMenu(TPM_LEFTALIGN | TPM_RIGHTBUTTON, pos.x, pos.y, this);
        menu.DestroyMenu();
        break;

    case  WM_LBUTTONDBLCLK://双击左键的处理
        if (IsWindowVisible())
        {
            ShowWindow(SW_HIDE);
        }
        else
        {
            ShowWindow(SW_SHOW);//简单的显示主窗口完事儿
        }
        break;
    }

    return 0;
}
```

值得注意的是menu.AppendMenu(MF_STRING, WM_USER_EXIT, "关闭");，我用了自定义的消息WM_USER_EXIT而不是WM_DESTROY。刚开始我参照别人的代码，使用WM_DESTROY，结果弹出菜单一直是灰色的。我换成WM_CLOSE也是一样的效果。没办法，我就试了下自定义消息。刚开始我采样的是普通类型的消息映射处理该菜单消息，菜单也是灰色的。**直到最后我用ON_COMMAND映射菜单消息，菜单才能够点击**。
第四步，在MainFrame.h中添加宏定义#define WM_USER_EXIT (WM_USER + 101)，再定义对应的消息处理函数，aafx_msg void OnExit();注意该函数的格式，与第三步不同，因为这是命令消息。再在源文件中的BEGIN_MESSAGE_MAP和END_MESSAGE_MAP()之间添加消息映射ON_COMMAND(WM_USER_EXIT, OnExit)。第四步是使弹出菜单能够点击的关键。我在OnExit直接调用DestroyWindow退出程序。
第五步，重载WM_CLOSE，在其中调用ShowWindow(SW_HIDE);。这样点击关闭按钮则进入托盘状态，而点击最小化按钮在任务栏上有程序的图标。
第六步，重载WM_DESTROY，程序退出时候删除托盘。对应代码如下：

``` stylus
void CMainFrame::OnDestroy()
{
    CFrameWndEx::OnDestroy();

    NOTIFYICONDATA tnid;
    tnid.cbSize = sizeof(NOTIFYICONDATA);
    tnid.hWnd = m_hWnd;
    tnid.uID = IDR_MAINFRAME;
    //用NIM_DELETE删除图标
    Shell_NotifyIcon(NIM_DELETE, tnid);
}
```

至此，实现了一个SDI框架下，完整的托盘程序。
我写这篇文章的目的是为了说明ON_MESSAGE和ON_COMMAND的区别。**ON_COMMAND对应的普通的windows消息，ON_COMMAND则对应的是菜单和按钮之类的命令消息，需要区别对待**。也就是处理不同类型的消息，需要使用不同类型的消息处理函数。如果消息处理函数类型不正确，有可能出现问题。比如，弹出菜单一直是灰色。