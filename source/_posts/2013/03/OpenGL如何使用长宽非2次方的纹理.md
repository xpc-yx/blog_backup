---
title: OpenGL如何使用长宽非2次方的纹理
tags:
  - OpenGL
  - 图形学
  - 纹理
id: 719
categories:
  - OpenGL
  - 图形学
date: 2013-03-24 15:52:00
---

也许在某些显卡上面，直接用glTexImage2D是可以使用非2次方纹理的。但是在我的机子上，直接用出现**运行错误**了。有没有办法让我们的程序**同时支持2次方纹理和非二次方纹理了，并且我们还不需要改变纹理坐标**了。
有，我们可以判断纹理的宽和高是不是都为2次方的。如果都是，那么直接使用就行了。如果不是，我们先用**glTexImage2D申请2次方的纹理**，然后用**glTexSubImage2D**把我们的数据放进去，再计算**纹理坐标的变化因子**，最后用glMatrixMode进入**纹理堆栈**操作，用**glScaled**设置坐标变化因子，这一切做完之后就可以按照非二次方纹理使用了。
下面提供部分代码，大致可以看出操作方法。
``` stylus
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
    }
    else
    {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, nWidthPowerOfTwo, nHeightPowerOfTwo,
        0, nFormat, GL_UNSIGNED_BYTE, NULL);
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, m_nWidth, m_nHeight,
        nFormat, GL_UNSIGNED_BYTE, m_byData);
        fTexScaleX = 1.0 * m_nWidth / nWidthPowerOfTwo;
        fTexScaleY = 1.0 * m_nHeight / nHeightPowerOfTwo;
        //设置纹理堆栈
        glMatrixMode(GL_TEXTURE);
        glLoadIdentity();
        glScaled(fTexScaleX, fTexScaleY, 1.0);
    }
```