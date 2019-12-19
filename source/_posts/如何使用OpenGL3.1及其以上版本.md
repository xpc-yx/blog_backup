---
title: 如何使用OpenGL3.1及其以上版本
tags:
  - Glew
  - OpenGL
id: 672
categories:
  - 图形学
  - OpenGL
date: 2013-01-09 22:10:34
---

刚开始学习图形学的时候，就看的是计算机图形学opengl版。那么，我当然也想下载最新版本的sdk。但是发现，官网上只有3.1及其以上版本的文档，无论我怎么找，都找不到相应的sdk。后面，我好像是在pudn上面找到了3.0版本的sdk。将就着用了吧，一直到今天我在看OpenGL编程指南第七版的时候，发现无法使用函数glGenBuffers。好吧，没办法，我只能去找更新版本的sdk。

还是找来找去，发现什么都找不到，但是发现opengl的扩展库倒是不少。比如，glew和glextension之类的。后面发现csdn上有篇博文说，opengl3.1及其之后的版本官方都不提供实现了，所以就找不到那些sdk。有个方法是glew，那么就用它吧。

使用glew也不是那么简单的事情，首先得下载glew，我下载了的是1.9的版本。即使配置成功了，也不一定说就能使用成功了。因为还必须初始化glew，**最坑爹的是这个初始化必须在你创建窗口之后，否则一定会失败**。

下面给出使用glew的示例代码。

``` stylus
#include "windows.h"
#include <glew.h>
#include <glut.h>
#include <assert.h>

#pragma comment(linker, "/subsystem:\"windows\" /entry:\"mainCRTStartup\"")
#pragma comment(lib , "glew32.lib")

const GLint WINDOW_WIDTH = 600;
const GLint WINDOW_HEIGHT = 450;
const GLint WINDOW_POS_X = 100;
const GLint WINDOW_POS_Y = 100;
const char* cszWindowTitile = "primrestart";

void Display()
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glColor3f(1.0, 1.0, 1.0);
    glRectf(0.0, 0.0, 100.0, 100.0);
    glutSwapBuffers();
}

void Reshape(int nW, int nH)
{
    glViewport(0, 0, nW, nH);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluOrtho2D(0, nW, 0, nH);
}

int main(int argc, char** argv)
{
    glutInit(argc, argv);
    glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH);
    glutInitWindowSize(WINDOW_WIDTH, WINDOW_HEIGHT);
    glutInitWindowPosition(WINDOW_POS_X, WINDOW_POS_Y);
    glutCreateWindow(cszWindowTitile);
    int nRet = glewInit();
    if (nRet != GLEW_OK)
    {
        MessageBox(NULL, "glew初始化失败", "Error", MB_ICONERROR);
        return -1;
    }
    Init();
    glutDisplayFunc(Display);
    glutReshapeFunc(Reshape);
    glutMainLoop();

    return 0;
}
```

从该代码中可以看到，glew.h之前不能包含gl.h，否则编译不过，还有链接上glew.lib，另外最恶心的就是glewInit的正确位置，一定要在创建了窗口（函数调用glutCreateWindow)之后，否则glewInit一定会失败的，glewInit失败了的话，再使用3.1及其以上版本的函数就会出现内存错误了。

最后做下贡献，附录下我的opengl sdk，[opengl3.0+glew1.9+一点文档](https://pan.baidu.com/s/1bS3dV4)，基本上可以满足要求了。