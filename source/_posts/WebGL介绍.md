---
title: WebGL介绍
tags:
  - Canvas
  - HTML5
  - JavaScript
  - WebGL
id: 2050
categories:
  - 图形图像
  - 图形学
  - OpenGL
  - WebGL
date: 2016-07-09 22:22:43
---

# WebGL概述

什么是WebGL？WebGL简单的说就是在Web中渲染OpenGL的技术，也可以理解为把OpenGL的接口移植到浏览器中使用。具体的可以参考[WebGL的维基百科](https://zh.wikipedia.org/wiki/WebGL)。
使用WebGL可以通过编写网页代码在浏览器中渲染三维图像，而且不需要任何的插件，比如Adobe Flash Player等。
WebGL在最新的浏览器中得到了广泛支持。

# WebGL与HTML5的关系

[HTML5](https://zh.wikipedia.org/zh-cn/HTML5)是最新的HTML（超文本标记语言）的最新修订版本。
HTML5中新增了`<canvas>`标签用于绘图。在HTML5之前，只能使用`<img>`标签在网页中显示静态图片，如果要显示动画得借助于Adobe Flash Player等第三方插件。在HTML5中，可以在`<canvas>`标签上绘制二维图像，也可以使用WebGL绘制三维图像。
WebGL相对于HTML5的关系就好比是OpenGL库和三维应用程序的关系。WebGL只是提供了底层的渲染和计算的函数。

# WebGL与JavaScript的关系

[JavaScript](https://zh.wikipedia.org/wiki/JavaScript)是一种浏览器中运行的动态脚本语言。WebGL也需要依靠JavaScript来操作浏览器中的对象。JavaScript与WebGL的关系类似于C或者C++和OpenGL的关系。

# WebGL与OpenGL的关系

WebGL基于OpenGL ES 2.0，WebGL实现了OpenGL ES 2.0的一个子集。WebGL使用Javascript进行内存管理，使用GLSL ES作为着色器语言。具体的关系可以参考下图：
![WebGL与OpenGL](https://c2.staticflickr.com/8/7581/28115784971_1e25355d87_o.png)

# WebGL程序的结构

默认情况下，网页程序包括HTML和Javascript脚本语言两部分。但是WebGL程序，还有特殊的GLSL ES着色器语言部分。
具体结构如下图所示：
![WebGL程序的结构](https://c1.staticflickr.com/9/8738/27578325223_d5b354ecce_o.png)

# 总结

本文介绍WebGL的基本概念，以及WebGL和HTML、JavaScript、OpenGL之间的关系等。接下来的文章会介绍具体的WebGL编程知识。

# 参考

&#91;1] WebGL编程指南
&#91;2] 维基百科