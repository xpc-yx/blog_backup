---
title: 计算机图形学OpenGL版第二章源代码汇总
tags:
  - 计算机图形学OpenGL版源代码
id: 357
categories:
  - 图形图像
  - 图形学
  - OpenGL
date: 2012-11-07 16:42:49
---

最近在用这本书学习计算机图形学，发现这本书在网上基本找不到配套的代码，找到的也是乱七八糟的，很不爽的那种，或者根本是语言初学者对着敲的。故打算把自己写的每个例子贡献出来。


散乱点图:
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
Sierpinski垫片
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
const int NUM = 55000;

struct GLintPoint
{
    GLint x;
    GLint y;
}; 
GLintPoint pts[3] = {{10, 10}, {600, 10}, {300, 600}};

void myInit()
{
    glClearColor(1.0, 1.0, 1.0, 0.0);//设置背景颜色为亮白
    glColor3f(0.0f, 0.0f, 0.0f);//设置绘图颜色为黑色
    glPointSize(4.0);//设置点的大小为4*4像素
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluOrtho2D(0.0, WINDOW_WIDTH, 0.0, WINDOW_HEIGHT);//以上三句话合起伙是设置窗口的坐标系
}

void drawDot(GLintPoint pt)
{
    glBegin(GL_POINTS);
    glVertex2i(pt.x, pt.y);
    glEnd();
}

void sierpinskiRender()
{
    glClear(GL_COLOR_BUFFER_BIT);//清屏
    int nIndex = rand() % 3;
    GLintPoint pt = pts[nIndex];

    drawDot(pt);
    for (int i = 0; i < NUM; ++i)
    {
        nIndex = rand() % 3;
        pt.x = (pt.x + pts[nIndex].x) / 2;
        pt.y = (pt.y + pts[nIndex].y) / 2;
        drawDot(pt);
    }
    glFlush();//送往设备显示
}

int main(int argc, char** argv)
{
    glutInit(argc, argv);
    glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB);//设置显示模式
    glutInitWindowSize(WINDOW_WIDTH, WINDOW_HEIGHT);
    glutInitWindowPosition(WINDOW_POS_X, WINDOW_POS_Y);
    glutCreateWindow("Sierpinski垫片");
    glutDisplayFunc(sierpinskiRender);//注册重绘回调函数
    myInit();
    srand(time(NULL));
    glutMainLoop();//进入消息循环

    return 0;
}
```
绘制函数曲线:
``` stylus
#include <math.h>
#include <windows.h>
#include <gl/gl.h>
#include <gl/glu.h>
#include <gl/glut.h>
#pragma comment( linker, "/subsystem:\"windows\" /entry:\"mainCRTStartup\"" ) //设置连接器选项

const int WINDOW_WIDTH = 640;
const int WINDOW_HEIGHT = 480;
const int WINDOW_POS_X = 300;
const int WINDOW_POS_Y = 150; 
const double PI = atan(1.0) * 4.0; 
GLdouble A, B, C, D;

void myInit()
{
    glClearColor(1.0, 1.0, 1.0, 0.0);//设置背景颜色为亮白
    glColor3f(0.0f, 0.0f, 0.0f);//设置绘图颜色为黑色
    glPointSize(2.0);//设置点的大小为2*2像素
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluOrtho2D(0.0, WINDOW_WIDTH, 0.0, WINDOW_HEIGHT);//以上三句话合起伙是设置窗口的坐标系
    A = WINDOW_WIDTH / 4.0;
    B = 0.0;
    C = D = WINDOW_HEIGHT / 2.0;
}

