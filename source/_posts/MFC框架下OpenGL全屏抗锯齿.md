---
title: MFC框架下OpenGL全屏抗锯齿
tags:
  - 全屏抗锯齿
id: 1071
categories:
  - 图形学
  - OpenGL
date: 2014-02-24 11:08:21
---

其实OpenGL的全屏抗锯齿就是开启多重采样。在使用glut的时候，很方便就能实现。只要启用多重采样缓冲就行了。但是，在MFC窗口中的实现就很麻烦了。
首先，在MFC窗口中渲染OpenGL就需要比较麻烦的设置。所以，需要在设置OpenGL渲染环境的时候进一步处理。具体的来看下面一段代码吧。
这段代码就是MFC窗口创建的时候，设置OpenGL渲染环境的代码。
对于没有启用多重采样的情况，思路是先获取DC，然后调用ChoosePixelFormat获取最佳像素格式，再调用SetPixelFormat设置像素格式，接着调用wglCreateContext创建OpenGL渲染环境，最后调用wglMakeCurrent设置OpenGL渲染环境。
如果启用了多重采样，代码逻辑就更加复杂了。最恶心的一点是窗口必须创建2次。第一次按照常规思路设置好OpenGL渲染环境，然后调用函数InitMultisample判断是否支持多重采样，如果支持则销毁窗口，重新创建一次。第二次的思路是按照多重采样初始化得到的像素格式设置好OpenGL渲染环境的像素格式，其余的设置和常规的一样。具体参见下面的代码。

``` stylus
   BOOL COglWnd::SetupGLContext()
    {
        DWORD dwFlags = (PFD_DRAW_TO_WINDOW | PFD_DOUBLEBUFFER | PFD_SUPPORT_OPENGL);

        PIXELFORMATDESCRIPTOR pfd =
        {
            sizeof(PIXELFORMATDESCRIPTOR),  // Structure size,
            1,              // Structure version number
            dwFlags,            // Property flags
            PFD_TYPE_RGBA,          // RGBA mode
            24,             // 24-bit color
            0, 0, 0, 0, 0, 0,       // 8-bit each color
            0, 0, 0, 0, 0, 0, 0,        // No alpha or accum. buffer,
            16,             // 32-bit z-buffer
            0, 0,               // No stencil or aux buffer
            PFD_MAIN_PLANE,         // Mainn layer type
            0,              // Reserved
            0, 0, 0,            // Unsupported.
        };

        BOOL bOk = false;
        m_hDC = GetDC()->m_hDC;
        int PixelFormat;

        static bool bFirst = true;
        if (bFirst)
        {
            bFirst = false;

            PixelFormat = ChoosePixelFormat(m_hDC, pfd);
            bOk = SetPixelFormat(m_hDC, PixelFormat, pfd);
            if (!bOk)
            {
                MessageBox(_T("GL set pixel format fail!"), _T("Error"), MB_OK);
                return bOk;
            }

            m_hGLRC = wglCreateContext(m_hDC);
            bOk = wglMakeCurrent(m_hDC, m_hGLRC);
            if (!bOk)
            {
                MessageBox(_T("Set up GL render context fail!"), _T("Error"), MB_OK);
                return bOk;
            }

            InitMultisample(m_hWnd);
            if (arbMultisampleSupported)
            {
                DestroyWindow();
                CreateEx(0, m_className, "OglWnd", WS_CHILD | WS_VISIBLE | WS_CLIPSIBLINGS | WS_CLIPCHILDREN,
                    m_rect, m_parent, 0);
                return bOk;
            }
        }
        else
        {
            PixelFormat = arbMultisampleFormat;//第二次创建
            bOk = SetPixelFormat(m_hDC, PixelFormat, pfd);
            if (!bOk)
            {
                MessageBox(_T("GL set pixel format fail!"), _T("Error"), MB_OK);
                return bOk;
            }

            m_hGLRC = wglCreateContext(m_hDC);
            bOk = wglMakeCurrent(m_hDC, m_hGLRC);
            if (!bOk)
            {
                MessageBox(_T("Set up GL render context fail!"), _T("Error"), MB_OK);
                return bOk;
            }
        }

        return bOk;
    }

```

