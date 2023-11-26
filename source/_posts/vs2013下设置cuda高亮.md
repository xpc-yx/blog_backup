---
title: vs2013下设置cuda高亮
tags:
  - CUDA
id: 1368
categories:
  - 图像处理
  - CUDA
date: 2014-11-03 17:12:40
---

因为是最近才接触cuda，安装的是6.5版本，所以网上的教程都不是完全适用了。
总之，设置高亮大致分为四步，不限于vs2013，其他平台下也类似。
第一步，是在vs2013里面设置vc++文件支持.cu;cuh;文件。方法：工具->选项->文本编辑器->文件扩展名。
得到如图所示的界面：注意，在右侧可以添加vc++类型的文件扩展名，这是我的设置效果，操作就不用细说了。
![](https://c2.staticflickr.com/8/7108/27175378080_ea4f90c9db_o.png)
第二步，是设置visual assist的目录。在va的C++directory里面，选择custom选项，然后包含你的cuda的sdk目录，效果如图：
![](https://c2.staticflickr.com/8/7376/27175377940_b07f4d0af3_o.png)
第三步，是设置va的支持文件类型，类似于第一步。但是，这次是修改注册表的值。注册表目录：
HKEY_CURRENT_USER/Software/Whole Tomato/Visual Assist X/VANet12，修改属性ExtSource的值为：.c;.cpp;.cc;.cxx;.tli;.cu;.cuh;
意思就是添加上cuda的头文件和源文件类型，vs2010的改法类似。
第四步，完成以上步骤之后，还可能会发现一些内置变量下面是有波浪线的。怎么办了？
加上这句：#include "device_launch_parameters.h"，就行了。cuda 6.5估计把内置变量的声明放在该头文件下面了吧。
最终的效果：
![](https://c2.staticflickr.com/8/7543/26844573893_3f74990273_o.png)