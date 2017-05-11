---
title: OpenGL立即模式必须先指定纹理坐标
tags:
  - OpenGL
  - 立即模式
  - 纹理坐标
id: 1338
categories:
  - 图形图像
  - 图形学
  - OpenGL
date: 2014-10-27 15:49:05
---

说实话，立即模式用了一年多了，还是犯了这个错误。因为很多代码例子里面都是先指定法线，再指定位置，结果添加纹理坐标的时候就变成了指定纹理坐标在最后。
错误的写法：

``` stylus
glNormal3f(n.x(), n.y(), n.z());
glVertex3f(p.x(), p.y(), p.z());
glTexCoord1f(g_p_DisFromFile->norm_dis[g_denoted_point_id][he->vertex()->tag()]);
```

不要以为这个bug很简单，说实话这种绘制的bug，不知道真的无从调试起来。。。这样写出现什么样子的bug，看下图吧。。。
![](https://c2.staticflickr.com/8/7241/27175251640_077ce24c67_o.png)

![](https://c2.staticflickr.com/8/7691/27417552636_58c2958b6a_o.png)
面片是不是很恶心的块状物？？？我这里绘制的是三维属性场，肯定是连续的，我无论怎么改插值模式，都没有用。。。
后面才回想起以前遇到过这个bug，所以改过来了。正确的代码应该是：

``` stylus
glTexCoord1f(g_p_DisFromFile->norm_dis[g_denoted_point_id][he->vertex()->tag()]);
glNormal3f(n.x(), n.y(), n.z());
glVertex3f(p.x(), p.y(), p.z());
```

正确的显示结果是：

![](https://c2.staticflickr.com/8/7425/27380202661_e1bb2be00c_o.png)

![](https://c2.staticflickr.com/8/7541/27175250770_c2656854e3_o.png)
如此简单的事情，能造成这样大的差距。