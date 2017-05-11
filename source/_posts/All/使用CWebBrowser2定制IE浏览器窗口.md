---
title: 使用CWebBrowser2定制IE浏览器窗口
tags:
  - CWebBrowser2
  - 内嵌IE浏览器
  - 定制浏览器弹窗
id: 1804
categories:
  - UI框架
  - - MFC
date: 2016-04-21 21:06:41
---

在客户端程序中嵌入浏览器，有两种方式，一种是使用微软的IE控件，一种是使用CEF。这里介绍的是使用CWebBrowser2类（在MFC程序中插入IE的Active控件生成），定制内嵌浏览器窗口的一些经验。

本文的经验积累于实现逆战退出游戏时候的广告弹窗的过程中，下面Show一下这个自带萌妹子的弹窗吧。

![](https://farm2.staticflickr.com/1575/25953542404_086b3470a8_o.png)

这是一个无边框的Windows对话框程序，并且是一个基于背景图片的不规则弹窗窗口；内部嵌入了一个浏览器控件窗口，这个漂亮的妹子就是浏览器控件打开的网页显示出来的。对这个妹子有兴趣的，可以去玩一把逆战，退出客户端的时候就会出来这个弹窗了。

下面介绍一些关于实现该弹窗浏览器的Tips。

### **一、如何获得CWebBrowser2**

方法1：网络搜索下载，比如我以前的一篇博文里面有下载链接：vc内嵌浏览器。

方法2：在MFC程序中插入IE对应的Activex控件，工程中就会生成这个类。

为了定制浏览器窗口，我继承了该类，自定义了浏览器窗口类CYXBrwser。

### **<span style="color: #444444;">二、让浏览器窗口适应对话框窗口大小</span>**

在对话框类的OnInitDialog()函数中，添加如下代码：

``` cpp?linenums
m_pBrowser = new CYXBrowser(); 
RECT rect; 
GetClientRect(rect);
rect.left += 8;
rect.right -= 8;
rect.top += 8;
rect.bottom -= 1;
m_pBrowser->Create(TEXT("NZBrowser"), WS_CHILD | WS_VISIBLE, rect, this, MY_IEBROWSER_ID);
```
注意，rect的大小需要调节来获得需要的效果。

### **三、屏蔽右键**

有种比较的方法是在PreTranslateMessage中过滤WM_RBUTTONDOWN消息。

``` cpp?linenums
//屏蔽右键
BOOL CYXBrowser::PreTranslateMessage(MSG* pMsg) 
{
    // TODO: Add your specialized code here and/or call the base class
    if(WM_RBUTTONDOWN == pMsg->message)
    {
        //AfxMessageBox(_T("Right Menu!"));
        return TRUE;
    }
    return CWnd::PreTranslateMessage(pMsg);
}
```

### **四、隐藏网页的滚动条**

这是最难处理的一个地方。不仅仅需要修改程序，而且需要web端的配合。

第一步：添加DocumentComplete事件响应。在C***Dlg的cpp中添加如下宏：

``` cpp?linenums
BEGIN_EVENTSINK_MAP(CClientBrowserDlg, CDialog)
    ON_EVENT(CClientBrowserDlg, MY_IEBROWSER_ID, DISPID_DOCUMENTCOMPLETE, DocumentComplete, VTS_DISPATCH VTS_PVARIANT)
END_EVENTSINK_MAP()
```

注意，CClientBrowserDlg是响应函数所在的类，MY_IEBROWSER_ID是二中指定的浏览器窗口ID。DocumentComplete是CClientBrowserDlg中的响应该事件的成员函数。

第二步：实现该函数，直接贴代码。

``` stylus
void CClientBrowserDlg::DocumentComplete(LPDISPATCH pDisp, VARIANT* URL)
{
    UNUSED_ALWAYS(pDisp);
    ASSERT(V_VT(URL) == VT_BSTR);

    CString str(V_BSTR(URL));
    m_pBrowser->OnDocumentComplete(str);
}

void CYXBrowser::OnDocumentComplete(LPCTSTR lpszURL)
{
    m_bDocumentComplete = true;
    HideScrollBar();
}

void CYXBrowser::HideScrollBar()
{
    HRESULT hr;
    IDispatch *pDisp = GetDocument();
    IHTMLDocument2 *pDocument = NULL;
    IHTMLElement*   pEl;  
    IHTMLBodyElement   *pBodyEl;

    if (pDisp)
    {
        hr = pDisp->QueryInterface(IID_IHTMLDocument2, (void**)pDocument);
        if (!SUCCEEDED(hr))
        {
            return;
        }
    }

    if(pDocument  SUCCEEDED(pDocument->get_body(pEl)))  
    {  
        if(pEl  SUCCEEDED(pEl->QueryInterface(IID_IHTMLBodyElement, (void**)pBodyEl)))  
        {  
            pBodyEl->put_scroll(L"no");//去滚动条
        }  
        IHTMLStyle   *phtmlStyle;  
        pEl->get_style(phtmlStyle);

        if(phtmlStyle  != NULL)  
        {  
            phtmlStyle->put_overflow(L"hidden");
            //需要设置网页源码DOCTYPE为<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
            //去除边框才有效
            phtmlStyle->put_border(L"none");//   去除边框

            phtmlStyle->Release();  
            pEl->Release();  
        }  
    } 
}
```

关键函数是HideScrollBar()。

第三步：在浏览器内嵌网页的最前面添加，

``` html
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
```
注意，第三步是不可缺少的。

### **五、屏蔽多次点击浏览器窗口的提示："服务器正在运行中"要选择"切换到..."或"重试"的对话框**

在CClientBrowserDlg::OnInitDialog()中添加如下代码，

``` cpp?linenums
    /*屏蔽掉"服务器正在运行中"要选择"切换到..."或"重试"的对话框*/
    AfxOleGetMessageFilter()->EnableBusyDialog(FALSE);
    AfxOleGetMessageFilter()->SetBusyReply(SERVERCALL_RETRYLATER);
    AfxOleGetMessageFilter()->EnableNotRespondingDialog(TRUE);
    AfxOleGetMessageFilter()->SetMessagePendingDelay(-1);
```

### **六、点击网页打开系统默认浏览器**

第一步：绑定NEWWINDOW2事件。

``` cpp?linenums
ON_EVENT(CClientBrowserDlg, MY_IEBROWSER_ID, DISPID_NEWWINDOW2, OnNewWindow2, VTS_PDISPATCH VTS_PBOOL)
```

第二步：设置该OnNewWindow2的\*bCancel为true，并且调用ShellExecute打开网页。

``` cpp?linenums
void CClientBrowserDlg::OnNewWindow2(LPDISPATCH* ppDisp, BOOL* bCancel)
{
    m_pBrowser->OnNewWindow2(ppDisp, bCancel);
}

void CYXBrowser::OnNewWindow2(LPDISPATCH* ppDisp, BOOL* bCancel)
{
    *bCancel = TRUE;//禁止弹出新窗口（因为会使用IE弹窗）

    HRESULT hr;
    IDispatch *pDisp = GetDocument();
    IHTMLDocument2 *pHTMLDocument2 = NULL;

    if (pDisp)
    {
        hr = pDisp->QueryInterface(IID_IHTMLDocument2, (void**)pHTMLDocument2);
        if (!SUCCEEDED(hr))
        {
            return;
        }
    }

    if (pHTMLDocument2 != NULL)  
    {  
        CComPtr<IHTMLElement> pIHTMLElement;  
        pHTMLDocument2->get_activeElement(pIHTMLElement);  

        if (pIHTMLElement != NULL)  
        {  
            variant_t url;  
            hr = pIHTMLElement->getAttribute(L"href", 0, url);  
            if (SUCCEEDED(hr))  
            {  
                CString strURL(V_BSTR(url));
                //打开默认浏览器
                ShellExecute(m_hWndOwner, NULL, strURL, NULL, NULL, SW_NORMAL);
            }  
        }  
    }     
}
```

处理了六，五也就不需要了，因为点击网页不会再弹出IE浏览器了。

### **七、为网页元素的添加事件处理：比如web按钮的点击等**

第一步：继承CCmdTarget新建类CHtmlEventHandle，代码如下：

``` cpp?linenums
#pragma once

#import <mshtml.tlb>

// CHtmlEventHandle command target
class CYXBrowser;

class CHtmlEventHandle : public CCmdTarget
{
    DECLARE_DYNAMIC(CHtmlEventHandle)

public:
    CHtmlEventHandle();
    virtual ~CHtmlEventHandle();

public:
    void SetWnd(CWnd* pWnd) { m_pWnd = pWnd;}
    void SetWebBrowser(CYXBrowser* pWebBroswer) { m_pWebBrowser = pWebBroswer; }
    // 消息处理函数
    void OnClick(MSHTML::IHTMLEventObjPtr pEvtObj);

private:
    CWnd* m_pWnd;
    CYXBrowser* m_pWebBrowser;

protected:
    DECLARE_MESSAGE_MAP()
    DECLARE_DISPATCH_MAP()
    DECLARE_INTERFACE_MAP()
};

// HtmlEventHandle.cpp : implementation file
//

#include "stdafx.h"
#include "ClientBrowser.h"
#include "HtmlEventHandle.h"
#include "mshtmdid.h"
#include "MsHTML.h"
#include "YXBrowser.h"

// CHtmlEventHandle

IMPLEMENT_DYNAMIC(CHtmlEventHandle, CCmdTarget)

CHtmlEventHandle::CHtmlEventHandle()
{
    EnableAutomation();  // 重要：激活 IDispatch
}

CHtmlEventHandle::~CHtmlEventHandle()
{
}

BEGIN_MESSAGE_MAP(CHtmlEventHandle, CCmdTarget)
END_MESSAGE_MAP()

BEGIN_DISPATCH_MAP(CHtmlEventHandle, CCmdTarget)
    DISP_FUNCTION_ID(CHtmlEventHandle, "HTMLELEMENTEVENTS2_ONCLICK",
    DISPID_HTMLELEMENTEVENTS2_ONCLICK, OnClick,
    VT_EMPTY, VTS_DISPATCH)
END_DISPATCH_MAP()

BEGIN_INTERFACE_MAP(CHtmlEventHandle, CCmdTarget)
    INTERFACE_PART(CHtmlEventHandle,
    DIID_HTMLButtonElementEvents2, Dispatch)
END_INTERFACE_MAP()

// CHtmlEventHandle message handlers

void CHtmlEventHandle::OnClick(MSHTML::IHTMLEventObjPtr pEvtObj)
{
    MSHTML::IHTMLElementPtr pElement =
        pEvtObj->GetsrcElement(); // 事件发生的对象元素
    while(pElement) // 逐层向上检查
    {
        _bstr_t strId;
        pElement->get_id(strId.GetBSTR());
        if(_bstr_t(HTML_CLOSE_BUTTON) == strId)//响应关闭按钮点击
        {
            PostQuitMessage(0);
            break;
        }
        else if (_bstr_t(HTML_SET_BUTTON) == strId)//30天不弹出设置
        {

        }

        pElement = pElement->GetparentElement();
    }
}
//注意那几个宏。宏的具体解释我没有去深究，仿照DISP_FUNCTION_ID可以为点击外的其它事件添加处理。

```

第二步：在CYXBrowser中注册这个web事件处理类。

``` cpp?linenums
//添加成员
private:
    void InstallEventHandler();
    void UninstallEventHandler();

private:
    CHtmlEventHandle *m_pEventHandler;
    DWORD m_dwDocCookie;    // 用于卸载事件响应函数
    IDispatch *m_pDispDoc;  // 用于卸载事件响应函数
    bool m_bDocumentComplete;

//相应的函数实现

// 安装响应函数。省略了一些失败判断以突出主要步骤
void CYXBrowser::InstallEventHandler()
{
    if(m_dwDocCookie)   // 已安装，卸载先。最后一次安装的才有效
        UninstallEventHandler();

    m_pDispDoc = GetDocument();
    IConnectionPointContainerPtr pCPC = m_pDispDoc;
    IConnectionPointPtr pCP;
    // 找到安装点
    pCPC->FindConnectionPoint(DIID_HTMLDocumentEvents2, pCP);
    IUnknown* pUnk = m_pEventHandler->GetInterface(IID_IUnknown);
    //安装
    HRESULT hr = pCP->Advise(pUnk, m_dwDocCookie);
    if(!SUCCEEDED(hr))  // 安装失败
        m_dwDocCookie = 0;
}

// 卸载响应函数。省略了一些失败判断以突出主要步骤
void CYXBrowser::UninstallEventHandler()
{
    if(0 == m_dwDocCookie) return;

    IConnectionPointContainerPtr pCPC = m_pDispDoc;
    IConnectionPointPtr pCP;
    pCPC->FindConnectionPoint(DIID_HTMLDocumentEvents2, pCP);
    HRESULT hr = pCP->Unadvise(m_dwDocCookie);
}

//在OnDocumentComplete中安装事件处理
CYXBrowser::CYXBrowser()
{
    m_pEventHandler = new CHtmlEventHandle;
    m_pEventHandler->SetWnd(m_pParent);
    m_pEventHandler->SetWebBrowser(this);
    m_dwDocCookie = 0;    // 用于卸载事件响应函数
    m_pDispDoc = NULL;  // 用于卸载事件响应函数
    m_bDocumentComplete = false;
}

void CYXBrowser::OnDocumentComplete(LPCTSTR lpszURL)
{
    m_bDocumentComplete = true;
    HideScrollBar();
    InstallEventHandler();
}

//在OnBeforeNavigate2和OnDestroy中卸载处理
// 在 BeforeNavigate2 和 Destroy 事件中卸载响应函数
void CYXBrowser::OnBeforeNavigate2(LPCTSTR lpszURL, DWORD nFlags,
                                   LPCTSTR lpszTargetFrameName, CByteArray baPostedData,
                                   LPCTSTR lpszHeaders, BOOL* pbCancel)
{
    UninstallEventHandler();
    // 其他代码...
}

void CYXBrowser::OnDestroy()
{
    UninstallEventHandler();
    CWebBrowser2::OnDestroy();
}
```
现在就可以在void CHtmlEventHandle::OnClick(MSHTML::IHTMLEventObjPtr pEvtObj)函数内捕获网页按钮之类的点击了。处理代码的思路是从当前元素开始，不断往上查找父元素，直到匹配的元素ID为止。

### **八、判断url是否有效，如果无效则打开资源url，防止Web页面为空**

``` cpp?linenums
//使用该函数判断url是否能打开
bool CYXBrowser::IsUrlAvailable(CString strUrl)
{
    CInternetSession* session = new CInternetSession(); 
    CInternetFile* file = NULL; 
    bool bAvailable = true;

    try
    {
        file = (CInternetFile*)session->OpenURL(strUrl); 
    }
    catch (CInternetException*)
    {
        bAvailable = false;
    }

    delete session;
    if (!file)
    {
        bAvailable = false;
    }

    return bAvailable;
}

//在对话框初始化时候，判断外网url是否能打开，如果不能则加载资源内的url
if (m_pBrowser->IsUrlAvailable(theApp.m_strUrl))
{
    m_pBrowser->Navigate2(theApp.m_strUrl);
}
else
{
    TCHAR szModule[MAX_PATH];
    GetModuleFileName(theApp.m_hInstance, szModule, MAX_PATH);
    theApp.m_strUrl.Format(_T("res://%s/%s"), szModule, theApp.m_strLocalUrl);
    m_pBrowser->Navigate2(theApp.m_strUrl);
}
```

注意资源url的格式是res://模块名/网页名，因此需要在该程序中导入自定义的资源，并且将其命名为theApp.m_strLocalUrl代表的字符串值，比如”NZ.HTML”。