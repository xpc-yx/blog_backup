---
title: vs2013下配置cuda6.5和opencv2.4.10的gpu版本
tags:
  - CUDA
id: 1401
categories:
  - 图像处理
  - CUDA
date: 2014-11-13 16:57:44
---

首先，当然是安装好vs2013。第二步是配置最新的cuda6.5版本，这个有相关的教程。
这里要讲的是如何生成相应的opencv的gpu版本。
首先，当然是去opencv官方网站下载opencv，然后解压到指定的目录，最好不要出现
中文路径，因为后面需要用到cmake。2.4.10的[下载地址](http://sourceforge.net/projects/opencvlibrary/files/latest/download?source=files)，已经不好找了。最新的是3.0beta版本，
由于模块分类完全变了，所以还是别去吃螃蟹了。
下载好解压之后，会出现两个子目录，build和source。如果，你只使用cpu版本，那么build
里面的内容就满足你的要求了。否则，打开source目录，你会发现有一个CMakeLists.txt文件。
那么，肯定是需要使用cmake生成相应的工程了。
第二步，下载cmake，安装好cmake。
第三步，用cmake生成工程。操作方法：假如opencv在f盘根目录下面，那么设置好cmake的
source目录和build目录。然后点击configure按钮，选择对应的平台如visual studio 12。注意，现在
记得选择WITH_CUDA，WITH_CUFFT，WITH_CUBLAS等相关的选项。
然后，点击generate按钮就能生成对应的工程。如果，出现配置错误，可以根据cmake的
提示寻找原因。基本上是些环境变量的设置问题，或者是平台不匹配等。
如图所示：

![](https://c2.staticflickr.com/8/7282/27175321180_663e09d18f_o.png)
注意build目录不用和source目录设置为同一个，否则可能引起问题，cmake也会出警告。
第四步，就是打开工程生成文件了。用vs2013或者你的使用版本，打开build目录下的OpenCV.sln
文件。最简单的办法，就是批生成->全选->重新生成。
关键的问题出现，如果你只是这样做，可能有几个dll无法编译出来，比如说opencv_gpu2410.dll。
问题在哪里了。我试验了好几次，每次几个小时，都是这样的结果。顿时觉得很郁闷，
只能去分析vs的输出内容了。突然发现有个错误提示：大致内容是NCV.cu文件中的std::max没有
定义。这个cu文件在..\opencv\sources\modules\gpu\src\nvidia\core下面。
你最后需要做的就是打开这个文件，然后包含algorithm头文件就行了，然后再重新编译吧。
PS：我只生成过32平台下的gpu版本了，64位的就没有去尝试了。