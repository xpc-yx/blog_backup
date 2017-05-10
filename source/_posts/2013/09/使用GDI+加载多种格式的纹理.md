---
title: 使用GDI+加载多种格式的纹理
tags:
  - GDI+
  - OpenGL
  - 纹理
id: 897
categories:
  - 图形图像
  - 图形学
  - OpenGL
date: 2013-09-12 12:16:45
---

今天在做一个缩略图的控件的时候发现，CXImage库在VS2010的debug模型下有内存泄露，这可是我查错查了几个小时最后得出的结论。瞬间觉得很不爽，就不用CxImage了。觉得加载不同种格式的需求，GDI+应该能够满足我的要求。那么久果断改为GDI+了。GDI+我也没使用过，果断只能搜索其用法了。
后面发现只需要使用Gdiplus::Bitmap就可以处理多种格式的图片。虽然该类叫做位图，实际上可以处理多种格式，据说从Gdiplus::Image继承而来。
nsp; 使用GDI+据说在vs2010下也不需要初始化该库，vc6和vs2008下面需要初始化。初始化也很简单，在App里面包含个成员ULONG_PTR m_gdiplusToken，在InitInstance里面加上Gdiplus::GdiplusStartupInput gdiplusStartupInput;Gdiplus::GdiplusStartup(m_gdiplusToken, gdiplusStartupInput, NULL);在ExitInstance里面加上Gdiplus::GdiplusShutdown(m_gdiplusToken);就行了。
由于GDI+使用的是Unicode，而我一般用的是多字节工程，所以还需要将图片名字转换为Unicode。具体过程是先把图片名字转换为Unicode，再用Gdiplus::Bitmap类的对象bitmap加载图片，然后锁定图片数据，申请一块数据从bitmap内部提取出像素数据，然后释放图片数据，剩下的就是ogl的操作了。
代码如下：

``` stylus
#ifndef XPC_YX_TEXTURE_H
#define XPC_YX_TEXTURE_H

class CxImage;

class CTexture
{
public:
    CTexture() { m_byData = NULL; m_szTexName[0] = 0; }
    CTexture(const char* pcszFileName) { m_byData = 0; LoadFromFile(pcszFileName); }
  ~CTexture();
    int LoadFromFile(const char* pcszFileName);
  void Init2DTex();
  void Init1DVertTex();

private:
  int m_nWidth;
  int m_nHeight;
    BYTE* m_byData;
    char m_szTexName[MAX_PATH];
  WCHAR m_char16ImgName[MAX_PATH];
    unsigned m_uTexName;
  double m_fTexScaleX;
    double m_fTexScaleY;
};

#endif
```

