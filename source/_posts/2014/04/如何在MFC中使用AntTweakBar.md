---
title: 如何在MFC中使用AntTweakBar
tags:
  - AntTweakBar
  - MFC
  - OpenGL
id: 1131
categories:
  - MFC
  - OpenGL
  - 图形学
date: 2014-04-27 13:05:04
---

这篇文章是在我的另一篇文章“[继承mfc的cwnd类渲染opengl](http://www.xpc-yx.com/2014/02/15/%E7%BB%A7%E6%89%BFmfc%E7%9A%84cwnd%E7%B1%BB%E6%B8%B2%E6%9F%93opengl/)”的基础上改进的。
AntTweakBar是一个条状的菜单库，类似于内嵌于渲染窗口的属性条，可以和OpenGL渲染窗口融为一体，效果很好看。以前见过有人用这个库，效果比较好看就关注了下。在网上找相关的资料，发现只有人在glut下使用。还有人因为在MFC下使用不成功，认为和MFC不兼容。其实，这个库只要给了渲染引擎就行了，然后把一些事情传给它就能交互了。
AntTweakBar提供的都是简单的C接口，所以非常方便和已有的界面框架整合，无论你用的是OpenGL还是DX渲染，无论你用的界面框架是glut还是glfw或者sdl等等都行。官方网站也提供了[整合步骤](http://anttweakbar.sourceforge.net/doc/tools:anttweakbar:howto)。
我现在介绍下，在我的框架里面的整合步骤。
第一步，在OnCreate函数里面调用TwInit(TW_OPENGL, NULL);初始化。
第二步，在OnCreate函数里面创建bar并且绑定变量。如，

``` stylusTwBar 
	*myBar;
	myBar = TwNewBar("Test");
	TwDefine(" Test refresh=0.5 color='96 216 224' alpha=0 text=dark");
	static int nTest = 0;
	TwAddVarRW(myBar, "Test", TW_TYPE_INT32, nTest, "test");
```

第三步，在OnSize里面调用TwWindowSize(cx, cy);
第四步，修改PreTranslateMessage实现为，

``` stylus
if (TwEventWin(pMsg->hwnd, pMsg->message, pMsg->wParam, pMsg->lParam))
{
	return 1;
}
return CWnd::PreTranslateMessage(pMsg);
```

第五步，在RenderScene函数最后添加TwDraw()，但是得保证在SwapBuffers(m_hDC)之前添加这句。
第六步，在OnDestroy()中调用TwTerminate()释放资源。
综上所述，整合还是非常简单的。
另外，AntTweakBar提供TwDefine函数用于设置颜色，透明度等参数，可以调整效果，非常方便。还有一个需要注意的是，TwAddVarRW绑定的变量不能是局部变量，否则会出错。当你绑定的变量值变化时候，就是你和AntTweakBar交互的时候了。总之，非常方便使用吧。
最后，我要说的是，AntTweakBar自己会使用自身的光标，它的光标会覆盖MFC窗口的光标。如果，我们坚持使用MFC的光标的话，该怎么办了。只能禁止掉AntTweakBar的光标了。方法是，修改它的源码，重新编译成库。我们把TwMgr.cpp的针对windows系统的**SetCursor**函数内部实现注视掉就行了。如下所示：

``` stylus
void CTwMgr::SetCursor(CTwMgr::CCursor _Cursor)
{
	/*if( m_CursorsCreated )
	{
	CURSORINFO ci;
	memset(ci, 0, sizeof(ci));
	ci.cbSize = sizeof(ci);
	BOOL ok = ::GetCursorInfo(ci);
	if( ok  (ci.flags  CURSOR_SHOWING) )
	::SetCursor(_Cursor);
	}*/
}
```

以下是实现效果，

![](https://c4.staticflickr.com/8/7482/27380004971_4d45801816_o.jpg)