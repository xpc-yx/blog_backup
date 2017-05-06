---
title: OpenGL渲染Obj模型(模型·材质·纹理)
tags:
  - obj模型
  - OpenGL
  - 图形学
id: 692
categories:
  - OpenGL
  - 图形学
date: 2013-03-08 10:53:24
---

这是我寒假的一个作业吧，到最后基本是在学校完成的了。这个程序主要完成的功能是读取**.obj文件**，顺便读取了其附带**.mtl文件**，以及.mtl文件附带的**.tga格式的纹理**(我没有处理其它格式了，因为自己下载的几个模型的纹理都是这种图片格式)。然后，用透视投影，调整视点**对准模型正中央**，渲染在视口里面。程序也提供了键盘上下左右旋转，上下左右移动，放大放小的功能，已经鼠标旋转模型的功能，不过鼠标旋转的效果不好。

首先要介绍下obj模型文件的格式，这个百度或者google肯定能找到不少文章。.obj文件里面主要是定义了点，线，面，当然还描述了其他元素。.mtl文件里面定义了模型的材质以及纹理的路径。我主要描述下我的代码用到的和假定的obj文件格式。
v 1.0  2.3 4.5 //代表一个三维点
v 1.0  2.3 4.5 //代表一个三维点
v 1.0  2.3 4.5 //代表一个三维点
v 1.0  2.3 4.5 //代表一个三维点
vn 1.0 1.0 1.0 //法线
vt 0.3 0.4 //纹理坐标
p 1 //第一个v代表的点
l 1 2 //第一个v和第二个v连接的直线
f 1//  2//  3//  4//  //1,2,3,4构成的面，没有法线和纹理
f 1/1/1 2/1/1 3/1/1 4/1/1  //1,2,3,4构成的面,结构是顶点索引,纹理索引,法线索引
我的代码基本上假定没有法线和纹理索引的时候，**后面也必须带//**。
另外一个最重要的是定义材质库的路径，mtllib xxx.mtl。
至于obj文件更加详细的描述，请查阅更标准的文档吧。

然后，介绍下.mtl的格式，我也只介绍我用到的东西。
比如下面这个材质文件的内容，
newmtl Arakkoa_Gray //定义材质设置的名字，一个材质库可能会出现多个材质设置
d 1.0 //透明度
Kd 1.000000 1.000000 1.000000 //模型散射颜色
Ka 0.250000 0.250000 0.250000 //模型环境颜色
Ks 0.000000 0.000000 0.000000//模型镜面颜色
Ke 0.000000 0.000000 0.000000//模型发射颜色
Ns 0.000000//模型镜面指数
map_Kd Arakkoa_Gray.tga//纹理路径
其它设置我就没有用到了。
至于tga图片的格式，请自行google吧。我只处理了**未压缩**版本的.tga纹理，格式类似于.bmp文件，处理起来也比较简单。

