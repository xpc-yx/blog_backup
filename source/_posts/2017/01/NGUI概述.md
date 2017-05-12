---
title: NGUI概述
tags:
  - NGUI
  - 教程
id: 2163
categories:
  - 游戏开发
  - - Unity3d
  - - - NGUI
date: 2017-01-12 17:15:51
toc: true
---

# NGUI介绍

NGUI是Unity中最流行的UI插件，在UGUI出现前几乎是Unity唯一的UI解决方案。
NGUI是一个提供高效事件通知框架的强大UI系统。NGUI遵循[Kiss准则](https://en.wikipedia.org/wiki/KISS_principle)，其中类代码简洁，多数在200行以内。程序员可以方便的扩展其组件类代码以获得定制的功能。
[NGUI官方网址](http://www.tasharen.com/?page_id=140)
[NGUI官方文档地址](http://www.tasharen.com/forum/index.php?board=12.0)

# NGUI下载

我们可以从unity商店购买NGUI，或者下载其免费版本。
[NGUI的Unity商店](https://www.assetstore.unity3d.com/cn/#!/content/2413)
当然也可以下载网上其它人提供的版本学习研究。
[NGUI 3.10.2](http://www.ceeger.com/forum/read.php?tid=20718fid=16)

# NGUI导入

下载NGUI后，我们得到的是一个.unitypackage文件，比如NGUI Next-Gen UI v3.6.8.unitypackage。
Unity编辑器中，打开菜单Assets->ImportPackage->CustomPackage，然后选择下载的.unitypackage文件导入编辑器。导入NGUI后，在工程的Assets目录下会出现一个NGUI文件夹，并且Unity编辑器中会多了一个NGUI主菜单。

# NGUI例子

打开NGUI->Options->Reset Prefab ToolBar，会出现如下工具条：

![NGUI例子](https://c1.staticflickr.com/1/782/31420422424_657c6cee61_o.png)
这里面有基本的NGUI控件例子，是我们学习参照的好材料。

# NGUI类图

下面是我整理的NGUI类图：
![NGUI类图](https://c1.staticflickr.com/1/363/32223724406_7e07b90f4b_o.png)

该类图中列出了NGUI中绝大部分的类。
类图中有两个最重要的分支，UIWidgetContainer分支和UIWidget分支。
NGUI中的大部分控件都继承自UIWidgetContainer，这说明在NGUI中，其实是把控件当作Sprite的容器而已。UIWidget的子类就是Sprite和Texture，表示NGUI中的控件都是图片化的，控件的表现都依赖图片。

# NGUI常用组件

## UILabel 文本

## UIInput 输入框

## UITextList 多文本显示框，类似聊天窗

## UISprite 图片精灵

## UIBotton 按钮

## UIToggle 单选框/复选框

## UIScrollBar 滚动条

## UISlider 滑动条/进度条

## UIProgressBar 进度条

## UIPopupList 下拉框

## UIGrid 将子控件按照单元格布局

## UITable UIGrid加强版，类似Html的table

## UIPanel 控件渲染器，管理和绘制其下所有的组件

## UIScrollView 滚动视窗

## UIKeyBinding 给控件的点击或者选中事情绑定按键

## UIRoot NGUI的UI根物体

# 参考资料：

[NGUI官网](http://www.tasharen.com/forum/index.php?topic=6754)