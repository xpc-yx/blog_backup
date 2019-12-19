---
title: OpenGL视口点投影到视角空间及反投影
tags:
  - OpenGL
id: 1114
categories:
  - 图形学
  - OpenGL
date: 2014-03-13 16:02:41
---

有些时候，我们想知道鼠标点中了哪个物体或者哪个部分，更详细的是最靠近模型的哪个顶点或者哪条线，或者哪个面。这些选取问题有不同的解决办法。如果只是针对**图元**的选取，可以直接用OpenGL的**选取模式**实现。但是有的时候，情况更加复杂，比如我们想通过鼠标在模型上面绘制一条线，然后对模型进行剖分等。这就需要把鼠标点变换到三维顶点，再进一步的操作。
我在这里贴出2个我自己使用的函数，针对鼠标点投影视角空间和反投影。
投影：``` stylus
void CMesh::ScreenToModel(v2f point, v3f point3d)
{
        float fWinX, fWinY, fWinZ;
        int nX, nY;
        GLdouble fX, fY, fZ;

        nX = point[0];
        nY = point[1];
        glReadBuffer(GL_BACK);
        glReadPixels(nX, nY, 1, 1, GL_DEPTH_COMPONENT, GL_FLOAT, fWinZ);
        if (fabs(fWinZ - 1.0) > 1e-8)
        {
            fWinX = nX;
            fWinY = nY;
            gluUnProject(fWinX, fWinY, fWinZ, m_pMatMV, m_pMatProj, m_pViewport,
                fX, fY, fZ);
            point3d[0] = fX;
            point3d[1] = fY;
            point3d[2] = fZ;
        }
        else
        {
            point3d[0] = point3d[1] = 0.0;
            point3d[2] = 1.0;
        }
}
```
使用该函数必须注意的是，point必须已经转换为**视口点**，即point[1] = window_height - point[1] - 1。
反投影:``` stylus
void CMesh::ModelToScreen(v3f point3d, v2f point)
{
        double fWinX, fWinY, fWinZ;
        gluProject(point3d[0], point3d[1], point3d[2], m_pMatMV, m_pMatProj, m_pViewport,
            fWinX, fWinY, fWinZ);

        point[0] = (float)fWinX;
        point[1] = (float)fWinY;
}
```
反投影得到的2维点同样是基于**左下角**为原点的视口点，要转换为鼠标点的话还得变换y值，即point[1] = window_height - point[1] - 1。
至于其它的实现方法，当然可以自己直接操作投影矩阵和模型矩阵，视口信息，进行转换，不过也是重复造轮子，但对于理解原理有帮助。
鼠标点投影到三维之后，就可以找到**最近**的模型点，或者通过射线之类求相交面。