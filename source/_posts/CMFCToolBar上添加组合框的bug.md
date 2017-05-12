---
title: CMFCToolBar上添加组合框的bug
tags:
  - CBS_DROPDOWN
  - CBS_DROPDOWNLIST
  - CMFCToolBar
  - CMFCToolBarComboBoxButton
id: 1030
categories:
  - UI框架
  - MFC
date: 2013-12-21 20:04:29
---

说实话，这几天为了CMFCToolBarComboBoxButton上的莫名其妙自动切换选择的bug烦死了，浪费了很多时间。也是过其它替代方法，发现都实现不了需要的界面效果。
我也不知道为什么自己对界面效果这么纠结。伤不起啊。本来我就没用过vs2008更新版本的MFC，也没打算用这个。由于上一次做的东西用到了切分视图，但是发现FormView自适应控件大小的实现非常麻烦，老是出现些不爽的bug，而且添加新的控件还得编辑界面，非常不爽。所以，打算使用新版本MFC里面的属性窗口。
刚好发现vs2010的项目导航可以生成这样的工程，果断试验之。虽然过程无比艰辛，总算可以使用这些自适应的DockPane窗口了。而且还发现这样的结构非常合适添加子窗口，以后的项目都可以采用这样的界面了，只要平台在windows下。
但是，美中最不足的是CFrameWndEx(使用CDockablePane必须使用扩展的框架窗口)，**只能使用恶心的CMFCToolBar**，因为CFrameWndEx的菜单和工具栏都是可以DockPane的子类。我只能说CMFCToolBar的使用太TMD的讲究了，一个不注意效果就不对。因为使用这个东西的人少，网上资料也很少。只能一直google，还有查看类定义的源码，慢慢尝试了。
现在，我这里说的只是添加组合框。
首先，在资源编辑器中新建工具栏IDR_BUILD，留下一个**空位**，如ID_BUILD_CHOOSE。如下图，第二个就是我预留的ID_BUILD_CHOOSE的空位。![](https://c8.staticflickr.com/8/7637/27379836511_65ae3047e4_o.jpg)
然后，在CMainFrame::OnCreate中创建两个工具栏，代码如下：

``` stylus
    if (!m_wndToolBar.CreateEx(this, TBSTYLE_FLAT, WS_CHILD | WS_VISIBLE | CBRS_TOP | CBRS_GRIPPER
	| CBRS_TOOLTIPS | CBRS_FLYBY | CBRS_SIZE_DYNAMIC)
		|| !m_wndToolBar.LoadToolBar(IDR_MAINFRAME))
	{
		TRACE0("未能创建工具栏\n");
		return -1;      // 未能创建
	}

	if (!m_wndToolBarBuild.Create(this, WS_CHILD | WS_VISIBLE | CBRS_TOP | CBRS_TOOLTIPS | CBRS_FLYBY
		| CBRS_HIDE_INPLACE | CBRS_SIZE_DYNAMIC| CBRS_GRIPPER | CBRS_BORDER_3D, IDC_MFCTOOLBAR_BUILD)
		|| !m_wndToolBarBuild.LoadToolBar(IDR_BUILD))
	{
		TRACE0("未能创建build工具栏\n");
		return -1;      // 未能创建
	}

	if (!m_wndStatusBar.Create(this))
	{
		TRACE0("未能创建状态栏\n");
		return -1;      // 未能创建
	}
	m_wndStatusBar.SetIndicators(indicators, sizeof(indicators)/sizeof(UINT));

	m_wndMenuBar.EnableDocking(CBRS_ALIGN_ANY);
	m_wndToolBar.EnableDocking(CBRS_ALIGN_ANY);
	m_wndToolBarBuild.EnableDocking(CBRS_ALIGN_ANY);

	EnableDocking(CBRS_ALIGN_ANY);
	DockPane(m_wndMenuBar);
	DockPane(m_wndToolBarBuild);
	DockPaneLeftOf(m_wndToolBar, m_wndToolBarBuild);
```
注意，创建第二个工具栏的时候需要使用**Create**而不是CreateEx，如果使用CreateEx就不能使用后面的ID参数。
现在需要实现三个消息。

``` stylus
ON_REGISTERED_MESSAGE(AFX_WM_RESETTOOLBAR, CMainFrame::OnToolbarReset)
ON_COMMAND(ID_BUILD_CHOOSE, CMainFrame::OnClickChoose)
ON_CBN_SELCHANGE(ID_BUILD_CHOOSE, CMainFrame::OnSelChangeClick)
```
代码如下：

``` stylus
LRESULT CMainFrame::OnToolbarReset(WPARAM wParam, LPARAM lParam)
{
	UINT uiToolBarId = (UINT)wParam;

	switch (uiToolBarId)
	{
	case IDR_MAINFRAME:
		break;

	case IDR_BUILD:
		{
		   CMFCToolBarComboBoxButton comboButton(ID_BUILD_CHOOSE, GetCmdMgr()->GetCmdImage(ID_BUILD_CHOOSE, FALSE), CBS_DROPDOWN);
		   comboButton.EnableWindow(TRUE);
		   comboButton.SetCenterVert();
		   comboButton.SetFlatMode();
		   comboButton.AddItem(_T("Example Stack"));
		   comboButton.AddItem(_T("Upsample Pyramid"));
		   comboButton.AddItem(_T("Jitter Pyramid"));
		   comboButton.AddItem(_T("Correct Pyramid"));
		   comboButton.SelectItem(0);
		   m_wndToolBarBuild.ReplaceButton(ID_BUILD_CHOOSE, comboButton);
		}
		break;

	default:
		break;
	}

	return 0;
}

void CMainFrame::OnClickChoose()
{

}

void CMainFrame::OnSelChangeClick()
{
	CMFCToolBarComboBoxButton* pCombo = CMFCToolBarComboBoxButton::GetByCmd(ID_BUILD_CHOOSE, TRUE);

	int nIndex = pCombo->GetCurSel();
	theAppState.ts.m_nDisplayMode = nIndex;
	theAppState.ts.UpdateDisplayWnd();
}
```

OnToolbarReset中实现的是添加组合框，根据MSDN的文档，应该采用这样的方法，当然也可以采用CMFCToolBar的protected方法InsertButton，不过需要把这个方法改成public的，这个就需要修改类定义的源码。必须响应ID_BUILD_CHOOSE的点击消息，否则组合框是灰的，无法点击。
OnSelChangeClick响应的是组合框选择变化的消息，这个消息的实现必须用 CMFCToolBarComboBoxButton::GetByCmd获得组合框的指针，否则得不到正确的效果。
最后要讲的是我碰到的一个bug，恶心了我一周了。我在工具栏上面定义了向前和向后操作，如果我一直点击向前或者向后按钮，**组合框会自动切换选择到最后一项**。我调试了很久，发现跟我的算法实现代码一点关系都没有，我什么都不做，操作界面就会出现这个bug。最后，我偶然发现修改CMFCToolBarComboBoxButton comboButton(ID_BUILD_CHOOSE, GetCmdMgr()->GetCmdImage(ID_BUILD_CHOOSE, FALSE), **CBS_DROPDOWNLIST**);的最后一个参数为**CBS_DROPDOWN**就不会出现这样的bug。只是有一个不爽的地方，那就是点击组合框的时候，会出现光标而已。勉强接受了吧。