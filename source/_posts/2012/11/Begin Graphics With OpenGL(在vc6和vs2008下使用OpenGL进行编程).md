---
title: Begin Graphics With OpenGL(在vc6和vs2008下使用OpenGL进行编程)
tags:
  - OpenGL
  - VC6
  - VS2008
  - 图形学
id: 318
categories:
  - 图形图像
  - 图形学
  - OpenGL
date: 2012-11-04 23:12:00
---

首先，我们需要安装好VC6或者VS2008，然后获取OpenGL的开发包。剩下的一件麻烦事情就是配置了。

如果你找不到合适的开发包，可以从我这里下载，里面开发包和查询手册，可是我辛苦收集好的哦。地址：[OpenGL SDK](https://pan.baidu.com/s/1bpp181T)

在你下载好的开发包里面，会出现三个目录，分别是include和lib,system32。include里面当然是OpenGL的头文件了，那么lib则是动态链接时候的导入库了，system32里面是几个dll，dll你知道该放在哪里吧，放在你的程序同一个目录下，或者干脆放在系统目录下，即c盘下面的system32目录。开发包里面有个txt文件简要说明了如何设置include和lib，下面我要用图示详细说明vc6和vs2008下的设置方法。

**vc6下的设置**，
step1:
Tools->Options->directories
![](https://c2.staticflickr.com/8/7197/26820703294_b85f12cc03_o.png)

step2:
在Show Directories For选型卡里面选择include files
然后,在下面的directories里面添加一个新项，然后选择opengl的include目录，再用右上角的箭头上移到最上面。

step3:
在Show Directories For选型卡里面选择Library files
然后,在下面的directories里面添加一个新项，然后选择opengl的lib目录，再用右上角的箭头上移到最上面。

step4:
把opengl开发包里面的system32文件下面的dll全部拷贝的C:\WINDOWS\system32下面，当然不同的系统这个目录不同，
不过这都是系统目录。

现在你就可以用vc6下使用opengl学习图形学了。。。

**vs2008下的设置**,
step1:
工具->选项，打开如图所示的对话框，![](https://c2.staticflickr.com/8/7197/26820701964_e3f17c8253_o.png)
点开左边的项目和解决方案，选择里面的vc++目录。

step2:
类似vc6下面的设置，在右边的显示一下内容的目录选项卡中选择包含文件，再在下面的列表框里面添加一个新的目录作为新的include目录。目录的路径设置同vc6，就是开发包的include文件夹。

step3:
类似vc6下面的设置，在右边的显示一下内容的目录选项卡中选择库文件，再在下面的列表框里面添加一个新的目录作为新的lib目录。目录的路径设置同vc6，就是开发包的lib文件夹。

step4:
同样是拷贝dll到系统目录下。

至此基本解决了，无论是哪种外部库的设置都是如果搞一下就ok了，无论是哪个版本的vs，基本上设置的地方差别不大。