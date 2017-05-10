---
title: 计算机图形学OpenGL版第三章源代码汇总
tags:
  - 计算机图形学OpenGL版源代码
id: 364
categories:
  - 图形图像
  - 图形学
  - OpenGL
date: 2012-11-07 22:41:48
---

写了下第三章部分作业和例子的代码，如下。

3.2节 sinc
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
3.2节 放大显示
``` stylus
#include <windows.h>
#include <math.h>
#include <gl/gl.h>
#include <gl/glu.h>
#include <gl/glut.h>
#pragma comment(linker, "/subsystem:\"windows\" /entry:\"mainCRTStartup\"")

const float PI = atan(1.0) * 4;
int nWidth = 640;
int nHeight = 480;
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

/////////////////////////////////////////////////////////////////
// Function: hexswirl()
// This draws a hexagon on the screen many times.  Each new
// hexagon is slightly bigger than the previous one and rotated
// slightly so that a hexagon "swirl" is drawn.
/////////////////////////////////////////////////////////////////
void hexSwirl()
{
    double angle;                       //the angle of rotation
    double angleInc = 2*3.14159265/6.0; //the angle increment
    double inc = 5.0 / 100;               //the radius increment
    double radius = 5.0 / 100.0;          //the radius to be used

    //glMatrixMode(GL_MODELVIEW);
    //glLoadIdentity();
    //clear the background

    //draw the hexagon swirl
    for (int j = 0; j <= 100; j++)
    {
        //the angle of rotation depends on which hexagon is 
        //being drawn.
        angle = j* (3.14159265/180.0);

        //draw one hexagon
        glBegin (GL_LINE_STRIP);
        for (int k=0; k <= 6; k++)
        {
            angle += angleInc;
            glVertex2d(radius * cos(angle), radius *sin(angle));

        }
        glEnd();

        //determine the radius of the next hexagon
        radius += inc;
    }

    //swap buffers for a smooth change from one
    //frame to another
    glutSwapBuffers();
    glFlush();
}

void myDisplay()
{
    glClear(GL_COLOR_BUFFER_BIT);
    float cx = 0.3, cy = 0.2;
    float H, W, aspect = 0.7;

    int frame = 50;
    for (int i = 0; i < frame; ++i)
    {
        glClear(GL_COLOR_BUFFER_BIT);
        W *= 0.7;
        H = W * aspect;
        SetWindow(cx - W, cx + W, cy - H, cy + H);
        hexSwirl();
    }

    glFlush();
}

void reShape(int nNewWidth, int nNewHeight)
{
    nWidth = nNewWidth;
    nHeight = nNewHeight;
    SetViewport(0, nWidth, 0, nHeight);
}

int main(int argc, char** argv)
{
    glutInit(argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB);//设置显示模式
    glutInitWindowSize(nWidth, nHeight);
    glutInitWindowPosition(WINDOW_POS_X, WINDOW_POS_Y);
    glutCreateWindow("hexSwirl");
    glutDisplayFunc(myDisplay);
    glutReshapeFunc(reShape);
    myInit();
    glutMainLoop();//进入消息循环

    return 0;
}
```
3.2节 回旋的旋涡
``` stylus
#include <windows.h>
#include <math.h>
#include <gl/gl.h>
#include <gl/glu.h>
#include <gl/glut.h>
#pragma comment(linker, "/subsystem:\"windows\" /entry:\"mainCRTStartup\"")

const float PI = atan(1.0) * 4;
int nWidth = 640;
int nHeight = 480;
const int WINDOW_POS_X = 300;
const int WINDOW_POS_Y = 150;
const int ROW = 8;
const int COLUMU = 6;

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

/////////////////////////////////////////////////////////////////
// Function: hexswirl()
// This draws a hexagon on the screen many times.  Each new
// hexagon is slightly bigger than the previous one and rotated
// slightly so that a hexagon "swirl" is drawn.
/////////////////////////////////////////////////////////////////
void hexSwirl()
{
    double angle;                       //the angle of rotation
    double angleInc = 2*3.14159265/6.0; //the angle increment
    double inc = 5.0 / 100;               //the radius increment
    double radius = 5.0 / 100.0;          //the radius to be used

    //glMatrixMode(GL_MODELVIEW);
    //glLoadIdentity();
    //clear the background

    //draw the hexagon swirl
    for (int j = 0; j <= 100; j++)
    {
        //the angle of rotation depends on which hexagon is 
        //being drawn.
        angle = j* (3.14159265/180.0);

        //draw one hexagon
        glBegin (GL_LINE_STRIP);
        for (int k=0; k <= 6; k++)
        {
            angle += angleInc;
            glVertex2d(radius * cos(angle), radius *sin(angle));

        }
        glEnd();

        //determine the radius of the next hexagon
        radius += inc;
    }
}

void myDisplay()
{
    glClear(GL_COLOR_BUFFER_BIT);

    const int  L = nWidth / ROW;

    for (int i = 0; i < ROW; ++i)
    {
        for (int j = 0; j < COLUMU; ++j)
        { 
            if ((i + j) % 2 == 0)
            {
                SetWindow(-0.6, 0.6, -0.6, 0.6);
            }
            else
            {
                SetWindow(-0.6, 0.6, 0.6, -0.6);
            }
            SetViewport(i * L, L + i * L, j * L, L + j * L);
            hexSwirl();
            //for (int k = 0; k <= 200000000; k++);
        }
    }

    //swap buffers for a smooth change from one
    //frame to another
    glutSwapBuffers();
    glFlush();
}

void reShape(int nNewWidth, int nNewHeight)
{
    nWidth = nNewWidth;
    nHeight = nNewHeight;
}

int main(int argc, char** argv)
{
    glutInit(argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB);//设置显示模式
    glutInitWindowSize(nWidth, nHeight);
    glutInitWindowPosition(WINDOW_POS_X, WINDOW_POS_Y);
    glutCreateWindow("hexSwirl");
    glutDisplayFunc(myDisplay);
    glutReshapeFunc(reShape);
    myInit();
    glutMainLoop();//进入消息循环

    return 0;
}
```
3.4节 5花环
``` stylus
#include <stdlib.h>
#include <math.h>
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
const int NUM = 55000;
const double PI = atan(1.0) * 4;

struct GLintPoint
{
    GLint x;
    GLint y;
}; 

class Point2
{
public:
    float x, y;
    void set(float dx, float dy) {x = dx; y = dy;}
    void set(Point2 p) {x = p.x; y = p.y;}
    Point2(float xx, float yy) {x = xx, y = yy;}
    Point2() {x = y = 0;}
};
Point2 curpos, cp;

void moveTo(Point2 p)
{
    cp.set(p);
}

void lineTo(Point2 p)
{
    glBegin(GL_LINES);
    glVertex2f(cp.x, cp.y);
    glVertex2f(p.x, p.y);
    glEnd();
    glFlush();
    cp.set(p);
}

void myInit()
{
    glClearColor(1.0, 0.0, 0.0, 0.0);
    glColor3f(0.0f, 1.0f, 0.0f);
    glPointSize(4.0);//设置点的大小为4*4像素
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluOrtho2D(-WINDOW_WIDTH / 2, WINDOW_WIDTH / 2, -WINDOW_HEIGHT / 2, WINDOW_HEIGHT / 2);
}

void rosette(int N, float radius)
{
    Point2* pointlist = new Point2[N];

    GLfloat theta = (2.0 * PI) / N;
    for (int c = 0; c < N; ++c)
    {
        pointlist``` stylus.set(radius * sin(c * theta), radius * cos(theta * c));
    }

    for (int i = 0; i < N; ++i)
    {
        for (int j = 0; j < N; ++j)
        {
            moveTo(pointlist[i]);
            lineTo(pointlist[j]);
        }
    }
}

