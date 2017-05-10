---
title: 计算机图形学OpenGL版第五章代码汇总
tags:
  - 计算机图形学OpenGL版源代码
id: 392
categories:
  - 图形图像
  - 图形学
  - OpenGL
date: 2012-11-12 21:13:34
---

5.6.2 网格场景

``` stylus
#include <windows.h>
#include <gl/gl.h>
#include <gl/glu.h>
#include <gl/glut.h>
#pragma comment(linker, "/subsystem:\"windows\" /entry:\"mainCRTStartup\"")

const int WINDOW_WIDTH = 640;
const int WINDOW_HEIGHT = 480;
const int WINDOW_POS_X = 300;
const int WINDOW_POS_Y = 150;

void myInit()
{
    glClearColor(1.0f, 1.0f, 1.0f, 0.0f);
    glViewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
}

//draw a z-axis, with cone at end
void axis(double length)
{
    glPushMatrix();
    glBegin(GL_LINES);
    glVertex3d(0, 0, 0);
    glVertex3d(0, 0, length);
    glEnd();
    glTranslated(0, 0, length - 0.2);//平移
    glutWireCone(0.04, 0.2, 12, 9);
    glPopMatrix();
}

void displayWire()
{
    glMatrixMode(GL_PROJECTION);//设置视景体
    glLoadIdentity();
    glOrtho(-2.0 * 64 / 48, 2.0 * 64 / 48, -2.0, 2.0, 0.1, 100);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    gluLookAt(1.0, 1.0, 2.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);

    glClear(GL_COLOR_BUFFER_BIT);
    glColor3d(0, 0, 0);

    axis(0.5);//z-axis
    glPushMatrix();
    glRotated(-90, 1.0, 0, 0);
    axis(0.5);//y-axis
    glRotated(90.0, 0, 1.0, 0);
    axis(0.5);//x-axis
    glPopMatrix();

    glPushMatrix();
    glTranslated(0.5, 0.5, 0.5);
    glutWireCube(1.0);//线框立方体
    glPopMatrix();

    glColor3d(1.0, 0, 0);
    glPushMatrix();
    glTranslated(1.0, 1.0, 0);
    glutWireSphere(0.25, 10, 8);//线框球体
    glPopMatrix();

    glColor3d(0, 1.0, 0);
    glPushMatrix();
    glTranslated(1.0, 0, 1.0);
    glutWireCone(0.2, 0.5, 10, 8);//线框圆锥体
    glPopMatrix();

    glColor3d(0, 0, 1.0);
    glPushMatrix();
    glTranslated(1.0, 1.0, 1.0);
    glutWireTeapot(0.2);//线框茶壶
    glPopMatrix();

    glColor3d(1.0, 0, 1.00);
    glPushMatrix();
    glTranslated(0, 1.0, 0);
    glutWireTorus(0.1, 0.3, 10, 10);//线框花环
    glPopMatrix();

    glColor3d(0, 1.0, 1.0);
    glPushMatrix();
    glTranslated(1.0, 0, 0);
    glScaled(0.15, 0.15, 0.15);
    glutWireDodecahedron();//线框12面体
    glPopMatrix();

    glColor3d(0.1, 0.5, 0.2);
    glPushMatrix();
    glTranslated(0, 1.0, 1.0);
    glutWireCube(0.25);
    glPopMatrix();

    glPushMatrix();
    glTranslated(0, 0, 1.0);
    GLUquadricObj* qobj = gluNewQuadric();//创建二次曲面对象
    gluQuadricDrawStyle(qobj, GLU_LINE);
    glColor3d(0.3, 0.5, 0.4);
    gluCylinder(qobj, 0.2, 0.2, 0.4, 8, 8);//圆柱体
    glPopMatrix();
    glFlush();
}

int main(int argc, char** argv)
{
    glutInit(argc, argv);
    glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB);
    glutInitWindowSize(WINDOW_WIDTH, WINDOW_HEIGHT);
    glutInitWindowPosition(WINDOW_POS_X, WINDOW_POS_Y);
    glutCreateWindow("Transformation Test -Wireframes");
    glutDisplayFunc(displayWire);
    myInit();
    glutMainLoop();//进入消息循环

    return 0;
}
```

5.6.3 着色三维场景绘制

