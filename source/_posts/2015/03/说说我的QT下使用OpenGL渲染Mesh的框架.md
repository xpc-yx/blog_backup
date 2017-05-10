---
title: 说说我的QT下使用OpenGL渲染Mesh的框架
tags:
  - cgal
  - mesh
  - OpenGL
  - Qt
  - 框架
id: 1518
categories:
  - 图形图像
  - - 图形学
  - - - OpenGL
date: 2015-03-13 21:22:39
---

我终于把界面换成qt的了，即使我从大二开始就用mfc，一直用到去年上半年。也终于到了，我实在受不了mfc代码混乱的时候了，qt那么方便的东西，我为什么不早点用了。这里就不吐槽mfc的混乱，qt的方便了。在mfc里面建立一个复杂的界面，比如说有dock窗口，或者tab页面的，代码多，而且混乱麻烦，更无语的是，每次我都必须去搜索下，解决各种各样的问题，有的还可以理解，有的就是莫名其妙了。更别说什么代码清晰，跨平台之类的，何止是天方夜谭。

下面，说说我自己逐渐搭建的这个框架吧。其实，这个框架是从我上一个项目里，使用mfc的单文档单视图，主窗口里面有几个dockpane，视图里面放置了渲染OpenGL的子窗口，过渡来的。在qt的框架里面，mfc所有的这些恶心的东西都没有了，只剩下一个MainWindow类。在这个类里面，创建菜单，工具条，状态条，主窗口，dock窗口，tab窗口。代码简洁方便。渲染opengl的窗口设置为MainWindow的主widget。渲染窗口只是一个普通的widget而已，可以任意放置。

这样的做法能够把界面和渲染窗口独立出来，渲染窗口对应一个独立的类(COglWidget)，所以方便创建不同类型的复杂界面。我觉得我应该先用viso画个类图，才能说清楚。下图是我的界面。中间是COglWidget。右侧是一个DockWidget，里面放置了个设置Mesh属性的widget。