void myDisplay()
{
    glClear(GL_COLOR_BUFFER_BIT);//清屏
    glViewport(10, 10, 640, 480);
    rosette(5, 200);
    glFlush();//送往设备显示
}

int main(int argc, char** argv)
{
    glutInit(argc, argv);
    glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB);//设置显示模式
    glutInitWindowSize(WINDOW_WIDTH, WINDOW_HEIGHT);
    glutInitWindowPosition(WINDOW_POS_X, WINDOW_POS_Y);
    glutCreateWindow("花环");
    glutDisplayFunc(myDisplay);//注册重绘回调函数
    myInit();
    glutMainLoop();//进入消息循环

    return 0;
}
```
3.4.3 阴阳符号
``` stylus
#include <algorithm>
#include <math.h>
#include <windows.h>
#include <gl/gl.h>
#include <gl/glu.h>
#include <gl/glut.h>
using namespace std;
#pragma comment(linker, "/subsystem:\"windows\" /entry:\"mainCRTStartup\"")

const double PI = atan(1.0) * 4;
const int WINDOW_WIDTH = 640;
const int WINDOW_HEIGHT = 480;
const int WINDOW_POS_X = 300;
const int WINDOW_POS_Y = 150;
const double BIG_R = 100;
const double MID_R = 50;
const double SML_R = 10;