``` stylus
#include "stdafx.h"
#include "Texture.h"
#include "CxImage/ximage.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

//该函数只处理了没有压缩的格式
/*int CTexture::LoadFromFile(const char* pcszFileName)
{
  if (pcszFileName != NULL)
  {
    strcpy(m_szTexName, pcszFileName);
  }
  CxImage image;

  image.Load(pcszFileName);
  if (image.IsValid() == false)
  {
    return 0;
  }

  m_nWidth = image.GetWidth();
  m_nHeight = image.GetHeight();
  if (m_byData)
  {
    delete m_byData;
    m_byData = NULL;
  }
  m_byData = new BYTE[m_nWidth * m_nHeight * 3];
  for (int i = 0; i < m_nHeight; ++i)
  {
    for (int j = 0; j < m_nWidth; ++j)
    {
      RGBQUAD rgb = image.GetPixelColor(j, i);
      m_byData[(i * m_nWidth + j) * 3] = rgb.rgbRed;
      m_byData[(i * m_nWidth + j) * 3 + 1] = rgb.rgbGreen;
      m_byData[(i * m_nWidth + j) * 3 + 2] = rgb.rgbBlue;
    }
  }

  for (int i = 0; i < m_nHeight; i += 5)
  {
    for (int j = 0; j < m_nWidth; ++j)
    {
      m_byData[(i * m_nWidth + j) * 3] = 0;
      m_byData[(i * m_nWidth + j) * 3 + 1] = 0;
      m_byData[(i * m_nWidth + j) * 3 + 2] = 0;
    }
  }

  return 1;
}*/

int CTexture::LoadFromFile(const char* pcszFileName)
{
  if (pcszFileName != NULL)
  {
    strcpy(m_szTexName, pcszFileName);
  }

  int nStrLen = strlen(pcszFileName);
  int nLen = MultiByteToWideChar(CP_ACP, 0, pcszFileName, nStrLen, NULL, 0);
  MultiByteToWideChar(CP_ACP, 0, pcszFileName, nStrLen, m_char16ImgName, nLen);
  m_char16ImgName[nLen] = '\0'; //添加字符串结尾，注意不是len+1*/

  Gdiplus::Bitmap image(m_char16ImgName);

  m_nWidth = image.GetWidth();
  m_nHeight = image.GetHeight();
  Gdiplus::Rect rect(0, 0, m_nWidth, m_nHeight);
  Gdiplus::BitmapData bitmapData;
  image.LockBits(rect, Gdiplus::ImageLockModeRead | Gdiplus::ImageLockModeWrite,
    PixelFormat24bppRGB,  bitmapData);

  if (m_byData)
  {
    delete m_byData;
    m_byData = NULL;
  }
  m_byData = new BYTE[m_nWidth * m_nHeight * 3];

  BYTE* pByte = (BYTE*)bitmapData.Scan0;
  int nOffset = bitmapData.Stride - m_nWidth * 3;
  for (int i = 0; i < m_nHeight; ++i)
  {
    for (int j = 0; j < m_nWidth; ++j)
    {
      m_byData[(i * m_nWidth + j) * 3] = pByte[0];
      m_byData[(i * m_nWidth + j) * 3 + 1] = pByte[1];
      m_byData[(i * m_nWidth + j) * 3 + 2] = pByte[2];
      pByte += 3;
    }
    pByte += nOffset;
  }
  image.UnlockBits(bitmapData);

  return 1;
}

void CTexture::Init2DTex()
{
  glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
  glGenTextures(1, m_uTexName);
  glBindTexture(GL_TEXTURE_2D, m_uTexName);

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);
  glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);

  int nRet = gluBuild2DMipmaps(GL_TEXTURE_2D, 3, m_nWidth, m_nHeight, GL_RGB, GL_UNSIGNED_BYTE,
    m_byData);
  if (nRet != 0)
  {
    AfxMessageBox("加载纹理失败");
  }
}

void CTexture::Init1DVertTex()
{
  glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
  glGenTextures(1, m_uTexName);
  glBindTexture(GL_TEXTURE_1D, m_uTexName);

  glTexParameteri(GL_TEXTURE_1D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_1D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_1D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_1D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);
  glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);

  BYTE* pbyData = new BYTE[m_nHeight * 3];
  int nAdd = m_nWidth / 2;
  for (int i = 0; i < m_nHeight; ++i)
  {
    pbyData[i * 3] = m_byData[(i * m_nWidth + nAdd) * 3];
    pbyData[i * 3 + 1] = m_byData[(i * m_nWidth + nAdd) * 3 + 1];
    pbyData[i * 3 + 2] = m_byData[(i * m_nWidth + nAdd) * 3 + 2];
  }

  int nRet = gluBuild1DMipmaps(GL_TEXTURE_1D, 3, m_nHeight, GL_RGB, GL_UNSIGNED_BYTE,
    pbyData);
  if (nRet != 0)
  {
    AfxMessageBox("加载纹理失败");
  }

  delete pbyData;
}

CTexture::~CTexture()
{ 
  if (m_byData) 
    delete m_byData;
}
```

现在，在vs2010和vs2008下，不需要使用额外的库就能处理多种格式的纹理了。下面是一个贴图效果，用的是一维纹理显示了sdf值在模型顶点上的分布。
![](https://c2.staticflickr.com/8/7477/27351972272_12745eca94_o.png)