![](https://c7.staticflickr.com/8/7463/26842619574_12cf1f5142_o.jpg)

通过主窗口的构造函数，可以看看如何创建这个界面，虽然在主窗口里面做这么的事情不是个好的习惯。

``` stylus
CMainWindow::CMainWindow(QWidget *parent)
        : QMainWindow(parent)
    {
        //setWindowFlags(this->windowFlags()  ~Qt::WindowMaximizeButtonHint);//隐藏最大化按钮
        setWindowTitle(tr("Skeleton Extract"));

        m_pSEMesh = new CSEMesh();
        m_pOglForSE = new COglWidget(this, m_pSEMesh);
        m_pSEMesh->SetOglWidget(m_pOglForSE);
        setCentralWidget((QWidget*)m_pOglForSE);//设置中间是渲染OpenGL的widget      

        m_pPCMesh = new CPointCloudMesh();
        m_pOglForPC = new COglWidget(this, m_pPCMesh);
        //m_pOglForPC->SetEye(0.0, 0.0, 1.0);
        m_pOglForPC->setFixedSize(960, 720);
        m_pOglForPC->setWindowTitle(tr("Point Cloud For Geodesic Matrix Eigen Vector"));
        m_pOglForPC->move((QApplication::desktop()->width() - m_pOglForPC->width()) / 2,
            (QApplication::desktop()->height() - m_pOglForPC->height())/2);
        m_pOglForPC->hide();
        m_pOglForPC->setWindowFlags(Qt::Window);

        CreateActions();
        CreateMenus();
        CreateToolBars();
        CreateStatusBar();
        CreateDockWidgets();

        setMinimumSize(960, 720);
        setWindowState(Qt::WindowMaximized);

        std::string strName = "MeshData\\bunny_3k.m";
        m_pSEMesh->LoadModel(strName.c_str());
        m_pMeshNameLabel->setText(QString(strName.c_str()));
    }
```

再来看一个使用tabwidget的界面，记得在mfc中使用tab页面应该是比较麻烦，我也没用过。不过，在qt里面，唯一需要改变的是把tabwidget设置为central的widget，把其它widget加入到tab页面里面就行了。效果如图：
![](https://c5.staticflickr.com/8/7433/27175531460_7ebec89490_o.jpg)
这个界面的创建代码如下，这里我把菜单，工具条，状态栏都去掉了。

``` stylus
CMainWindow::CMainWindow(QWidget *parent)
        : QMainWindow(parent)
    {
        //setWindowFlags(this->windowFlags()  ~Qt::WindowMaximizeButtonHint);//隐藏最大化按钮
        setWindowTitle(tr("Virtual Box"));

        m_pMesh = new CCubeMesh();
        m_pOglWidget = new COglWidget(this, m_pMesh);

        m_pMainViewMesh = new CCubeMesh();
        m_pMainViewMesh->DrawStyle(CCubeMesh::MAIN_VIEW);
        m_pMainViewWidget = new CViewWidget(this, m_pMainViewMesh);

        m_pTopViewMesh = new CCubeMesh();
        m_pTopViewMesh->DrawStyle(CCubeMesh::TOP_VIEW);
        m_pTopViewWidget = new CViewWidget(this, m_pTopViewMesh);

        m_pSideViewMesh = new CCubeMesh();
        m_pSideViewMesh->DrawStyle(CCubeMesh::SIDE_VIEW);
        m_pSideViewWidget = new CViewWidget(this, m_pSideViewMesh);

        //CreateActions();
        //CreateMenus();
        //CreateToolBars();
        //CreateStatusBar();
        //CreateDockWidgets();

        setMinimumSize(960, 720);
        setWindowState(Qt::WindowMaximized);

        //std::string strName = "cube.obj";
        //m_pMesh->LoadModel(strName.c_str());
        //m_pMeshNameLabel->setText(QString(strName.c_str()));
        m_pTabWidget = new QTabWidget(this);
        m_pTabWidget->addTab(m_pOglWidget, "Cube View");
        m_pTabWidget->addTab(m_pMainViewWidget, "Main View");
        m_pTabWidget->addTab(m_pTopViewWidget, "Top View");
        m_pTabWidget->addTab(m_pSideViewWidget, "Side View");
        setCentralWidget((QWidget*)m_pTabWidget);
    }
```

从上面的代码中，可以看到创建一个OglWidget需要一个Mesh指针。在我的框架中，COglWidget内中只使用几个固定的Mesh函数。因此，可以把COglWidget实现为依赖于一个IMesh接口，这样就进一步把OpenGL窗口和Mesh分离开来。不管Mesh类的具体实现如何，OpenGL窗口只需要依赖IMesh接口，因此，第一个界面里面的Mesh类实际上组合了一个CGAL的CGAL::Polyhedron_3对象。而第二个界面的Mesh类是一个简单的渲染长方体的类，不过支持渲染多个视图而已。
下面说说，COglWidget类具有哪些功能。首先，渲染Mesh，包括设置视口，eye，投影，光照，背景等等，其次，处理鼠标按键操作模型，我的实现是把所有的鼠标按键消息都丢给了下层的一个trackball类，这个trackball类支持旋转缩放移动模型，另外还写了几个打开文件，以及选取背景色的操作。
现在到了Mesh的部分了。因为跟OpenGL窗口相关的只是IMesh接口，所以，我可以任意实现实际的Mesh类。
IMesh的定义如下，

``` stylus
#ifndef IMESH_H
#define IMESH_H
#include "libyx/vertex.h"

namespace LibYX
{
    struct IMesh
    {
        IMesh()
        {
            m_pMatMV = new double[16];
            m_pMatProj = new double[16];
            m_pViewport = new int[4];
        }

        virtual ~IMesh()
        {
            FreeModel();
            delete[] m_pMatMV;
            delete[] m_pMatProj;
            delete[] m_pViewport;
        }

        virtual bool LoadModel(const char* pFilename) { return true; }
        virtual void SaveModel(const char* sFilename) {}
        virtual void UnifyModel() {}

        virtual bool HasModelLoad() const { return true; }
        virtual void FreeModel() {}

        virtual void InitData() {}
        virtual void DestroyData() {}

        virtual void DrawScene()
        {
            glGetDoublev(GL_MODELVIEW_MATRIX, m_pMatMV);
            glGetDoublev(GL_PROJECTION_MATRIX, m_pMatProj);
            glGetIntegerv(GL_VIEWPORT, m_pViewport);
        }

        void WindowWidth(int nWidth) { m_nWinWidth = nWidth; }
        int WindowWidth() const { return m_nWinWidth; }
        void WindowHeight(int nHeight) { m_nWinHeight = nHeight; }
        int WindowHeight() const { return m_nWinHeight; }

    protected:
        double* m_pMatMV;//模型视图矩阵
        double* m_pMatProj;//投影矩阵
        int* m_pViewport;//视口
        int m_nWinWidth;
        int m_nWinHeight;

    protected:
        v3d m_vMax, m_vMin;         // bounding box of the scene
    };
};

#endif
```

其中，DrawScene()是渲染接口，另外还有加载模型的接口等，里面还有些数据。我用CTriMesh继承IMesh接口，同时组合Enriched_Model *m_pModel的指针，创建一个CGAL的多边形网格模型，实际的操作基本都交给m_pModel。这个类的定义太复杂了，就不贴了。这个类里面我集成了基本操作，比如按照点，线，面方式渲染，渲染包围盒，坐标轴，法线，顶点，边，面的索引等，加载和保存模型等等。因此，CTriMesh作为模型的基类，在实际的项目中，再继承CTriMesh，比如第一个界面中的CSEMesh，在CSEMesh中进行具体的处理。
所以，实际的算法实现都在CSEMesh里面。因为，IMesh和CTriMesh，COglWidget可以固化了。能够变化的只是CMainWindow。如果要添加新的代码，只能继承CTriMesh，在子类里面实现具体的算法，也算是对修改关闭对扩展开放吧。

因此，如果再做类似的东西，我就有一个很方便的框架了。。。鉴于不少人留言要代码，有兴趣的可以参考这个[QtRenderMesh](https://pan.baidu.com/s/1eSbiwYe)。