void myInit()
{
    glClearColor(0.5, 0.5, 0.5, 0.0);
    glColor3f(0.0, 0.0, 1.0);
    glLineWidth(2.0);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluOrtho2D(0.0, WINDOW_WIDTH, 0.0, WINDOW_HEIGHT);
}

void drawArc(double fX, double fY, double fR, double fBeg, double fEnd)
{
    double fAdd = 0.0001;

    fBeg = fBeg * PI / 180;
    fEnd = fEnd * PI / 180;
    if (fBeg > fEnd)
    {
        swap(fBeg, fEnd);
    }

    glBegin(GL_POLYGON);
    while (fBeg < fEnd)
    {
        glVertex2f(fX + fR * cos(fBeg), fY + fR * sin(fBeg));
        fBeg += fAdd;
    }
    glEnd();
}

void myDisplay()
{
    glClear(GL_COLOR_BUFFER_BIT);

    glColor3f(0.0, 0.0, 0.0);//黑
    drawArc(WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2, BIG_R, 0, 180);
    glColor3f(1.0, 1.0, 1.0);//白
    drawArc(WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2, BIG_R, 180, 360);
    glColor3f(0.0, 0.0, 0.0);//黑
    drawArc(WINDOW_WIDTH / 2 - MID_R, WINDOW_HEIGHT / 2, MID_R, 0, 360);
    glColor3f(1.0, 1.0, 1.0);//白
    drawArc(WINDOW_WIDTH / 2 + MID_R, WINDOW_HEIGHT / 2, MID_R, 0, 360);
    drawArc(WINDOW_WIDTH / 2 - MID_R, WINDOW_HEIGHT / 2, SML_R, 0, 360);
    glColor3f(0.0, 0.0, 0.0);//黑
    drawArc(WINDOW_WIDTH / 2 + MID_R, WINDOW_HEIGHT / 2, SML_R, 0, 360);

    glFlush();
}

int main(int argc, char** argv)
{
    glutInit(argc, argv);
    glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB);//设置显示模式
    glutInitWindowSize(WINDOW_WIDTH, WINDOW_HEIGHT);
    glutInitWindowPosition(WINDOW_POS_X, WINDOW_POS_Y);
    glutCreateWindow("阴阳图");
    glutDisplayFunc(myDisplay);
    myInit();
    glutMainLoop();//进入消息循环

    return 0;
}
```

3.4.4 Koch雪花
``` stylus
#include <algorithm>
#include <math.h>
#include <windows.h>
#include <gl/gl.h>
#include <gl/glu.h>
#include <gl/glut.h>
using namespace std;
#pragma comment(linker, "/subsystem:\"windows\" /entry:\"mainCRTStartup\"")

const double PI = atan(1.0) * 4;
const int WINDOW_WIDTH = 640;
const int WINDOW_HEIGHT = 480;
const int WINDOW_POS_X = 300;
const int WINDOW_POS_Y = 150;
const int DEPTH = 8;

struct GLdoublePoint
{
    GLdouble fX, fY;
};

GLdoublePoint operator + (const GLdoublePoint a, const GLdoublePoint b)
{
    GLdoublePoint c;
    c.fX = a.fX + b.fX;
    c.fY = a.fY + b.fY;
    return c;
}

GLdoublePoint operator - (const GLdoublePoint a, const GLdoublePoint b)
{
    GLdoublePoint c;
    c.fX = a.fX - b.fX;
    c.fY = a.fY - b.fY;
    return c;
}

GLdoublePoint operator * (const GLdoublePoint a, double fScale)
{
    GLdoublePoint c;
    c.fX = a.fX * fScale;
    c.fY = a.fY * fScale;
    return c;
}

void myInit()
{
    glClearColor(1.0, 1.0, 1.0, 0.0);
    glColor3f(0.0, 0.0, 0.0);
    glLineWidth(2.0);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluOrtho2D(0.0, WINDOW_WIDTH, 0.0, WINDOW_HEIGHT);
}

