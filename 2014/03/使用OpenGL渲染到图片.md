---
title: 使用OpenGL渲染到图片
tags:
  - OpenGL
  - 渲染图片
  - 渲染数据
id: 1100
categories:
  - OpenGL
  - 图形学
date: 2014-03-03 22:51:06
---

标题的意思是使用OpenGL生成特定的图片。比如说，把OpenGL渲染出来的特定结果保存出来，或者生成特殊的纹理图片。
第一步，保存OpenGL环境。这个使用glPushAttrib(GL_ALL_ATTRIB_BITS)实现。
第二步，设置视口。既然我们要生成指定大小的图片，那我们就**把视口设置为该图片的大小**。glViewport(0, 0, nWidth, nHeight);
第三步，设置投影矩阵。
第四步，设置模型视图矩阵。
第五步，进行相关绘制。
第六步，调用**glReadPixels**保存绘制内容。（这一步也可以放到后面的任意位置）
第七步，恢复模型视图矩阵。
第八步，恢复投影矩阵。
第九步，恢复OpenGL环境。
大致的代码，可以用下面这个函数描述。只需要替换绘制的代码就可以改成你需要的形式了。
``` stylus
    void CDrawedTexture::InterpolateData(int m_nWidth, int m_nHeight)
    {
        glPushAttrib(GL_ALL_ATTRIB_BITS);

        glViewport(0, 0, nWidth, nHeight);
        glClearColor(0.0, 0.0, 0.0, 1.0);
        glDisable(GL_TEXTURE_2D);

        glMatrixMode(GL_PROJECTION);
        glPushMatrix();
        glLoadIdentity();
        gluOrtho2D(0.0, 1.0, 0.0, 1.0);

        glMatrixMode(GL_MODELVIEW);
        glPushMatrix();
        glLoadIdentity();

        glClear(GL_COLOR_BUFFER_BIT);

        //绘制三角形
        glEnable(GL_TEXTURE_2D);

        for (int i = 0; i < m_faces.size(); ++i)
        {
            m_faces[i].v[0].pTexture->Bind2d();
            glBegin(GL_TRIANGLES);
            for (int j = 0; j < 3; ++j)
            {
                //设置纹理坐标
                glTexCoord2f(m_faces[i].v[j].oldTexPos[0], m_faces[i].v[j].oldTexPos[1]);
                //设置坐标
                glVertex2f(m_faces[i].v[j].newTexPos[0], m_faces[i].v[j].newTexPos[1]);
            }
            glEnd();
        }

        glReadPixels(0, 0, nWidth, nHeight, GL_RGBA, GL_UNSIGNED_BYTE, m_img.raw());

        glPopMatrix();

        glMatrixMode(GL_PROJECTION);
        glPopMatrix();

        glPopAttrib();

        m_img.save("插值纹理.bmp");
    }
```
注意请使用**双缓存区**，而且**绝对不能调用交换缓存区函数**。原因是生成图片是幕后工作，交换缓存区会破坏屏幕当前的显示。这里还有个必须很注意的地方，就是glReadPixels的参数一定要正确。比如**像素的格式**，还有**数据的类型**。如果你的颜色缓存区是rgba的，那么你一定得使用**GL_RGBA**而不是GL_RGB，还有一般不能使用GL_BYTE，而是要使用**GL_UNSIGNED_BYTE**，否则会造成数据截断。
我这段代码的意图是将笔画绘制所经过的三维部分投影到二维图片上面保存起来。三维模型上面贴了纹理。
当然还可以用FBO实现和本文类似的功能。
如果实现所谓的渲染到纹理，我们只需要把渲染到后缓存区的数据提取出来，绑定到纹理就行了。