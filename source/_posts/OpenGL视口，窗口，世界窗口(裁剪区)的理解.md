---
title: OpenGL视口，窗口，世界窗口(裁剪区)的理解
tags:
id: 361
categories:
  - 图形学
  - OpenGL
date: 2012-11-07 17:07:45
---

先讲下OpenGL的坐标系。OpenGL的坐标系和Windows窗口默认的坐标系是不同的。WindowsGDi的默认原点在左上角，X向右递增，Y向下递增，而OpenGL的原点在窗口的左下角，X向右递增，Y向上递增。

OpenGL里面所谓的窗口就是我们创建出来的窗口，也叫做屏幕窗口，我们可以在这整个窗口里面绘图。而视口则是窗口的一个子区域，通过设置视口就可以把绘图区域限定为窗口的一个子区域，而这个子区域的别名就叫做视口。这个函数是**glViewport。**该函数原型为
void **glViewport**(GLint _x_,
GLint _y_,
GLsizei _width_,
GLsizei _height_)

第一个参数和第二个参数是左下角的坐标，第三个参数和第四个参数则分别是视口的宽度和高度。记住一点，OpenGL用的是笛卡尔坐标系，而我一直习惯了WindowsGDI的坐标系设置。

现在来讲解最关键的东西---世界窗口（裁剪区）。

这个东西理解了，我们就可以通过一些设置做出一些漂亮的图形裁剪啊之类的，总之能达到一些很爽的效果。以计算机图形学OpenGL版3.2节的例子来说明，世界窗口即是能容纳sinc(x) = sin(PI*x) / (PI *x)的定义域和值域的二维矩阵。比如说，这个例子里面绘画函数的时候x的范围是[-4.0,4.0]，该函数最大值不会超过1.0，在该范围内最小值也会大于-0.3，那么我们可以设置世界窗口为[-4.0,4.0,-0.3,1.0]，四个值分别是描述了现实世界中的一个与坐标轴平行的矩形。如果把世界窗口设置为[-5.0,5.0,-0.3,1.0]，该函数的显示效果可能会更好一点，因为可以看到边界外面的部分。

现在很明显的看到，世界窗口和视口大小基本上是不一致的，那么我们要显示的图形肯定会被拉伸。这个拉伸也是很简单的按照比例尺计算出来的。可以很形象的想象下，把一个人放小显示在一个窗口里面，或者把一只蚂蚁放大显示在一个窗口里面。

附3.2节sinc源码:

``` stylus
#include <windows.h>
#include <math.h>
#include <gl/gl.h>
#include <gl/glu.h>
#include <gl/glut.h>
#pragma comment(linker, "/subsystem:\"windows\" /entry:\"mainCRTStartup\"")

const float PI = atan(1.0) * 4;
const int WINDOW_WIDTH = 640;
const int WINDOW_HEIGHT = 480;
const int WINDOW_POS_X = 300;
const int WINDOW_POS_Y = 150;

//设置世界窗口
void SetWindow(GLdouble left, GLdouble right, GLdouble bottom, GLdouble top)
{
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluOrtho2D(left, right, bottom, top);
}

//设置视口
void SetViewport(GLint left, GLint right, GLint bottom, GLint top)
{
    glViewport(left, bottom, right - left, top - bottom);
}

void myInit()
{
    glClearColor(1.0, 1.0, 1.0, 0.0);//白色背景
    glColor3f(0.0, 0.0, 1.0);
    glLineWidth(2.0);
}

void myDisplay()
{
    glClear(GL_COLOR_BUFFER_BIT);
    glMatrixMode(GL_MODELVIEW);//使视图矩形栈有效
    glLoadIdentity();

    SetViewport(0, WINDOW_WIDTH / 2, 0, WINDOW_HEIGHT);//这个函数调用在main里面一直没效果
    glBegin(GL_LINE_STRIP);
    for (float x = -4.0; x <= 4.0; x += 0.1)
    {
        if (fabs(x) < 1e-8)
        {
            glVertex2f(0.0, 1.0);
        }
        else
        {
            glVertex2f(x, sin(PI * x) / (PI* x));
        }
    }
    glEnd();

    glFlush();
}

int main(int argc, char** argv)
{
    glutInit(argc, argv);
    glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB);//设置显示模式
    glutInitWindowSize(WINDOW_WIDTH, WINDOW_HEIGHT);
    glutInitWindowPosition(WINDOW_POS_X, WINDOW_POS_Y);
    glutCreateWindow("The Famous Sinc Function");
    glutDisplayFunc(myDisplay);
    myInit();
    SetWindow(-5.0, 5.0, -0.3, 1.0);
    glutMainLoop();//进入消息循环

    return 0;
}
```

显示效果如图，

![](https://c2.staticflickr.com/8/7292/27153717460_4c258e9ddc_o.png)

由于我设置了视口为左半窗口，可以明显的看到，函数曲线挤压在左边了。注意，在主函数里面设置视口一直没有效果，我也不知道为什么。