void drawKoch(GLdoublePoint beg, GLdoublePoint end, int depth, bool left)
{
    if (depth == 0)
    {
        glBegin(GL_LINES);
        glVertex2f(beg.fX, beg.fY);
        glVertex2f(end.fX, end.fY);
        glEnd();
        return;
    }

    GLdoublePoint pts[3];
    GLdoublePoint vct = end - beg;
    pts[0] = beg + (vct * (1.0 / 3.0));
    pts[2] = beg + (vct * (2.0 / 3.0));
    GLdoublePoint nvct;

    if (left)
    {
        nvct.fX = -vct.fY;
        nvct.fY = vct.fX;
    }
    else
    {
        nvct.fX = vct.fY;
        nvct.fY = -vct.fX;
    }

    double fSize = sqrt(nvct.fX * nvct.fX + nvct.fY * nvct.fY);
    double fLen = (fSize / 3) * (sqrt(3) / 2);
    nvct.fX = nvct.fX / fSize * fLen;
    nvct.fY = nvct.fY / fSize * fLen;
    pts[1] = beg + (vct * 0.5);
    pts[1] = pts[1] + nvct;

    drawKoch(beg, pts[0], depth - 1, left);
    drawKoch(pts[0], pts[1], depth - 1, left);
    drawKoch(pts[1], pts[2], depth - 1, left);
    drawKoch(pts[2], end, depth - 1, left);
}

void myDisplay()
{
    glClear(GL_COLOR_BUFFER_BIT);

    GLdoublePoint beg, end;
    beg.fX = WINDOW_WIDTH / 3;
    beg.fY = WINDOW_HEIGHT / 3 * 2;
    end.fX = (WINDOW_WIDTH / 3) * 2;
    end.fY = WINDOW_HEIGHT / 3 * 2;
    drawKoch(beg, end, DEPTH, true);

    beg.fX = WINDOW_WIDTH / 3;
    beg.fY = WINDOW_HEIGHT / 3 * 2;
    end.fX = WINDOW_WIDTH / 2;
    end.fY = WINDOW_HEIGHT / 3 * 2 - (WINDOW_WIDTH / 3) * (sqrt(3) / 2);
    drawKoch(beg, end, DEPTH, false);

    beg.fX = WINDOW_WIDTH / 2;
    beg.fY = WINDOW_HEIGHT / 3 * 2 - (WINDOW_WIDTH / 3) * (sqrt(3) / 2);
    end.fX = WINDOW_WIDTH / 3 * 2;
    end.fY = WINDOW_HEIGHT / 3 * 2;
    drawKoch(beg, end, DEPTH, false);

    glFlush();
}

int main(int argc, char** argv)
{
    glutInit(argc, argv);
    glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB);//设置显示模式
    glutInitWindowSize(WINDOW_WIDTH, WINDOW_HEIGHT);
    glutInitWindowPosition(WINDOW_POS_X, WINDOW_POS_Y);
    glutCreateWindow("Koch雪花");
    glutDisplayFunc(myDisplay);
    myInit();
    glutMainLoop();//进入消息循环

    return 0;
}
```

3.5.3 心脏线
``` stylus
#include <math.h>
#include <windows.h>
#include <gl/gl.h>
#include <gl/glu.h>
#include <gl/glut.h>
#pragma comment(linker, "/subsystem:\"windows\" /entry:\"mainCRTStartup\"") //设置连接器选项

const int WINDOW_WIDTH = 640;
const int WINDOW_HEIGHT = 480;
const int WINDOW_POS_X = 300;
const int WINDOW_POS_Y = 150; 
const double PI = atan(1.0) * 4;

void myInit()
{
    glClearColor(1.0, 0.0, 0.0, 0.0);
    glColor3f(0.0f, 1.0f, 0.0f);
    glPointSize(4.0);
}

