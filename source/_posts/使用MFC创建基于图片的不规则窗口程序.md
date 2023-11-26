---
title: 使用MFC创建基于图片的不规则窗口程序
tags:
  - MFC
id: 1863
categories:
  - MFC
date: 2016-04-23 20:45:25
---

上一篇文章定制IE浏览器弹窗中的外部窗口就是一个不规则窗口，这篇文章介绍下其是如何实现的。思路是根据这张图片创建一个不规则区域，然后将窗口的区域设置为该不规则区域。



## **第一步，在资源文件rc中设置对话框的属性**

Border：None

Style：Popup



## **第二步，导入背景图片到程序资源中**

最好是导入位图，虽然也可以导入其它格式的图片。假设导入位图ID为IDB_BITMAP_BACK。



## **第三步，在OnInitialDlg函数中，创建区域，并将其设置为窗口区域**

``` cpp?linenums
//OnInitDialog()中
CRgn wndRgn;

m_bitmapBack.LoadBitmap(IDB_BITMAP_BACK);
CreateRgn(m_bitmapBack, RGB(255, 255, 255), wndRgn);
SetWindowRgn(wndRgn, TRUE);

//根据图片创建区域的函数
void CClientBrowserDlg::CreateRgn(CBitmap cBitmap, COLORREF dwColorKey, CRgn wndRgn)  
{  
    CDC *pDC = this->GetDC();  
    CDC memDC;  
    //创建与传入DC兼容的临时DC  
    memDC.CreateCompatibleDC(pDC);  

    CBitmap *pOldMemBmp=NULL;  
    //将位图选入临时DC  
    pOldMemBmp = memDC.SelectObject(cBitmap);  

    //创建总的窗体区域，初始region为0  
    wndRgn.CreateRectRgn(0,0,0,0);  

    BITMAP bit;     
    cBitmap.GetBitmap (bit);//取得位图参数，这里要用到位图的长和宽       

    int y;  
    for(y=0; y <= bit.bmHeight; y++)  
    {  
        CRgn rgnTemp;  
        int iX = 0;  
        do  
        {  
            //跳过透明色找到下一个非透明色的点.  
            while (iX <= bit.bmWidth   memDC.GetPixel(iX, y) == dwColorKey)  
                iX++;  
            //记住这个起始点  
            int iLeftX = iX;  
            //寻找下个透明色的点  
            while (iX <= bit.bmWidth   memDC.GetPixel(iX, y) != dwColorKey)  
                ++iX;  
            //创建一个包含起点与重点间高为1像素的临时“region”  
            rgnTemp.CreateRectRgn(iLeftX, y, iX, y+1);  
            //合并到主"region".  
            wndRgn.CombineRgn(wndRgn, rgnTemp, RGN_OR);  
            //删除临时"region",否则下次创建时和出错  
            rgnTemp.DeleteObject();  
        } while(iX < bit.bmWidth );  
        iX = 0;  
    }  

    if(pOldMemBmp)  
        memDC.SelectObject(pOldMemBmp);  
}
```

## **第四步，在OnPaint()绘制窗口背景图片**
``` cpp?linenums
void CClientBrowserDlg::OnPaint()
{
    if (IsIconic())
    {
        CPaintDC dc(this); // device context for painting

        SendMessage(WM_ICONERASEBKGND, reinterpret_cast<WPARAM>(dc.GetSafeHdc()), 0);

        // Center icon in client rectangle
        int cxIcon = GetSystemMetrics(SM_CXICON);
        int cyIcon = GetSystemMetrics(SM_CYICON);
        CRect rect;
        GetClientRect(rect);
        int x = (rect.Width() - cxIcon + 1) / 2;
        int y = (rect.Height() - cyIcon + 1) / 2;

        // Draw the icon
        dc.DrawIcon(x, y, m_hIcon);
    }
    else
    {
        //选入DC  
        CClientDC cdc(this);
        CDC comdc;  
        comdc.CreateCompatibleDC(cdc);  
        comdc.SelectObject(m_bitmapBack);  

        //生成BITMAP  
        BITMAP bit;  
        m_bitmapBack.GetBitmap(bit);  

        //客户区域  
        CRect rect;  
        GetClientRect(rect);

        //用客户区的DC绘制所生成的BITMAP，并适应为窗口大小  
        cdc.StretchBlt(0,0,rect.Width(),rect.Height(),comdc,0,0,bit.bmWidth,bit.bmHeight,SRCCOPY);

        CDialog::OnPaint();
    }
}
```

## **第五步，点击客户区移动窗口**

这一点还是有意义的，比如上一篇定制IE浏览器窗口的文章，其外部窗口就是使用这里介绍的不规则窗体。不规则窗体由于是无边框的，因此无法点击边框移动窗口了。因此，设置点击客户端移动是有意义的。而**且窗口的内部区域已经被浏览器控件占据了，只有外部的边界区域可以点击到，因此这样刚好模拟出了点击正常窗口边框的效果。**

设置客户区可以点击的代码如下：

``` cpp?linenums
LRESULT CClientBrowserDlg::OnNcHitTest(CPoint point)
{
    // TODO: Add your message handler code here and/or call default
    // 取得鼠标所在的窗口区域
    UINT nHitTest = CDialog::OnNcHitTest(point);

    // 如果鼠标在窗口客户区，则返回标题条代号给Windows
    // 使Windows按鼠标在标题条上类进行处理，即可单击移动窗口
    return (nHitTest == HTCLIENT) ? HTCAPTION : nHitTest;
    //return CDialog::OnNcHitTest(point);
}
```