``` stylus
#include
#include <gl/gl.h>
#include <gl/glu.h>
#include <gl/glut.h>
#pragma comment(linker, "/subsystem:\"windows\" /entry:\"mainCRTStartup\"")

const int WINDOW_WIDTH = 640;
const int WINDOW_HEIGHT = 480;
const int WINDOW_POS_X = 300;
const int WINDOW_POS_Y = 150;

void myInit()
{
    glEnable(GL_LIGHTING);//enable the light source
    glEnable(GL_LIGHT0);
    glShadeModel(GL_SMOOTH);//光滑着色
    glEnable(GL_DEPTH_TEST);//启用深度测试,根据坐标的远近自动隐藏被遮住的图形
    glEnable(GL_NORMALIZE);//根据函数glNormal的设置条件，启用法向量
    glClearColor(1.0f, 1.0f, 1.0f, 0.0f);
    glViewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
}

//draw thin wall with top = xz-plane, corner at origin
void wall(double thickness)
{
    glPushMatrix();
    glTranslated(0.5, 0.5 * thickness, 0.5);
    glScaled(1.0, thickness, 1.0);
    glutSolidCube(1.0);
    glPopMatrix();
}

//table leg
void tableLeg(double thick, double len)
{
    glPushMatrix();
    glTranslated(0, len / 2, 0);
    glScaled(thick, len, thick);
    glutSolidCube(1.0);
    glPopMatrix();
}

//draw one axis of the unit jack-a stretched sphere
void jackPart()
{
    glPushMatrix();
    glScaled(0.2, 0.2, 1.0);
    glutSolidSphere(1, 15, 15);
    glPopMatrix();

    glPushMatrix();
    glTranslated(0, 0, 1.2);//ball on one end
    glutSolidSphere(0.2, 15, 15);
    glTranslated(0, 0, -2.4);
    glutSolidSphere(0.2, 15, 15);//ball on the other end
    glPopMatrix();
}

//draw a unit jact out of spheroids
void jack()
{
    glPushMatrix();
    jackPart();
    glRotated(90.0, 0, 1, 0);
    jackPart();
    glRotated(90.0, 1.0, 0, 0);
    jackPart();
    glPopMatrix();
}

//draw the table - a top and four legs
//绘画桌子时候，外部调用已经使原点到达桌子中间了
void table(double topWid, double topThick, double legThick, double legLen)
{
    glPushMatrix();
    glTranslated(0, legLen, 0);
    glScaled(topWid, topThick, topWid);
    glutSolidCube(1.0);//桌面
    glPopMatrix();

    double dist = 0.95 * topWid / 2.0 - legThick / 2.0;
    glPushMatrix();
    //glTranslated(dist, 0, dist);
    glTranslated(dist, 0, dist);
    tableLeg(legThick, legLen);
    glTranslated(0, 0, -2 * dist);
    tableLeg(legThick, legLen);
    glTranslated(-2 * dist, 0, 2 * dist);
    tableLeg(legThick, legLen);
    glTranslated(0, 0, -2 * dist);
    tableLeg(legThick, legLen);
    glPopMatrix();
}

void displaySolid()
{
    //设置表面纹理属性
    GLfloat mat_ambient[] = {0.7, 0.7, 0.7, 1.0};
    GLfloat mat_diffuse[] = {0.6, 0.6, 0.6, 1.0};
    GLfloat mat_specular[] = {1.0, 1.0, 1.0, 1.0};//反射
    GLfloat mat_shininess[] = {50.0};//光

    glMaterialfv(GL_FRONT, GL_AMBIENT, mat_ambient);//环境光材质
    glMaterialfv(GL_FRONT, GL_DIFFUSE, mat_diffuse);//漫反射
    glMaterialfv(GL_FRONT, GL_SPECULAR, mat_specular);//镜面反射
    glMaterialfv(GL_FRONT, GL_SHININESS, mat_shininess);//光亮

    //设置光源属性
    GLfloat lightIntensity[] = {0.7, 0.7, 0.7, 1.0};
    GLfloat lightPosition[] = {2.0, 6.0, 3.0, 0.0};
    glLightfv(GL_LIGHT0, GL_POSITION, lightPosition);//设置光源0的位置
    glLightfv(GL_LIGHT0, GL_DIFFUSE, lightIntensity);//光源漫反射强度的RGBA值

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    double winHt = 1.0; // half - height of th window
    glOrtho(-winHt * 64 / 48.0, winHt * 64 / 48.0, -winHt, winHt, 0.1, 100.0);

    glMatrixMode(GL_MODELVIEW);//设置照相机
    glLoadIdentity();
    gluLookAt(2.3, 1.3, 2, 0, 0.25, 0, 0.0, 1.0, 0.0);

    //start draw
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glPushMatrix();
    glTranslated(0.4, 0.4, 0.6);
    glRotated(45, 0, 0, 1);
    glScaled(0.08, 0.08, 0.08);
    jack();//draw the jack
    glPopMatrix();

    glPushMatrix();
    glTranslated(0.6, 0.38, 0.5);
    glRotated(30, 0, 1, 0);
    glutSolidTeapot(0.08);//draw the teapot
    glPopMatrix();

    glPushMatrix();
    glTranslated(0.25, 0.42, 0.35);
    glutSolidSphere(0.1, 15, 15);//draw the sphere
    glPopMatrix();

    glPushMatrix();
    glTranslated(0.4, 0, 0.4);
    table(0.6, 0.02, 0.02, 0.3);//draw the table
    glPopMatrix();

    wall(0.02); //wall #1: in xz-plane
    glPushMatrix();
    glRotated(90.0, 0.0, 0.0, 1.0);
    wall(0.02);//wall #2: in xy-plane
    glRotated(90.0, 1.0, 0.0, 0.0);
    wall(0.02);
    glPopMatrix();//wall #3: in yz-plane

    glFlush();
}

int main(int argc, char** argv)
{
    glutInit(argc, argv);
    glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB | GLUT_DEPTH);
    glutInitWindowSize(WINDOW_WIDTH, WINDOW_HEIGHT);
    glutInitWindowPosition(WINDOW_POS_X, WINDOW_POS_Y);
    glutCreateWindow("Shaded example-3D scene");
    glutDisplayFunc(displaySolid);
    myInit();
    glutMainLoop();//进入消息循环

    return 0;
}
```

5.6.4 使用SDL从文件中读取场景描述

[SDLDraw](https://pan.baidu.com/s/1nvvSLKl)