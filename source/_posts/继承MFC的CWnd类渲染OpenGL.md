---
title: 继承MFC的CWnd类渲染OpenGL
tags:
id: 1054
categories:
  - 图形学
  - OpenGL
date: 2014-02-15 11:12:31
---

我以前使用过glut的窗口环境，以及在CView中渲染OpenGL的类。但是这些都不怎么方便。首先，在windows下，MFC比glut，glui作为界面框架要方便很多，其次，CView类没有单独的CWnd类方便，自定义的窗口类可以**嵌入**到任意窗口内部，这样就可以脱离框架，方便移植了。
我的思路是实现一个COglWnd类。该类可以负责构建OpenGL渲染环境，并且调用模型类渲染，另外负责响应鼠标旋转放缩移动模型等，也可以添加一些额外的操作。
该类需要提供的外部接口，创建窗口和渲染模型。
COglWnd使用方法：在容器类（比如CView）的OnCreate函数内调用COglWnd的Create函数创建窗口，在容器类的OnSize函数类内调用COglWnd类的**SetWindowPos**移动窗口位置。
COglWnd的实现：
1.构建OpenGL渲染环境。这个必须在COglWnd的OnCreate函数类实现。具体实现我写在了SetupGLContext函数内部。该函数主要是依次调用了ChoosePixelFormat，SetPixelFormat，wglCreateContext，wglMakeCurrent函数而已。基本上就是设置下OpenGL的一些参数，然后构造下渲染环境的意思，非常好理解。具体可以google。
2.渲染。这里需要屏蔽**OnEraseBkgnd**函数，还有OnPaint内调用实际的渲染函数RenderScene而已。这里需要注意的是，我们屏蔽了CWnd的背景擦除函数，这样能够避免一定程度的闪烁。还有，当我们需要更新显示的时候，可以直接调用RenderScene而不是调用MFC的Invalidate函数。这样可以略去MFC的消息传递等。
3.鼠标响应。这里旋转我使用了**轨迹球**类。其余的直接调用OpenGL函数即可实现。
下面是我的COglWnd类，内部使用了一个vertex模版类存储数据和渲染球类来实现鼠标响应。上面所述，均可参照我的实现细节。我这个类就是嵌入在CView内作为子窗口使用的。

