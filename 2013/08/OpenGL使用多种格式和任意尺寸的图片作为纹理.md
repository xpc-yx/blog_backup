---
title: OpenGL使用多种格式和任意尺寸的图片作为纹理
tags:
  - OpenGL
  - 图形学
  - 纹理
id: 889
categories:
  - OpenGL
  - 图形学
date: 2013-08-31 22:09:07
---

处理多种格式本身就是件麻烦的事情。但是使用cximage的话，就可以完美解决这个问题了。cximage可以处理多种常见格式的图片，比如bmp，png，jpg等。
那么如何使用任意尺寸的图片了。glTexImage2D必须使用长宽二次方的图片，使用非二次方的图片，必须用glTexSubImage2D进行处理，具体方法，可以参考 OpenGL使用长宽非二次方纹理 。
那么如何避免使用glTexSubImage2D了。我们可以使用函数gluBuild2DMipmaps来完成以上两个函数完成的工作，还不需要对纹理坐标进行放缩。这是一件非常方便的事情。
下面提供我的纹理类。使用方法很简单。先调用加载图片函数，再调用初始化纹理函数，可以选择二维和一维垂直方向的。然后，在绘制的时候使用纹理就行了。

``` stylus
#ifndef XPC_YX_TEXTURE_H
#define XPC_YX_TEXTURE_H

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
    unsigned m_uTexName;
};

#endif
```

``` stylus
#include "stdafx.h"
#include "Texture.h"
#include "../CxImage/ximage.h"
#include <stdlib.h>
#include <stdio.h>
#pragma comment(lib, "cximage.lib")

int CTexture::LoadFromFile(const char* pcszFileName)
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

    return 1;
}

void CTexture::Init2DTex()
{
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glGenTextures(1, m_uTexName);
  glBindTexture(GL_TEXTURE_2D, m_uTexName);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

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
  glTexParameteri(GL_TEXTURE_1D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_1D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);

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

要使用该类，还得配置CxImage。下面这张图片是使用一维垂直纹理的效果。
![](https://c2.staticflickr.com/8/7635/27451191995_e448a2f0bc_o.png)