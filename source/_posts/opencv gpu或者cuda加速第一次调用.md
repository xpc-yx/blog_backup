---
title: opencv gpu或者cuda加速第一次调用
tags:
  - CUDA
id: 1395
categories:
  - 图像处理
  - CUDA
date: 2014-11-11 15:29:48
---

经测试，第一次gpu调用，无论是用opencv的gpu模块或者cuda都会比较耗时，可能将近1s。
额，这也不是我一个人碰到的问题，确实有这回事。stackoverflow上面有个帖子就是关于这个的。
帖子地址：[关于速度慢](http://stackoverflow.com/questions/12074281/why-opencv-gpu-codes-is-slower-than-cpu)，[关于解决办法](https://stackoverflow.com/questions/10415204/how-to-create-a-cuda-context)。
如果，看了上面的帖子话，这篇文章也不用看下去了。因为我要讲的就是这件事情。
我的观点也是，在第一次调用之前先建立cuda context。为什么需要做这样的事情了？额，假如，
你只调用一次gpu处理，总不能太慢了吧。那样就看不到速度了，所以先调用次垃圾操作初始化cuda环境。
方法是调用cudaFree(0)，在这之前最好调用先调用cudaSetDevice(0)。记住包含cuda的头文件，
如果只有opencv的头文件，这2个函数是找不到的。还有，建立的工程是cuda runtime模版。
在我的L0Smooth代码里，这样的处理之后，初次L0Smooth调用能减少1s左右，从3s变成了2s。
其余的耗时，基本都在gpu版本的dft和idft，还得继续寻找加快速度的办法。