``` stylus
#include "libyx/vertex.h"
#include "libyx/trackball.h"
#include "Mesh/TriMesh.h"
#include "Mesh/Texture.h"
#include <vector>
// COglWnd

namespace LibYX
{

	class COglWnd : public CWnd
	{
		DECLARE_DYNAMIC(COglWnd)

	public:
		COglWnd();
		virtual ~COglWnd();
		enum CURSOR_TYPE
		{
			CURSOR_HAND = 0, CURSOR_PEN = 1
		};

		enum MOUSE_STATE
		{
			MOUSE_NONE = 0,
			MOUSE_LEFTBUTTON_DOWN = 1, MOUSE_LEFTBUTTON_UP = 2,
			MOUSE_MIDDLEBUTTON_DOWN = 3, MOUSE_MIDDLEBUTTON_UP = 4,
			MOUSE_RIGHTBUTTON_DOWN = 5, MOUSE_RIGHTBUTTON_UP = 6
		};

		//外部接口
	public:
		void Create(CRect rect, CWnd *parent);
		CString LoadModel();
		CString SaveModel();
		bool ChooseDrawColor(v4f color);
		bool ChooseStrokeColor(v4f color);
		CString ChooseDrawTexture();
		bool ChooseBackColor(v4f color);
		void RenderScene();//渲染函数

	public:
		void SetCursorType(int nType) { m_cursorType = nType; }

		//消息处理函数
	protected:
		DECLARE_MESSAGE_MAP()
		afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
		afx_msg void OnSize(UINT nType, int cx, int cy);
		afx_msg void OnDestroy();
		afx_msg void OnPaint();
		afx_msg BOOL OnEraseBkgnd(CDC* pDC);
		afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
		afx_msg void OnLButtonUp(UINT nFlags, CPoint point);
		afx_msg void OnMButtonDown(UINT nFlags, CPoint point);
		afx_msg void OnMButtonUp(UINT nFlags, CPoint point);
		afx_msg void OnRButtonDown(UINT nFlags, CPoint point);
		afx_msg void OnRButtonUp(UINT nFlags, CPoint point);
		afx_msg void OnMouseMove(UINT nFlags, CPoint point);
		afx_msg BOOL OnMouseWheel(UINT nFlags, short zDelta, CPoint pt);
		afx_msg BOOL OnSetCursor(CWnd* pWnd, UINT nHitTest, UINT message);

		//OpenGL函数
	private:
		BOOL SetupGLContext();
		BOOL DetachGLContext();

	private:
		void SetGLViewFrustum(int left, int top, int right, int bottom, float DepthMin, float DepthMax, float Fov);
		void SetGLViewFrustum(int left, int top, int right, int bottom);
		void SetGLFOV(float Fov);
		void ResizeGLViewport(int width, int height);
		void SetEye(v3f pos, v3f dest, v3f up);

	private:
		void InitColor();
		void InitLight();

	private:
		void InitialScene();
		void ReleaseScene();

	private:
		void RenderBackGround();

	public:
		CTriMesh m_mesh;
		CTexture m_backTexture;

	private:
		CRect m_rect;
		CWnd* m_parent;
		int		m_nWinWidth;
		int		m_nWinHeight;
		HDC		m_hDC;
		HGLRC	m_hGLRC;
		float m_fGLDepthMin;
		float m_fGLDepthMax;
		float m_fGLFov;
		BOOL m_bGLSetup;

	private:
		v4f	m_backColor;
		v4f m_diffuseLight;
		v4f m_specularLight;
		v4f	m_ambientLight;
		v4f m_emissionLight;
		v4f m_gloabalAmbientLight;

	private:
		v3f m_eye;
		v3f m_dest;
		v3f m_up;
		Trackball m_trackball;

	private:
		int m_cursorType;
		int m_mouseState;
	};
};
```

GlWnd.cpp : 实现文件

