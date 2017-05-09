---
title: 如何将内存中的位图数据绘制在DC上
tags:
  - 从内存数据绘制位图
id: 612
categories:
  - MFC
  - UI框架
date: 2012-12-26 10:06:47
---

假如你定义了一个位图类，里面包含位图头，位图信息头，调色板，位图数据。然后你按照位图的格式将位图文件读入你的类中，现在你知道了位图的全部信息了。主要信息包含在位图信息头里面，数据则在位图数据缓冲里面。现在的问题是，在Windows下面如何将一张位图画出来，而且现在是如何从数据缓存里面绘画出位图。
一般情况，我们都是直接绘制在dc里面，而不是绑定到子控件，让子控件自己绘画，比如picture控件之类的，我觉得提供绘制在dc里面的接口更具有广泛性。

现在我知道两种从内存数据绘制彩色位图的2种方法。第一种麻烦一点，第二种则相当直接。
方法一：
第一步，用CreateCompatibleDC创建跟目标dc的兼容性内存dc。
第二步，用CreateCompatibleBitmap创建跟目标dc的兼容性位图。
第三步，用SelectObject将第二步创建的兼容位图选入第一步创建的兼容dc中。
第四步，**用SetDIBits设置兼容位图的数据缓冲**。
第五步，用BitBlt将数据从兼容内存dc绘制到目标dc。
第六步，删除兼容位图和兼容dc。
代码如下，其中buffer代表位图数据缓冲。

``` stylus
HDC hCompatibleDC = CreateCompatibleDC(hDc);
HBITMAP hCompatibleBitmap = CreateCompatibleBitmap(hDc, bitmapinfoheader.biWidth,
bitmapinfoheader.biHeight);
HBITMAP hOldBitmap = (HBITMAP)SelectObject(hCompatibleDC, hCompatibleBitmap);
SetDIBits(hDc, hCompatibleBitmap, 0, bitmapinfoheader.biHeight,
buffer, (BITMAPINFO*)&bitmapinfoheader, DIB_RGB_COLORS);
BitBlt(hDc, nStartX, nStartY, bitmapinfoheader.biWidth, bitmapinfoheader.biHeight,
hCompatibleDC, 0, 0, SRCCOPY);
SelectObject(hCompatibleDC, hOldBitmap);
DeleteObject(hCompatibleDC);
DeleteObject(hCompatibleDC);
```

方法二：**直接调用StretchDIBits绘制位图**。
该函数功能相当强悍，似乎专为从内存数据绘制位图到dc而生。
函数原型如下：
int StretchDIBits(
HDC hdc,                      // handle to DC
int XDest,                    // x-coord of destination upper-left corner
int YDest,                    // y-coord of destination upper-left corner
int nDestWidth,               // width of destination rectangle
int nDestHeight,              // height of destination rectangle
int XSrc,                     // x-coord of source upper-left corner
int YSrc,                     // y-coord of source upper-left corner
int nSrcWidth,                // width of source rectangle
int nSrcHeight,               // height of source rectangle
CONST VOID *lpBits,           // bitmap bits
CONST BITMAPINFO *lpBitsInfo, // bitmap data
UINT iUsage,                  // usage options
DWORD dwRop                   // raster operation code
);
使用也相当简单，调用

``` stylus
StretchDIBits(hDc, nStartX, nStartY, bitmapinfoheader.biWidth,
bitmapinfoheader.biHeight, 0, 0, bitmapinfoheader.biWidth,
bitmapinfoheader.biHeight, buffer, (BITMAPINFO*)&bitmapinfoheader,
DIB_RGB_COLORS, SRCCOPY);
```

即可了。