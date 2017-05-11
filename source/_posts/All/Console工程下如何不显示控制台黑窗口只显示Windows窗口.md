---
title: Console工程下如何不显示控制台黑窗口只显示Windows窗口
tags:
  - OpenGL
  - VC6
  - VS2008
  - 控制台
  - 程序入口
id: 341
categories:
  - UI框架
  - MFC
date: 2012-11-06 19:53:00
---

本文是以OpenGL的代码为例子的。计算机图形学OpenGL版上面的例子都是控制台模式的，如果不进行设置，运行的时候会先出现黑窗口再出现Windows窗口。

其实要去除控制台窗口非常简单，只需要修改工程设置，把子系统改成Windows，程序的入口点改成mainCRTStartup。

下面我先把几中解决办法列举出来，再解释下我的理解。

方法一：在程序中加入一句#pragma comment(linker, "/subsystem:\"windows\" /entry:\"mainCRTStartup\"")，建议加在include的后面。

方法二：修改工程设置。

对于vc6，地方在Project->setting->Link->Project Options。

点开后的界面如图，
![](https://c2.staticflickr.com/8/7311/26822691403_8a9e32a9b9_o.png)

在右下角的Project Options里面找到/subsytem:,并把其后面其后面的参数改成为windows,然后再找到/entry:，把其后面的值改成"mainCRTStartup"，如果找不到就添加，最后的效果是/subsystem:windows /entry:"mainCRTStartup"。

对于vs2008，地方在项目->属性->链接器，

然后在左边选中高级，如图所示，
![](https://c2.staticflickr.com/8/7339/26822691883_876f4aac50_o.png)

在最上面的入口点输入mainCRTStartup，再选中系统，如图所示，

![](https://c2.staticflickr.com/8/7323/26822692733_cb9da04a2a_o.png)

在最上面的子系统选择Windows即可了。

为什么这样设置下就可以了了。**主要是因为Windows系统下有几种子系统，一种是控制台，一种是窗口子系统**，如果建立了控制台工程肯定是要创建控制台子系统程序了，建立了Windows Application和MFC之类的工程则是窗口子系统了。**不同的子系统会链接不同的主函数**，控制台的会链接main,窗口的会链接WinMain，如果不匹配肯定会链接失败。

现在我们使用OpenGL编程，又建立的是控制台工程，如果不进行设置肯定会出现黑窗口的，所以我们把工程的子系统改成Windows，但是我们不想改主函数为WinMain了，因为这样会很麻烦，所以我们再把程序入口改成mainCRTStartup。同样如果是win32 App工程下，我们可以把子系统改成控制台，再设置程序入口为WinMainCRTStartup，应该就会得到相反的效果了。