void myDisplay()
{
    GLdouble fAdd = 0.001;

    glClear(GL_COLOR_BUFFER_BIT);//清屏
    glBegin(GL_POINTS);
    for (GLdouble x = 0.0; x < 4.0; x += fAdd)
    {
        GLdouble fValue = exp(-x) * cos(2 * PI * x);
        glVertex2d(A * x + B, C * fValue + D);
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
    glutCreateWindow("Dot Plot of a Function");
    glutDisplayFunc(myDisplay);//注册重绘回调函数
    myInit();
    glutMainLoop();//进入消息循环

    return 0;
}
```
画矩形:
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
const int NUM = 8;
const int BOARD_WIDTH = WINDOW_WIDTH / NUM;
const int BOARD_HEIGHT = WINDOW_HEIGHT / NUM;
const GLfloat r1 = 0.0, g1 = 0.0, b1 = 0.0;
const GLfloat r2 = 1.0, g2 = 1.0, b2 = 1.0;

struct GLintPoint
{
    GLint x;
    GLint y;
};

void myInit()
{
    glClearColor(1.0, 1.0, 1.0, 0.0);//设置背景颜色为亮白
    glColor3f(0.0f, 0.0f, 0.0f);//设置绘图颜色为黑色
    glPointSize(2.0);//设置点的大小为2*2像素
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluOrtho2D(0.0, WINDOW_WIDTH, 0.0, WINDOW_HEIGHT);//以上三句话合起伙是设置窗口的坐标系
}

//根据中心,高和宽绘画矩形
void drawRectangleCenter(GLintPoint center, double fWidth, double fHeight)
{
    glRectf(center.x - fWidth / 2.0, center.y - fHeight / 2.0,
            center.x + fWidth / 2.0, center.y + fHeight / 2.0);
}

//根据左上角,高和宽高比绘画矩形
void drawRectangleCornersize(GLintPoint topleft, double fHeight, double fScale)
{
    glRectf(topleft.x, topleft.y, topleft.x + fHeight * fScale, topleft.y + fHeight);
}

void myDisplay()
{
    glClear(GL_COLOR_BUFFER_BIT);//清屏
    GLintPoint center, topleft;

    for (int i = 0; i < NUM; ++i)
    {
        for (int j = 0; j < NUM; ++j)
        {
            if ((i + j) % 2 == 0)
            {
                glColor3f(r1, g1, b1);
                center.x = i * BOARD_WIDTH + BOARD_WIDTH / 2.0;
                center.y = j * BOARD_HEIGHT + BOARD_HEIGHT / 2.0;
                drawRectangleCenter(center, BOARD_WIDTH, BOARD_HEIGHT);
            }
            else
            {
                glColor3f(r2, g2, b2);
                topleft.x = i * BOARD_WIDTH;
                topleft.y = j * BOARD_HEIGHT;
                drawRectangleCornersize(topleft, BOARD_HEIGHT, BOARD_HEIGHT * 1.0 / BOARD_WIDTH);
            }
        }
    }
    glFlush();//送往设备显示
}

int main(int argc, char** argv)
{
    glutInit(argc, argv);
    glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB);//设置显示模式
    glutInitWindowSize(WINDOW_WIDTH, WINDOW_HEIGHT);
    glutInitWindowPosition(WINDOW_POS_X, WINDOW_POS_Y);
    glutCreateWindow("画矩形");
    glutDisplayFunc(myDisplay);//注册重绘回调函数
    myInit();
    glutMainLoop();//进入消息循环

    return 0;
}
```
画棋盘:
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
const int NUM = 8;
const int BOARD_WIDTH = WINDOW_WIDTH / NUM;
const int BOARD_HEIGHT = WINDOW_HEIGHT / NUM;
const GLfloat r1 = 0.0, g1 = 0.0, b1 = 0.0;
const GLfloat r2 = 1.0, g2 = 1.0, b2 = 1.0;

void myInit()
{
    glClearColor(1.0, 1.0, 1.0, 0.0);//设置背景颜色为亮白
    glColor3f(0.0f, 0.0f, 0.0f);//设置绘图颜色为黑色
    glPointSize(2.0);//设置点的大小为2*2像素
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluOrtho2D(0.0, WINDOW_WIDTH, 0.0, WINDOW_HEIGHT);//以上三句话合起伙是设置窗口的坐标系
}

void myDisplay()
{
    glClear(GL_COLOR_BUFFER_BIT);//清屏
    for (int i = 0; i < NUM; ++i)
    {
        for (int j = 0; j < NUM; ++j)
        {
            if ((i + j) % 2 == 0)
            {
                glColor3f(r1, g1, b1);
            }
            else
            {
                glColor3f(r2, g2, b2);
            }
            glRecti(i * BOARD_WIDTH, j * BOARD_HEIGHT,
                    i * BOARD_WIDTH + BOARD_WIDTH, j * BOARD_HEIGHT + BOARD_HEIGHT);
        }
    }
    glFlush();//送往设备显示
}

int main(int argc, char** argv)
{
    glutInit(argc, argv);
    glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB);//设置显示模式
    glutInitWindowSize(WINDOW_WIDTH, WINDOW_HEIGHT);
    glutInitWindowPosition(WINDOW_POS_X, WINDOW_POS_Y);
    glutCreateWindow("棋盘");
    glutDisplayFunc(myDisplay);//注册重绘回调函数
    myInit();
    glutMainLoop();//进入消息循环

    return 0;
}
```
根据不同长宽比画矩形:
``` stylus
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <windows.h>
#include <gl/gl.h>
#include <gl/glu.h>
#include <gl/glut.h>
#pragma comment(linker, "/subsystem:\"windows\" /entry:\"mainCRTStartup\"") //设置连接器选项