void myDisplay()
{
    double fAdd = 0.01;
    double K = 0.4;
    double fX, fY, fValue;
    glClear(GL_COLOR_BUFFER_BIT);//清屏

    glBegin(GL_POINTS);
    for (float fTheta = 0.0; fTheta <= 360; fTheta += fAdd)
    {
        double fAngle = fTheta / ( 2 * PI);
        fValue = K * (1 + cos(fAngle));
        fX = fValue * cos(fAngle);
        fY = fValue * sin(fAngle);
        glVertex2f(fX, fY);
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
    glutCreateWindow("阿基米德螺线");
    glutDisplayFunc(myDisplay);//注册重绘回调函数
    myInit();
    glutMainLoop();//进入消息循环

    return 0;
}
```
玫瑰曲线
``` stylus
#include <math.h>
#include <windows.h>
#include <gl/gl.h>
#include <gl/glu.h>
#include <gl/glut.h>
#pragma comment(linker, "/subsystem:\"windows\" /entry:\"mainCRTStartup\"") //设置连接器选项

const int WINDOW_WIDTH = 640;
const int WINDOW_HEIGHT = 480;
const int WINDOW_POS_X = 300;
const int WINDOW_POS_Y = 150; 
const double PI = atan(1.0) * 4;

void myInit()
{
    glClearColor(1.0, 0.0, 0.0, 0.0);
    glColor3f(0.0f, 1.0f, 0.0f);
    glPointSize(4.0);
}

void myDisplay()
{
    double fAdd = 0.01;
    double K = 1;
    double fX, fY, fValue;
    int N = 5;
    glClear(GL_COLOR_BUFFER_BIT);//清屏

    glBegin(GL_POINTS);
    for (float fTheta = 0.0; fTheta <= 360; fTheta += fAdd)
    {
        double fAngle = fTheta / ( 2 * PI);
        fValue = K * cos(N * fAngle);
        fX = fValue * cos(fAngle);
        fY = fValue * sin(fAngle);
        glVertex2f(fX, fY);
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
    glutCreateWindow("玫瑰曲线");
    glutDisplayFunc(myDisplay);//注册重绘回调函数
    myInit();
    glutMainLoop();//进入消息循环

    return 0;
}
```
阿基米德曲线
``` stylus
#include <math.h>
#include <windows.h>
#include <gl/gl.h>
#include <gl/glu.h>
#include <gl/glut.h>
#pragma comment(linker, "/subsystem:\"windows\" /entry:\"mainCRTStartup\"") //设置连接器选项

const int WINDOW_WIDTH = 640;
const int WINDOW_HEIGHT = 480;
const int WINDOW_POS_X = 300;
const int WINDOW_POS_Y = 150; 
const double PI = atan(1.0) * 4;

void myInit()
{
    glClearColor(1.0, 0.0, 0.0, 0.0);
    glColor3f(0.0f, 1.0f, 0.0f);
    glPointSize(4.0);
}

void myDisplay()
{
    double fAdd = 0.01;
    double A = 0.01;
    double fX, fY, fValue;
    glClear(GL_COLOR_BUFFER_BIT);//清屏

    glBegin(GL_POINTS);
    for (float fTheta = 0.0; fTheta <= 360; fTheta += fAdd)
    {
        double fAngle = fTheta / ( 2 * PI);
        fValue = A * fAngle;
        fX = fValue * cos(fAngle);
        fY = fValue * sin(fAngle);
        glVertex2f(fX, fY);
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
    glutCreateWindow("阿基米德螺线");
    glutDisplayFunc(myDisplay);//注册重绘回调函数
    myInit();
    glutMainLoop();//进入消息循环

    return 0;
}
```
对数螺旋线
``` stylus
#include <math.h>
#include <windows.h>
#include <gl/gl.h>
#include <gl/glu.h>
#include <gl/glut.h>
#pragma comment(linker, "/subsystem:\"windows\" /entry:\"mainCRTStartup\"") //设置连接器选项

const int WINDOW_WIDTH = 640;
const int WINDOW_HEIGHT = 480;
const int WINDOW_POS_X = 300;
const int WINDOW_POS_Y = 150; 
const double PI = atan(1.0) * 4;

void myInit()
{
    glClearColor(1.0, 0.0, 0.0, 0.0);
    glColor3f(0.0f, 1.0f, 0.0f);
    glPointSize(2.0);
}

void myDisplay()
{
    double fAdd = 0.01;
    double K = 0.018;
    double a = 0.07;
    double fX, fY, fValue;
    glClear(GL_COLOR_BUFFER_BIT);//清屏

    glBegin(GL_POINTS);
    for (float fTheta = 0.0; fTheta <= 360; fTheta += fAdd)
    {
        double fAngle = fTheta / ( 2 * PI);
        fValue = K * exp(a * fAngle);
        fX = fValue * cos(fAngle);
        fY = fValue * sin(fAngle);
        glVertex2f(fX, fY);
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
    glutCreateWindow("对数螺旋线");
    glutDisplayFunc(myDisplay);//注册重绘回调函数
    myInit();
    glutMainLoop();//进入消息循环

    return 0;
}
```