以下是我渲染一个魔兽世界模型的效果，
![](https://c3.staticflickr.com/8/7122/27174491730_279a2a593f_o.jpg)

![](https://c4.staticflickr.com/8/7331/26843716883_1206d1f53e_o.jpg)

基本上**启用光照加上纹理**之后的渲染效果还行。下面我来讲述我整个代码的结构吧。

说实话，这个程序虽然功能不多，但是也可以写出不少代码来的，虽然没多少啰嗦代码，也有近千行。我也定义了不少结构体和类。如下图，
![](https://c2.staticflickr.com/8/7554/27451030815_10517061ce_o.png)
S开头的是结构体，主要定义了顶点，法线，纹理的数据，以及三者的索引(SVertexData)，rgb，Tga文件头。其余的，比如CPoint，CLine，CFace对应obj文件里面的p,l,f元素，这三个类里面有**各自的渲染函数**。
CObj类最复杂，里面有顶点，法线，纹理坐标的数据集合，为了方便，我使用了vector，同时用**reserve预留空间**。还有，点集合，线集合，面集合，材质设置的集合。CObj的渲染函数则是调用点，线，面集合里面的元素对应的渲染函数。其中，最复杂的是面的渲染函数。面的渲染函数会根据材质设置是否改变来**更换材质**，然后再渲染每个面，同时每个面里面也有个vector集合包含顶点等的索引，所以我的程序**不仅仅支持三角形面**。CObj类里面最复杂的是读取.obj模型的函数，函数写了100多行，我也没进行功能拆分了，不细说了，至于读取材质的相对简单点。
CMaterial就描述了我使用的集中材质设置，包括一个CTgaTex类成员等。基本上是在读取的时候初始化下材质，更换材质的时候改变下。CTgaTex主要是读取未压缩的tga文件，并且用读取的数据初始化opengl的纹理设置，更改纹理设置的时候，CMaterial会调用其更改纹理。
CBox类也比较复杂，因为该类关系到透视投影，视点等。我是这样考虑的，我读取模型的时候，确定包括整个模型顶点的**最小长方体**，存储在CBox里面。然后，CBox会求出该长方体的**外接球**，我再把操作的对象改变成该外接球，也就是我的透视投影啊，观察点设置，平移，放缩，旋转什么的都针对该外接球了。所以啊，我对模型操作的函数全部放置在CBox类里面了。我的透视函数是调用的gluPerspective，**近平面是球的前切面，远平面是球的后切面，我的观察点是球心，视点是正对球心离开其4-10倍半径距离的点**。
至于其余全局函数的实现就不介绍了。

给出一些关键的类定义，看了这些类定义，就知道我的代码结构了。
//obj的定义

``` stylus
#ifndef _XPC_YX_OBJ_H
#define _XPC_YX_OBJ_H
#include "vertex.h"
#include "mtl.h"
#include
using std::vector;

//点元素
class CPoint
{
    friend class CObj;
public:
    void Render(CObj obj);//绘制点

private:
    int m_nVI;
};

//线元素
class CLine
{
    friend class CObj;
public:
    void Render(CObj obj);//绘制点

private:
    vector m_vis;
};

//面元素
class CFace
{
    friend class CObj;
public:
    CFace() { m_nNewMtlI = -1; }
    void Render(CObj obj);//绘制面

private:
    vector m_vds;
    int m_nNewMtlI;//所使用新的材质索引(如果不修改材质库此索引为-1)
};

class CBox;
//obj模型
class CObj
{
    friend class CPoint;
    friend class CLine;
    friend class CFace;

    enum {VERTEX = 0, TEXTURE = 1, NORMAL = 2};
public:
    CObj(CBox* pBox) { m_pBox = pBox; }
    CObj(const char* pcszFileName) { LoadFromFile(pcszFileName); }
    int LoadFromFile(const char* pcszFileName);//从文件加载模型
    int LoadMaterials(const char* pcszFileName);//加载材质库
    void Render();//绘制该模型

private:
    static const int VERTEX_INIT_NUM;
    static const int POINT_INIT_NUM;
    static const int LINE_INIT_NUM;
    static const int FACE_INIT_NUM;
    vector m_vs;//顶点坐标集合
    vector m_vts;//顶点纹理坐标集合
    vector m_vns;//顶点法线集合
    vector m_ps;//点集合
    vector m_ls;//线集合
    vector m_fs;//面集合
    vector m_ms;//材质库
    CBox* m_pBox;
};
#endif
```

//CBox的定义

``` stylus
class CBox
{
public:
    void Init()
    {
        m_fXMin = m_fYMin = m_fZMin = INT_MAX;
        m_fXMax = m_fYMax = m_fZMax = INT_MIN;
    }
    void InitBoxInfo();
    void Adjust(SVertex v) { Adjust(v.fX, v.fY, v.fZ); }
    void Adjust(double fX, double fY, double fZ);
    void LookAtBox(int nW, int nH);
    void Big(int nPercent);
    void Small(int nPercent);
    void Left(int nPercent);
    void Right(int nPercent);
    void Up(int nPercent);
    void Down(int nPercent);
    bool IsInBox(SVertex vertex);
    void Move(SVertex one, SVertex two);//移动模型
    void Rotate(SVertex one, SVertex two);//旋转模型
    void RotateLeft(double fTheta);
    void RotateRight(double fTheta);
    void RotateUp(double fTheta);
    void RotateDown(double fTheta);
    void SetLight();

private:
    double m_fXMin;
    double m_fXMax;
    double m_fYMin;
    double m_fYMax;
    double m_fZMin;
    double m_fZMax;
    SVertex m_center;//模型原本的外接球中心
    double m_fRadius;//外接球的半径
    double m_fDistance;//观察点与外接球的距离
    double m_fTheta;//视角
};
```

//材质类的定义

``` stylus
#ifndef _XPC_YX_MTL_H
#define _XPC_YX_MTL_H

#include "tga.h"
#include <windows.h>

class CObj;

struct SRgb
{
    float fR;
    float fG;
    float fB;
    float fA;
};

class CMaterial
{
    friend class CObj;
public:
    CMaterial()
    {
        m_emission.fR = m_emission.fG = m_emission.fB = 0.0;
        m_fTrans = 1.0;
    }
    void InitTex();
    void Set();

private:
    SRgb m_ambient;//材质的环境颜色
    SRgb m_diffuse;//
    SRgb m_specular;
    SRgb m_emission;
    float m_fShiness;//镜面指数
    float m_fTrans;//透明度
    char m_szName[MAX_PATH];
    char m_szTextureName[MAX_PATH];
    CTgaTex m_tgaTex;
};
#endif
```

//tga纹理的定义

``` stylus
#ifndef _XPC_YX_TGA_H
#define _XPC_YX_TGA_H
#include <windows.h>

#define RGB16(r,g,b)   ( ((r>>3) << 10) + ((g>>3) << 5) + (b >> 3) )
#define RGB24(r,g,b)   ( ((r) << 16) + ((g) << 8) + (b) )

typedef unsigned char BYTE;
//tga文件头
struct STgaHeader
{
    BYTE  byImageInfoByteCnt;    //The image information length, in byte
    BYTE  byColorTableExist;       //0-have not color table,1-have
    BYTE  byImageType;              //Image type,2-uncompare RGB image,10-compare RGB image
    BYTE  byColorTableInfo[5];    //Color table information
    unsigned short uXOrigin;
    unsigned short uYOrigin;
    unsigned short uWidth;
    unsigned short uHeight;
    unsigned char  chBitsPerPixel;  //每像素的字节数
    unsigned char  chImageDescriptor;
};

class CTgaTex
{
public:
    CTgaTex() { byData = 0; m_szTexName[0] = 0; }
    CTgaTex(const char* pcszFileName) { byData = 0; LoadTga(pcszFileName); }
    ~CTgaTex() { if (byData) free(byData); }
    int LoadTga(const char* pcszFileName);
    void InitTex();
    void SetTexture();

private:
    STgaHeader m_header;
    BYTE* byData;
    char m_szTexName[MAX_PATH];
    unsigned m_uTexName;
};

#endif
```

如果你需要完整的代码，可以留言或者给我发邮件，代码写得不怎么样，不过还是尽力写好一点的了。里面肯定会有让老手觉得不规范的地方的。

由于很多人留言询问代码，为了方便，已上传百度网盘，分享地址：[http://pan.baidu.com/s/1eQJ9mF4](http://pan.baidu.com/s/1eQJ9mF4 "渲染obj模型") 密码：ovnv