那么函数InitMultisample是怎么来的了。NeHe刚好有一节课是讲这个的，我是从那里下载得到的。该函数代码如下。

``` stylus
// InitMultisample: Used To Query The Multisample Frequencies
bool InitMultisample(HWND hWnd)
{  
     // See If The String Exists In WGL!
    if (!WGLisExtensionSupported("WGL_ARB_multisample"))
    {
        arbMultisampleSupported=false;
        return false;
    }

    // Get Our Pixel Format
    PFNWGLCHOOSEPIXELFORMATARBPROC wglChoosePixelFormatARB = (PFNWGLCHOOSEPIXELFORMATARBPROC)wglGetProcAddress("wglChoosePixelFormatARB");  
    if (!wglChoosePixelFormatARB) 
    {
        arbMultisampleSupported=false;
        return false;
    }

    // Get Our Current Device Context
    HDC hDC = GetDC(hWnd);

    int     pixelFormat;
    int     valid;
    UINT    numFormats;
    float   fAttributes[] = {0,0};

    // These Attributes Are The Bits We Want To Test For In Our Sample
    // Everything Is Pretty Standard, The Only One We Want To 
    // Really Focus On Is The SAMPLE BUFFERS ARB And WGL SAMPLES
    // These Two Are Going To Do The Main Testing For Whether Or Not
    // We Support Multisampling On This Hardware.
    int iAttributes[] =
    {
        WGL_DRAW_TO_WINDOW_ARB,GL_TRUE,
        WGL_SUPPORT_OPENGL_ARB,GL_TRUE,
        WGL_ACCELERATION_ARB,WGL_FULL_ACCELERATION_ARB,
        WGL_COLOR_BITS_ARB,24,
        WGL_ALPHA_BITS_ARB,8,
        WGL_DEPTH_BITS_ARB,16,
        WGL_STENCIL_BITS_ARB,0,
        WGL_DOUBLE_BUFFER_ARB,GL_TRUE,
        WGL_SAMPLE_BUFFERS_ARB,GL_TRUE,
        WGL_SAMPLES_ARB,16,//16设置了抗锯齿的质量
        0,0
    };

    // First We Check To See If We Can Get A Pixel Format For 4 Samples
    valid = wglChoosePixelFormatARB(hDC,iAttributes,fAttributes,1,pixelFormat,numFormats);

    // If We Returned True, And Our Format Count Is Greater Than 1
    if (valid  numFormats >= 1)
    {
        arbMultisampleSupported = true;
        arbMultisampleFormat = pixelFormat; 
        return arbMultisampleSupported;
    }

    // Our Pixel Format With 4 Samples Failed, Test For 2 Samples
    iAttributes[19] = 2;
    valid = wglChoosePixelFormatARB(hDC,iAttributes,fAttributes,1,pixelFormat,numFormats);
    if (valid  numFormats >= 1)
    {
        arbMultisampleSupported = true;
        arbMultisampleFormat = pixelFormat;  
        return arbMultisampleSupported;
    }

    // Return The Valid Format
    return  arbMultisampleSupported;
}
```

该函数的使用还是很简单的，基本上是修改了2个全局变量，arbMultisampleSupported判断是否支持多重采样，arbMultisampleFormat则是对应的像素格式。我在代码中注释了一行：WGL_SAMPLES_ARB,16,//16设置了抗锯齿的质量。这里貌似可以修改数字的大小，据说一般显卡都支持到16，16的情况下，抗锯齿很好了，4的话效果一般般。这个函数相关的完整代码可以从NeHe下载。
至于完整代码，可以参考我上一篇文章，然后将这一篇文章的代码加进去即可。
未抗锯齿的效果：![](https://c2.staticflickr.com/8/7346/27417287776_bda4d8b386_o.png)
抗锯齿的效果：![](https://c2.staticflickr.com/8/7593/27417289466_6e1071be4d_o.png)