const int WINDOW_WIDTH = 400;
const int WINDOW_HEIGHT = 400;
const int WINDOW_POS_X = 300;
const int WINDOW_POS_Y = 150;
const int MAX = 100000;
double R = 1.7;

struct GLintPoint
{
    GLint x;
    GLint y;
};

void myInit()
{
    glClearColor(1.0, 1.0, 1.0, 0.0);//设置背景颜色为亮白
    glColor3f(0.0f, 0.0f, 0.0f);//设置绘图颜色为黑色
    glPointSize(2.0);//设置点的大小为2*2像素
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluOrtho2D(0.0, WINDOW_WIDTH, 0.0, WINDOW_HEIGHT);//以上三句话合起伙是设置窗口的坐标系
}

void myDisplay()
{
    glClear(GL_COLOR_BUFFER_BIT);//清屏

    double fWidth, fHeight;
    if (R > 1.0)
    {
        fWidth = WINDOW_WIDTH;
        fHeight = fWidth / R;
    }
    else
    {
        fHeight = WINDOW_HEIGHT;
        fWidth = fHeight * R;

    }
    glRectf(0.0, 0.0, fWidth, fHeight);
    R = (rand() % MAX) * 1.0 / (MAX / 10.0);

    glFlush();//送往设备显示
}

