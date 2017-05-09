---
title: OpenGL使用位图纹理
tags:
  - OpenGL
  - 图形学
  - 纹理
id: 732
categories:
  - OpenGL
  - 图形学
date: 2013-03-24 16:47:34
---

使用位图纹理主要需要注意2个地方。1个是**非二次方纹理的处理**，这个可以参考我[上一篇文章](http://www.xpc-yx.com/2013/03/opengl%E5%A6%82%E4%BD%95%E4%BD%BF%E7%94%A8%E9%95%BF%E5%AE%BD%E9%9D%9E2%E6%AC%A1%E6%96%B9%E7%9A%84%E7%BA%B9%E7%90%86/)的。另外一个是需要注意**位图数据的格式**，24位的是BGR而不是RGB,32位的是BGRA，而不是RGBA，所以用glTexImage2D之类的函数需要注意把format改成**GL_BGR_EXT**或者**GL_BGRA_EXT**，但是internalformat必须是GL_RGB或者GL_RGBA，如果没有进行这个处理的话，颜色效果会变掉的。
下面我给出我的一个任务里面所实现的bitmap位图类，我加载数据的时候使用了以前实现的类CxBitmap，这个也可以从我的另一篇文章中得到。整个类还是比较简单的，你也可以修改加载文件的代码，从而不需要使用CxBitmap类。

CBitmapTex类的定义如下：

``` stylus
#ifndef XPC_YX_BITMAPTEX_H
#define XPC_YX_BITMAPTEX_H
#include

#define RGB16(r,g,b)   ( ((r>>3) << 10) + ((g>>3) << 5) + (b >> 3) )
#define RGB24(r,g,b)   ( ((r) << 16) + ((g) << 8) + (b) )

class CBitmapTex
{
public:
    CBitmapTex() { m_byData = 0; m_szTexName[0] = 0; }
    CBitmapTex(const char* pcszFileName) { m_byData = 0; LoadBitmapTex(pcszFileName); }
    ~CBitmapTex() { if (m_byData) free(m_byData); }
    int LoadBitmapTex(const char* pcszFileName);
    void InitTex();
    void SetTexture();

private:
    int m_nWidth;
    int m_nHeight;
    int m_nBytesPerPixel;
    BYTE* m_byData;
    char m_szTexName[MAX_PATH];
    unsigned m_uTexName;
    double m_fTexScaleX;
    double m_fTexScaleY;
};

#endif
```

CBitmapTex的实现如下，

``` stylus
#include "bitmapTex.h"
#include "CxBitmap.h"
#include "tool.h"
#include
#include
#include

//该函数只处理了没有压缩的格式
int CBitmapTex::LoadBitmapTex(const char* pcszFileName)
{
    CxBitmap* pBitmap = new CxBitmap;
    int i;
    int nBytesPerLine;

    strcpy(m_szTexName, pcszFileName);
    if (pBitmap->LoadBitmap(pcszFileName) == NULL)
    {
        return 0;
    }
    m_nWidth = pBitmap->GetWidth();
    m_nHeight = pBitmap->GetHeight();
    m_nBytesPerPixel = pBitmap->GetBytesPerPixel();
    m_byData = (BYTE*)malloc(m_nWidth * m_nHeight * m_nBytesPerPixel);
    if (m_byData == NULL)
    {
        return 0;
    }
    nBytesPerLine = m_nWidth * m_nBytesPerPixel;
    if (pBitmap->GetBytesPerLine() == nBytesPerLine)
    {
        //拷贝数据
        memcpy(m_byData, pBitmap->GetBuffer(), m_nHeight * m_nWidth * m_nBytesPerPixel);
    }
    else//注意文件内部的bitmap数据已经对齐,但是opengl纹理的数据不能对其,所以必须一行行拷贝
    {   //否则会出现纹理变形
        for (i = 0; i < m_nHeight; ++i)         {           memcpy(m_byData + i * nBytesPerLine, pBitmap->GetBuffer()
                + i * pBitmap->GetBytesPerLine(), nBytesPerLine);//拷贝数据
        }
    }

    delete pBitmap;

    return 1;
}

void CBitmapTex::InitTex()
{
    int nFormat;
    int nWidthPowerOfTwo = ::Pow2Big(m_nWidth);
    int nHeightPowerOfTwo = ::Pow2Big(m_nHeight);

    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glGenTextures(1, m_uTexName);
    glBindTexture(GL_TEXTURE_2D, m_uTexName);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);

    if (m_nBytesPerPixel == 3)
    {
        nFormat = GL_BGR_EXT;
    }
    else if (m_nBytesPerPixel == 4)
    {
        nFormat = GL_BGRA_EXT;//bitmap内部数据是bgra格式,所以输入格式必须变化下
    }

    if (nWidthPowerOfTwo == m_nWidth  nHeightPowerOfTwo == m_nHeight)
    {
        //输出格式必须是GL_RGB,写成GL_BGR_EXT会出现空白
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, nWidthPowerOfTwo, nHeightPowerOfTwo,
            0, nFormat, GL_UNSIGNED_BYTE, m_byData);
        m_fTexScaleX = m_fTexScaleY = 1.0;
    }
    else
    {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, nWidthPowerOfTwo, nHeightPowerOfTwo,
        0, nFormat, GL_UNSIGNED_BYTE, NULL);
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, m_nWidth, m_nHeight,
        nFormat, GL_UNSIGNED_BYTE, m_byData);
        m_fTexScaleX = 1.0 * m_nWidth / nWidthPowerOfTwo;
        m_fTexScaleY = 1.0 * m_nHeight / nHeightPowerOfTwo;
    }
}

void CBitmapTex::SetTexture()
{
    glBindTexture(GL_TEXTURE_2D, m_uTexName);
    //设置纹理堆栈
    glMatrixMode(GL_TEXTURE);
    glLoadIdentity();
    glScaled(m_fTexScaleX, m_fTexScaleY, 1.0);
}
```

注意到我的实现中使用了CxBitmap类，你可以从[这篇文章](http://www.xpc-yx.com/2013/01/%E4%BD%8D%E5%9B%BE%E6%95%B0%E5%AD%97%E5%9B%BE%E5%83%8F%E5%A4%84%E7%90%86%E7%B1%BBcxbitmap/)中得到。还使用tool.h中的一个函数Pow2Big，该然后是返回一个刚好比输入参数大的2的次方大小，实现很简单。
该类只需要先调用LoadBitmapTex读入数据之后，再调用InitTex初始化opengl的一些纹理设置，最后需要使用哪个纹理，就用哪个纹理对象调用SetTexture函数就行了，非常方便。