``` stylus
#include "stdafx.h"
#include "OglWnd.h"
#include "../Resource.h"
#include <gl/glew.h>

#pragma comment(lib, "opengl.lib")
#pragma comment(lib, "glu.lib")
#pragma comment(lib, "glew32.lib")

// CGlWnd
namespace LibYX
{

	IMPLEMENT_DYNAMIC(COglWnd, CWnd)

	COglWnd::COglWnd()
	{
		m_bGLSetup = false;
		m_fGLDepthMin = 0.0001f;
		m_fGLDepthMax = 100.0f;
		m_fGLFov = 60.0f;
		m_cursorType = CURSOR_HAND;
		m_mouseState = MOUSE_NONE;
	}

	COglWnd::~COglWnd()
	{

	}

	void COglWnd::Create(CRect rect, CWnd *parent)
	{
		if (m_bGLSetup) return;

		ASSERT(rect);
		ASSERT(parent);
		m_rect = rect;
		m_parent = parent;

		CString className = AfxRegisterWndClass(
			CS_HREDRAW | CS_VREDRAW | CS_OWNDC, NULL, (HBRUSH)GetStockObject(BLACK_BRUSH), NULL);

		CreateEx(0, className, "OglWnd", WS_CHILD | WS_VISIBLE | WS_CLIPSIBLINGS | WS_CLIPCHILDREN,
			rect, parent, 0);
		m_mesh.Wnd(this);
	}

	CString COglWnd::LoadModel()
	{
		char filefilter[] = _T("M Files (*.m) |*.m|Wavefront Files (*.obj) |*.obj|");
		CFileDialog dlg(TRUE, NULL, NULL, OFN_HIDEREADONLY | OFN_OVERWRITEPROMPT,
			filefilter, NULL, 0);
		CString pathname;

		if (IDOK != dlg.DoModal())
			return pathname;

		pathname = dlg.GetPathName();
		if (pathname.IsEmpty() == TRUE)
		{
			AfxMessageBox("输入模型文件名为空!");
			return pathname;
		}

		CString ext = dlg.GetFileExt();
		if (ext == "obj" || ext == "OBJ")
		{
			m_mesh.LoadOBJModel(pathname);
		}
		else if (ext == "m" || ext == "M")
		{
			m_mesh.LoadMModel(pathname);
		}
		RenderScene();

		return pathname;
	}

	CString COglWnd::SaveModel()
	{
		CString pathname;
		if (m_mesh.HasModelLoad() == FALSE)
		{
			return pathname;
		}

		char defExt[] = _T(".obj");
		char filefilter[] = _T("Wavefront Files (*.obj) |*.obj|m Files (*.m) |*.m||");
		CFileDialog dlg(FALSE, defExt, m_mesh.GetModelName().c_str(), OFN_HIDEREADONLY, filefilter, NULL, 0);

		if (IDOK != dlg.DoModal())
			return pathname;

		CString ext = dlg.GetFileExt();

		if (ext == _T("obj") || ext == _T("OBJ"))
		{
			pathname = dlg.GetPathName();
			if (pathname.IsEmpty())
			{
				AfxMessageBox("输入模型文件名为空!");
			}
			else
			{
				m_mesh.SaveOBJModel(pathname);
			}
		}
		else if (ext == _T("m") || ext == _T("M"))// Save model without material)
		{
			pathname = dlg.GetPathName();
			if (pathname.IsEmpty())
			{
				AfxMessageBox("输入模型文件名为空!");
			}
			else
			{
				m_mesh.SaveMModel(pathname);
			}
		}

		return pathname;
	}

	bool COglWnd::ChooseDrawColor(v4f color)
	{
		CColorDialog colorDialog;
		COLORREF colorRef;

		if (colorDialog.DoModal() == IDOK)//如果按下颜色对话框的OK键
		{
			colorRef = colorDialog.GetColor();
			color[0] = GetRValue(colorRef);
			color[1] = GetGValue(colorRef);
			color[2] = GetBValue(colorRef);

			m_mesh.DrawColor(color);
			return true;
		}

		return false;
	}

	bool COglWnd::ChooseStrokeColor(v4f color)
	{
		CColorDialog colorDialog;
		COLORREF colorRef;

		if (colorDialog.DoModal() == IDOK)//如果按下颜色对话框的OK键
		{
			colorRef = colorDialog.GetColor();
			color[0] = GetRValue(colorRef);
			color[1] = GetGValue(colorRef);
			color[2] = GetBValue(colorRef);
			m_mesh.StrokeColor(color);
			RenderScene();
			return true;
		}

		return false;
	}

	bool COglWnd::ChooseBackColor(v4f color)
	{
		CColorDialog colorDialog;
		COLORREF colorRef;

		if (colorDialog.DoModal() == IDOK)//如果按下颜色对话框的OK键
		{
			colorRef = colorDialog.GetColor();
			m_backColor[0] = GetRValue(colorRef);
			m_backColor[1] = GetGValue(colorRef);
			m_backColor[2] = GetBValue(colorRef);
			color = m_backColor;
			glClearColor(m_backColor[0], m_backColor[1], m_backColor[2], 1.0f);
			RenderScene();
			return true;
		}

		return false;
	}

	CString COglWnd::ChooseDrawTexture()
	{
		char filefilter[] = _T("Jpg Files (*.jpg)|*jpg|Bmp Files (*.bmp)|*.bmp|\
							   					Png Files (*.png)|*.png|Gif Files (*.gif)|*.gif|Tga Files (*.tga)|*.tga|");
		CFileDialog dlg(TRUE, NULL, NULL, OFN_HIDEREADONLY | OFN_OVERWRITEPROMPT,
			filefilter, NULL, 0);
		CString strPathName;

		if (dlg.DoModal() == IDOK)
		{
			strPathName = dlg.GetPathName();
			m_mesh.SetTexture(strPathName);
		}

		return strPathName;
	}

	//////////////////////////////////////////////////////////////////////////
	//以下是OpenGL相关的函数
	BOOL COglWnd::SetupGLContext()
	{
		DWORD dwFlags = (PFD_DRAW_TO_WINDOW | PFD_DOUBLEBUFFER | PFD_SUPPORT_OPENGL);

		PIXELFORMATDESCRIPTOR pfd =
		{
			sizeof(PIXELFORMATDESCRIPTOR),	// Structure size,
			1,				// Structure version number
			dwFlags,			// Property flags
			PFD_TYPE_RGBA,			// RGBA mode
			24,				// 24-bit color
			0, 0, 0, 0, 0, 0,		// 8-bit each color
			0, 0, 0, 0, 0, 0, 0,		// No alpha or accum. buffer,
			32,				// 32-bit z-buffer
			0, 0,				// No stencil or aux buffer
			PFD_MAIN_PLANE,			// Mainn layer type
			0,				// Reserved
			0, 0, 0,			// Unsupported.
		};

		m_hDC = GetDC()->m_hDC;

		int PixelFormat = ChoosePixelFormat(m_hDC, pfd);
		BOOL bOk = false;
		bOk = SetPixelFormat(m_hDC, PixelFormat, pfd);
		if (!bOk)
		{
			MessageBox(_T("GL set pixel format fail!"), _T("Error"), MB_OK);
			return bOk;
		}
		m_hGLRC = wglCreateContext(m_hDC);
		bOk = wglMakeCurrent(m_hDC, m_hGLRC);
		if (!bOk)
		{
			MessageBox(_T("Set up GL render context fail!"), _T("Error"), MB_OK);
			return bOk;
		}

		return bOk;
	}

	BOOL COglWnd::DetachGLContext()
	{
		wglMakeCurrent(m_hDC, NULL);
		wglDeleteContext(m_hGLRC);
		::ReleaseDC(this->m_hWnd, m_hDC);

		return TRUE;
	}

	void COglWnd::SetGLViewFrustum(GLint left, GLint top, GLint right, GLint bottom,
		GLfloat DepthMin, GLfloat DepthMax, GLfloat Fov)
	{
		m_fGLDepthMin = DepthMin;
		m_fGLDepthMax = DepthMax;
		m_fGLFov = Fov;

		SetGLViewFrustum(left, top, right, bottom);
	}

	void COglWnd::SetGLViewFrustum(GLint left, GLint top, GLint right, GLint bottom)
	{
		glViewport(left, top, (right - left), (bottom - top));

		float AspectRatio = (float)(right - left) / (float)(bottom - top);
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();

		gluPerspective(m_fGLFov, AspectRatio, m_fGLDepthMin, m_fGLDepthMax);
	}

	void COglWnd::SetGLFOV(GLfloat Fov)
	{
		m_fGLFov = Fov;

		int vp[4];
		glGetIntegerv(GL_VIEWPORT, vp);
		float AspectRatio = (float)(vp[2]) / (float)(vp[3]);

		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();

		gluPerspective(m_fGLFov, AspectRatio, m_fGLDepthMin, m_fGLDepthMax);
	}

	void COglWnd::SetEye(v3f pos, v3f desti, v3f up)
	{
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();
		gluLookAt(pos[0], pos[1], pos[2], desti[0], desti[1], desti[2], up[0], up[1], up[2]);
	}

	void COglWnd::ResizeGLViewport(GLint width, GLint height)
	{
		glViewport(0, 0, width, height);

		float AspectRatio = (float)width / (float)height;

		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();

		gluPerspective(m_fGLFov, AspectRatio, m_fGLDepthMin, m_fGLDepthMax);
	}

	void COglWnd::InitialScene()
	{
		if (glewInit() != GLEW_OK)
		{
			return;
		}

		m_eye[0] = m_eye[1] = 0.0;
		m_eye[2] = 6.0f;
		m_dest[0] = m_dest[1] = m_dest[2] = 0.0;
		m_up[0] = m_up[2] = 0.0;
		m_up[1] = 1.0;
		SetEye(m_eye, m_dest, m_up);

		InitColor();
		InitLight();

		glCullFace(GL_BACK);
		glEnable(GL_CULL_FACE);
		glShadeModel(GL_SMOOTH);
		glEnable(GL_DEPTH_TEST);
		glDepthFunc(GL_LEQUAL);
		glClearColor(m_backColor[0], m_backColor[1], m_backColor[2], 1.0f);
		glDrawBuffer(GL_BACK);

		//glEnable(GL_ALPHA_TEST);
		//glAlphaFunc(GL_GREATER, 0.9);//0.5可以换成任何在0~1之间的数 

		//m_backTexture.LoadFromFile("OglWnd\\blue_back.jpg");
		//m_backTexture.Init2DTex();

		m_trackball.setBallSpeed(10.0);
		m_mesh.InitData();
		m_mesh.DrawMouseStroke(true);
		//m_mesh.LoadOBJModel("MeshData\\bunny_480k.obj");
		//m_mesh.LoadModel("MeshData\\plane.obj");
		m_mesh.LoadMModel("MeshData\\bunny_80k.m");
		//m_mesh.LoadMModel("MeshData\\bunny_5k.m");
	}

	void COglWnd::InitColor()
	{
		//m_backColor[0] = 0.15f;
		//m_backColor[1] = 0.20f;
		//m_backColor[2] = 0.267f;
		m_backColor[0] = m_backColor[1] = m_backColor[2] = 0.0;
	}

	void COglWnd::InitLight()
	{
		v4f lightOnePos(V4F(0.0f, 0.0f, 20.0f, 0.0f));

		m_gloabalAmbientLight[0] = m_gloabalAmbientLight[1] = m_gloabalAmbientLight[2]
			= m_gloabalAmbientLight[3] = 0.2f;
		m_diffuseLight[0] = m_diffuseLight[1] = m_diffuseLight[2] = m_diffuseLight[3] = 1.0;
		m_diffuseLight[3] = 1.0;
		m_specularLight[0] = m_specularLight[1] = m_specularLight[2] = m_specularLight[3] = 1.0;
		m_specularLight[3] = 1.0;
		m_ambientLight[0] = m_ambientLight[1] = m_ambientLight[2] = m_ambientLight[3] = 0.2;
		m_emissionLight[0] = m_emissionLight[1] = m_emissionLight[2] = m_emissionLight[3] = 0.1;

		glEnable(GL_LIGHT0);
		glEnable(GL_LIGHTING);

		glLightModeli(GL_LIGHT_MODEL_COLOR_CONTROL, GL_SEPARATE_SPECULAR_COLOR);//纹理映射之后再应用镜面光高亮的效果
		glLightModelfv(GL_LIGHT_MODEL_AMBIENT, (float*)m_gloabalAmbientLight);

		glLightfv(GL_LIGHT0, GL_POSITION, (float*)lightOnePos);
		glLightfv(GL_LIGHT0, GL_DIFFUSE, (float*)m_diffuseLight);
		glLightfv(GL_LIGHT0, GL_SPECULAR, (float*)m_specularLight);
	}

	void COglWnd::RenderBackGround()
	{
		glPushAttrib(GL_ALL_ATTRIB_BITS);
		glDisable(GL_DEPTH_TEST);

		glEnable(GL_TEXTURE_2D);
		m_backTexture.Bind2d();

		glMatrixMode(GL_PROJECTION);
		glPushMatrix();
		glLoadIdentity();
		gluOrtho2D(0.0, 1.0, 0.0, 1.0);

		glMatrixMode(GL_MODELVIEW);
		glPushMatrix();
		glLoadIdentity();
		glBegin(GL_QUADS);
		glTexCoord2f(0.0, 1.0);
		glVertex2f(0.0, 0.0);
		glTexCoord2f(1.0, 1.0);
		glVertex2f(1.0, 0.0);
		glTexCoord2f(1.0, 0.0);
		glVertex2f(1.0, 1.0);
		glTexCoord2f(0.0, 0.0);
		glVertex2f(0.0, 1.0);
		glEnd();
		glPopMatrix();

		glMatrixMode(GL_PROJECTION);
		glPopMatrix();

		glPopAttrib();
	}

	void COglWnd::RenderScene()
	{
		if (m_hGLRC != wglGetCurrentContext())
		{
			wglMakeCurrent(m_hDC, m_hGLRC);
		}
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT); // Clear Screen And Depth Buffer

		//RenderBackGround();
		glMatrixMode(GL_MODELVIEW);
		glPushMatrix();
		glMultMatrixf((float*)(m_trackball.matrix().transpose()));

		m_mesh.DrawScene();

		glPopMatrix();
		SwapBuffers(m_hDC);
	}

	void COglWnd::ReleaseScene()
	{
		m_mesh.DestroyData();
		DetachGLContext();
	}

	BEGIN_MESSAGE_MAP(COglWnd, CWnd)
		ON_WM_DESTROY()
		ON_WM_PAINT()
		ON_WM_CREATE()
		ON_WM_SIZE()
		ON_WM_ERASEBKGND()
		ON_WM_LBUTTONDOWN()
		ON_WM_LBUTTONUP()
		ON_WM_MBUTTONDOWN()
		ON_WM_MBUTTONUP()
		ON_WM_RBUTTONDOWN()
		ON_WM_RBUTTONUP()
		ON_WM_MOUSEMOVE()
		ON_WM_MOUSEWHEEL()
		ON_WM_SETCURSOR()
		ON_WM_MBUTTONDOWN()
		ON_WM_MBUTTONUP()
		ON_WM_RBUTTONDOWN()
		ON_WM_RBUTTONUP()
	END_MESSAGE_MAP()

	//以下是消息处理函数
	int COglWnd::OnCreate(LPCREATESTRUCT lpCreateStruct)
	{
		if (CWnd::OnCreate(lpCreateStruct) == -1)
			return -1;

		if (!SetupGLContext())
		{
			AfxMessageBox("初始化OpenGL窗口设置失败!");
			return -1;
		}

		InitialScene();

		m_bGLSetup = TRUE;

		return 0;
	}

	// COglWnd 消息处理程序

	void COglWnd::OnSize(UINT nType, int cx, int cy)
	{
		CWnd::OnSize(nType, cx, cy);

		// TODO: 在此处添加消息处理程序代码
		m_nWinWidth = cx;
		m_nWinHeight = cy;
		m_mesh.WindowWidth(m_nWinWidth);
		m_mesh.WindowHeight(m_nWinHeight);
		m_trackball.init(cx, cy);

		if (m_bGLSetup)
		{
			wglMakeCurrent(m_hDC, m_hGLRC);
			ResizeGLViewport(cx, cy);
		}
	}

	BOOL COglWnd::OnEraseBkgnd(CDC* pDC)
	{
		// TODO:  在此添加消息处理程序代码和/或调用默认值
		return TRUE;
		//return CWnd::OnEraseBkgnd(pDC);
	}

	void COglWnd::OnDestroy()
	{
		CWnd::OnDestroy();

		ReleaseScene();
	}

	void COglWnd::OnPaint()
	{
		CPaintDC dc(this); // device context for painting

		if (m_bGLSetup)
		{
			RenderScene();
		}
	}

	BOOL COglWnd::OnSetCursor(CWnd* pWnd, UINT nHitTest, UINT message)
	{
		if (m_cursorType == CURSOR_HAND)
		{
			SetCursor(LoadCursor(AfxGetApp()->m_hInstance, MAKEINTRESOURCE(IDC_CURSOR_HAND)));
		}
		else if (m_cursorType == CURSOR_PEN)
		{
			SetCursor(LoadCursor(AfxGetApp()->m_hInstance, MAKEINTRESOURCE(IDC_CURSOR_PEN)));
		}

		return TRUE;
		//return CWnd::OnSetCursor(pWnd, nHitTest, message);
	}

	void COglWnd::OnLButtonDown(UINT nFlags, CPoint point)
	{
		m_mouseState = MOUSE_LEFTBUTTON_DOWN;
		if (m_cursorType == CURSOR_HAND)//如果是浏览模式
		{
			m_trackball.buttonPressed(Trackball::LEFT_BUTTON, point.x, point.y);
			m_mesh.DrawMouseStroke(false);
		}
		else if (m_cursorType == CURSOR_PEN)//如果是绘制模式
		{
			m_mesh.DrawMouseStroke(true);
			m_mesh.ClearMouseStroke();//清除原鼠标点集合
			//添加新鼠标点
			m_mesh.AddMousePoint(V2F(point.x, m_nWinHeight - point.y - 1));
		}

		CWnd::OnLButtonDown(nFlags, point);
	}

	void COglWnd::OnLButtonUp(UINT nFlags, CPoint point)
	{
		m_mouseState = MOUSE_LEFTBUTTON_UP;
		if (m_cursorType == CURSOR_HAND)
		{
			m_trackball.buttonReleased(Trackball::LEFT_BUTTON);
		}
		else if (m_cursorType == CURSOR_PEN)
		{
			//添加新鼠标点
			m_mesh.AddMousePoint(V2F(point.x, m_nWinHeight - point.y - 1));
			m_mesh.DrawStroke();//绘制笔画
		}
		RenderScene();

		CWnd::OnLButtonUp(nFlags, point);
	}

	void COglWnd::OnMButtonDown(UINT nFlags, CPoint point)
	{
		m_mouseState = MOUSE_MIDDLEBUTTON_DOWN;
		if (m_cursorType == CURSOR_HAND)
		{
			m_mesh.DrawMouseStroke(false);
			m_trackball.buttonPressed(Trackball::MIDDLE_BUTTON, point.x, point.y);
		}

		CWnd::OnMButtonDown(nFlags, point);
	}

	void COglWnd::OnMButtonUp(UINT nFlags, CPoint point)
	{
		m_mouseState = MOUSE_MIDDLEBUTTON_UP;
		if (m_cursorType == CURSOR_HAND)
		{
			m_trackball.buttonReleased(Trackball::MIDDLE_BUTTON);
		}

		CWnd::OnMButtonUp(nFlags, point);
	}

	void COglWnd::OnRButtonDown(UINT nFlags, CPoint point)
	{
		m_mouseState = MOUSE_RIGHTBUTTON_DOWN;
		if (m_cursorType == CURSOR_HAND)
		{
			m_mesh.DrawMouseStroke(false);
			m_trackball.buttonPressed(Trackball::RIGHT_BUTTON, point.x, point.y);
		}

		CWnd::OnRButtonDown(nFlags, point);
	}

	void COglWnd::OnRButtonUp(UINT nFlags, CPoint point)
	{
		m_mouseState = MOUSE_RIGHTBUTTON_UP;
		if (m_cursorType == CURSOR_HAND)
		{
			m_trackball.buttonReleased(Trackball::RIGHT_BUTTON);
		}

		CWnd::OnRButtonUp(nFlags, point);
	}

	void COglWnd::OnMouseMove(UINT nFlags, CPoint point)
	{
		SetFocus();

		if (m_cursorType == CURSOR_HAND)
		{
			if (m_mouseState == MOUSE_LEFTBUTTON_DOWN
				|| m_mouseState == MOUSE_MIDDLEBUTTON_DOWN
				|| m_mouseState == MOUSE_RIGHTBUTTON_DOWN)
			{
				m_trackball.update(point.x, point.y);
				RenderScene();
			}
		}
		else if (m_cursorType == CURSOR_PEN)
		{
			if (m_mouseState == MOUSE_LEFTBUTTON_DOWN)
			{
				//添加新鼠标点
				m_mesh.AddMousePoint(V2F(point.x, m_nWinHeight - point.y - 1));
				RenderScene();//更新显示
			}
		}

		CWnd::OnMouseMove(nFlags, point);
	}

	//中键滚动放缩模型
	BOOL COglWnd::OnMouseWheel(UINT nFlags, short zDelta, CPoint pt)
	{
		if (m_cursorType == CURSOR_HAND  m_mesh.HasModelLoad())
		{
			float z = m_eye[2];
			z += zDelta / 1000.f;
			z = z < m_fGLDepthMin ? m_fGLDepthMin : z;
			SetEye(m_eye, m_dest, m_up);

			RenderScene();
		}

		return CWnd::OnMouseWheel(nFlags, zDelta, pt);
	}
};

```

效果如下图所示的中间渲染窗口：
![](https://c7.staticflickr.com/8/7755/27174995310_3c6b96eba2_o.jpg)