int main(int argc, char** argv)
{
    glutInit(argc, argv);
    glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB);//设置显示模式
    glutInitWindowSize(WINDOW_WIDTH, WINDOW_HEIGHT);
    glutInitWindowPosition(WINDOW_POS_X, WINDOW_POS_Y);
    glutCreateWindow("不同长宽比");
    glutDisplayFunc(myDisplay);//注册重绘回调函数
    myInit();
    srand(time(NULL));
    glutMainLoop();//进入消息循环

    return 0;
}
```
鼠标和键盘:
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

struct GLintPoint
{
    GLint x, y;
};
GLintPoint corner[2];
bool bSelect = false;

void myInit()
{
    glClearColor(1.0, 1.0, 1.0, 0.0);//设置背景颜色为亮白
    glColor3f(0.0f, 0.0f, 0.0f);//设置绘图颜色为黑色
    glPointSize(4.0);//设置点的大小为4*4像素
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluOrtho2D(0.0, WINDOW_WIDTH, 0.0, WINDOW_HEIGHT);//以上三句话合起伙是设置窗口的坐标系
    glLineWidth(4.0);
}

void myDisplay()
{
    glClear(GL_COLOR_BUFFER_BIT);//清屏

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    if (bSelect)
    {
        glBegin(GL_QUADS);
        glVertex2i(corner[0].x, corner[0].y);
        glVertex2i(corner[0].x, corner[1].y);
        glVertex2i(corner[1].x, corner[1].y);
        glVertex2i(corner[1].x, corner[0].y);
        glEnd();
    }
    glutSwapBuffers();
}

void myMouse(int button, int state, int x, int y)
{
    if (button == GLUT_LEFT_BUTTON  state == GLUT_DOWN)
    {
        corner[0].x = x;
        corner[0].y = WINDOW_HEIGHT - y;
        bSelect = true;
    }
    glutPostRedisplay();
}

//鼠标在窗口上面移动并且没有按钮按下
void myPassiveMotion(int x, int y)
{
    corner[1].x = x;
    corner[1].y = WINDOW_HEIGHT - y;
    glutPostRedisplay();
}

void myKeyboard(unsigned char key, int mouseX, int mouseY)
{
    switch (key)
    {
    case 'P':
    case 'p':
        glBegin(GL_POINTS);
        glVertex2i(mouseX, WINDOW_HEIGHT - mouseY);
        glEnd();
        glutSwapBuffers();
        break;

    case 'Q':
    case 'q':
        exit(-1);
        break;

    default:
        break;
    }
}

int main(int argc, char** argv)
{
    glutInit(argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB);//设置显示模式
    glutInitWindowSize(WINDOW_WIDTH, WINDOW_HEIGHT);
    glutInitWindowPosition(WINDOW_POS_X, WINDOW_POS_Y);
    glutCreateWindow("Rubber Rect Demo");
    glutDisplayFunc(myDisplay);//注册重绘回调函数
    glutMouseFunc(myMouse);
    glutPassiveMotionFunc(myPassiveMotion);
    glutKeyboardFunc(myKeyboard);
    myInit();
    glutMainLoop();//进入消息循环

    return 0;
}
```
菜单:
``` stylus
#include <windows.h>
#include <gl/gl.h>
#include <gl/glu.h>
#include <gl/glut.h>
#pragma comment(linker, "/subsystem:\"windows\" /entry:\"mainCRTStartup\"") //设置连接器选项

const int WINDOW_WIDTH = 640;
const int WINDOW_HEIGHT = 480;
const int WINDOW_POS_X = 300;
const int WINDOW_POS_Y = 150; 

enum COLOR
{
    RED, GREEN, BLUE, WHITE
};
float angle = 0.0;
float red = 1.0, blue = 1.0, green = 1.0;

void myDisplay()
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);//清屏
    glLoadIdentity();

    glRotatef(angle, 0.0, 1.0, 0.0);
    glColor3f(red, green, blue);
    glBegin(GL_TRIANGLES);//下面的画点坐标为什么是这么设置的了?
    glVertex3f(-0.5, -0.5, 1.0);
    glVertex3f(0.5, 0.0, 0.0);
    glVertex3f(0.0, 0.5, 2.0);
    glEnd();
    angle++;
    glutSwapBuffers();
}

void myMenuEvents(int option)
{
    switch (option)
    {
    case RED: red = 1.0; green = blue = 0.0; break;
    case GREEN: green = 1.0; red = blue = 0.0; break;
    case BLUE: blue = 1.0; red = green = 0.0; break;
    case WHITE: red = green = blue = 1.0; break;
    }
}

int main(int argc, char** argv)
{
    glutInit(argc, argv);
    glutInitDisplayMode(GLUT_DEPTH | GLUT_DOUBLE | GLUT_RGBA);//设置显示模式
    glutInitWindowSize(WINDOW_WIDTH, WINDOW_HEIGHT);
    glutInitWindowPosition(WINDOW_POS_X, WINDOW_POS_Y);
    glutCreateWindow("Menu Test");
    glutDisplayFunc(myDisplay);//注册重绘回调函数
    glutIdleFunc(myDisplay);
    glutCreateMenu(myMenuEvents);
    glutAddMenuEntry("Red", RED);
    glutAddMenuEntry("Blue", BLUE);
    glutAddMenuEntry("Green", GREEN);
    glutAddMenuEntry("Black", WHITE);
    glutAttachMenu(GLUT_RIGHT_BUTTON);
    glutMainLoop();//进入消息循环

    return 0;
}
```
姜饼人:
``` stylus
#include <math.h>
#include <stdlib.h>
#include <windows.h>
#include <gl/gl.h>
#include <gl/glu.h>
#include <gl/glut.h>
#pragma comment(linker, "/subsystem:\"windows\" /entry:\"mainCRTStartup\"") //设置连接器选项

const int WINDOW_WIDTH = 640;
const int WINDOW_HEIGHT = 480;
const int WINDOW_POS_X = 300;
const int WINDOW_POS_Y = 150;
const int M = 40;
const int L = 3;
const int TIMES = 1000000;

struct GLintPoint
{
    GLint x, y;
};
GLintPoint p, q;

void myInit()
{
    glClearColor(1.0, 1.0, 1.0, 0.0);//设置背景颜色为亮白
    glColor3f(0.0f, 0.0f, 0.0f);//设置绘图颜色为黑色
    glPointSize(2.0);//设置点的大小为2*2像素
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluOrtho2D(0.0, WINDOW_WIDTH, 0.0, WINDOW_HEIGHT);//以上三句话合起伙是设置窗口的坐标系
    p.x = 121;
    p.y = 115;
}

void myDisplay()
{
    glClear(GL_COLOR_BUFFER_BIT);//清屏
    glBegin(GL_POINTS);
    for (int i = 0; i < TIMES; ++i)
    {
        q.x = M * (1 + 2 * L) - p.y + abs(p.x - L * M);
        q.y = p.x;
        p = q;
        glVertex2f(p.x, p.y);
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
    glutCreateWindow("姜饼人");
    glutDisplayFunc(myDisplay);//注册重绘回调函数
    myInit();
    glutMainLoop();//进入消息循环

    return 0;
}
```