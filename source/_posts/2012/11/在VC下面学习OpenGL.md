---
title: 在VC下面学习OpenGL
tags:
  - OpenGL
  - VC6
id: 350
categories:
  - OpenGL
date: 2012-11-06 20:10:35
---

先贴一个OpenGL程序的代码,

``` stylus
#include <stdlib.h>
#include <time.h>
#include <windows.h>
#include <gl/gl.h>
#include <gl/glu.h>
#include <gl/glut.h>
#pragma comment(linker, "/subsystem:\"windows\" /entry:\"mainCRTStartup\"") //设置连接器选项

const int WINDOW_WIDTH = 640;
const int WINDOW_HEIGHT = 480;
const int WINDOW_POS_X = 300;
const int WINDOW_POS_Y = 150;
const int NUM = 1000;

void myInit()
{
    glClearColor(1.0, 1.0, 1.0, 0.0);//设置背景颜色为亮白
    glColor3f(0.0f, 0.0f, 0.0f);//设置绘图颜色为黑色
    glPointSize(4.0);//设置点的大小为4*4像素
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluOrtho2D(0.0, WINDOW_WIDTH, 0.0, WINDOW_HEIGHT);//以上三句话合起伙是设置窗口的坐标系
}

void myDisplay()
{
    glClear(GL_COLOR_BUFFER_BIT);//清屏
    glBegin(GL_POINTS);
    for (int i = 0; i < NUM; ++i)
    {
        glVertex2i(rand() % WINDOW_WIDTH, rand() % WINDOW_HEIGHT);
    }
    glEnd();
    glFlush();//送往设备显示
}

int main(int argc, char** argv)
{
    glutInit(argc, argv);
    glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB);//设置显示模式
    glutInitWindowSize(WINDOW_WIDTH, WINDOW_HEIGHT);
    glutInitWindowPosition(WINDOW_POS_X, WINDOW_POS_Y);
    glutCreateWindow("散乱点图");
    glutDisplayFunc(myDisplay);//注册重绘回调函数
    myInit();
    srand(time(NULL));
    glutMainLoop();//进入消息循环

    return 0;
}
```

该程序只是创建一个窗口，然后在里面画一些随机的点。效果如图所示，

![](https://c6.staticflickr.com/8/7386/26822942093_22d5d37726_o.jpg)

说实话这个程序非常简单，在主函数里面只是设置了窗口大小和位置，然后创建了个窗口，做了些初始化，并且为窗口设置了显示回调函数。初始化函数里面都有注释，显示回调函数里面只是一直在随机画点而已。

说实话，仅仅是使用最基本的opengl画图确实太简单了，也没什么多说的，如果你熟悉Windows程序设计和C++语言，只是换个库而已，真正需要学习的是计算机图形学。我觉得OpenGL相对于DirectX简洁明了很多了，所以才选择了计算机图形学OpenGL版这本书来学习图形学的。下面来简要介绍下OpenGL的库组成吧。

OpenGL库分为四个部分，GL和GLU，GLUT以及GLUI。GL和GLU都是用于绘图的，只是第一个是基本库，第二个是一些高级的绘图函数。GLUT库主要包含一些管理窗口和菜单的函数，GLUI则是一些高级的界面管理部分，比如各种复杂的按钮和菜单。

我觉得如果在VC下面建立控制台工程，然后设置链接命令去掉控制台窗口，再在main函数下执行OpenGL操作，这个过程不仅简洁而且感觉效果也不错。现在看来，OpenGL确实是一个比较美观的东西，至少相对于我用了几年的MFC来说。

