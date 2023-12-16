---
title: Urp渲染管线下的卡通冰效果实现
tags: 
- Urp
- 卡通冰
category: 
- 图形学
- Rendering
date: 2022-05-04 17:10:00
renderNumberedHeading: false
grammar_cjkRuby: true
---

# 一、卡通冰的效果
先看最终实现的卡通冰材质效果吧，如下所示：
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/卡通冰.png)
也可以调出类似玻璃的效果：
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/卡通冰-玻璃.png)
如果对一个球应用卡通冰材质，然后打开各种选项，可以得到如下效果：
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/卡通冰-球.png)
凹凸不平的地方是因为应用了法线贴图。

# 二、脚本和最终的材质界面
最终的材质界面，如下图所示：
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/卡通冰材质.png)
通过材质界面可以清晰看出卡通冰效果的各个模块。
另外为了获得屏幕颜色需要挂上一个脚本（PostProcessEffect）表示当前管线需要执行CopyColorPass。

# 三、折射
冰效果最关键的部分是折射，注意是折射而不是半透明。折射是透光冰看过去，后面的背景会发生一定的扭曲；而半透明混合是冰本身的颜色和背景做一定的混合，无法背景实现扭曲的效果。这里的实现思路参考之前的屏幕扭曲特效的实现方式，具体可以参考文章：[Urp下自定义特效管线和后处理特效实现](https://xiaopengcheng.top/2021/10/22/Urp%E4%B8%8B%E8%87%AA%E5%AE%9A%E4%B9%89%E7%89%B9%E6%95%88%E7%AE%A1%E7%BA%BF%E5%92%8C%E5%90%8E%E5%A4%84%E7%90%86%E7%89%B9%E6%95%88%E5%AE%9E%E7%8E%B0/)。
关于如何取得屏幕颜色贴图的方法不再赘述，另外为了优化性能，最终是判断是否需要获取屏幕颜色贴图（比如是否挂了屏幕特效脚本等）来决定是否执行CopyColorPass。

# 3.1 折射屏幕扭曲
获得屏幕颜色贴图后，只需要在屏幕空间下采样就能获得背景的颜色信息，至于扭曲的方式是通过一张扭曲贴图来采样当前位置的扭曲程度，这个扭曲程度加到屏幕空间UV上即可。一定程度的扭曲，能够模仿透过冰这种介质发生光线扭曲的这种效果。

# 3.2 折射强度控制
折射强度主要是通过NDotV来控制，另外提供了折射强度和控制贴图来调节。折射越强，越能透光冰看到后面的场景。至于为什么要使用NDotV，主要是为了贴近菲尼尔效应。根据菲涅尔效应，视线垂直于法线的情况下，反射越强，相应的折射越弱，NDotV越小。

# 四、卡通着色
这里的卡通着色就是一个二阶色的卡通着色，计算halfLambert，然后映射到2个颜色（暗色、亮色），中间的过渡用smoothstep插值。可以参考文章：[Unity下的日式卡通渲染实现-着色篇（一）](https://xiaopengcheng.top/2022/01/22/Unity%E4%B8%8B%E7%9A%84%E6%97%A5%E5%BC%8F%E5%8D%A1%E9%80%9A%E6%B8%B2%E6%9F%93%E5%AE%9E%E7%8E%B0-%E7%9D%80%E8%89%B2%E7%AF%87%EF%BC%88%E4%B8%80%EF%BC%89/)中的卡通着色部分。
那么卡通着色如何跟折射效果结合了？
可以使用折射强度去插值基础颜色和折射颜色，然后再用得到的基础色去计算卡通着色。

# 五、高光
高光就是Blinn-Phong的高光部分，计算NDotH，然后用pow(NDotH, 高光指数)来得到高光结果。比较简单，不再赘述。

# 六、边缘光
边缘光也是通过NDotV来判断边缘光程度，方法是判断NDotV是否小于边缘光宽度。这样不仅可以通过NDotV简单的模仿物体边缘判断，而且可以通过边缘光宽度来调整边缘光的大小。
高光和边缘光是叠加在卡通着色基础之上的，叠加比例是1-折射强度。

# 七、描边
描边就是使用沿着法线外扩的卡通渲染描边，可以参考文章：[Unity下的日式卡通渲染实现-描边篇（三）](https://xiaopengcheng.top/2022/03/12/Unity%E4%B8%8B%E7%9A%84%E6%97%A5%E5%BC%8F%E5%8D%A1%E9%80%9A%E6%B8%B2%E6%9F%93%E5%AE%9E%E7%8E%B0-%E6%8F%8F%E8%BE%B9%E7%AF%87%EF%BC%88%E4%B8%89%EF%BC%89/)。

# 八、溶解
为了满足特效那边的冰消融的需求，额外添加了一个溶解部分。材质设置如下图：
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/卡通冰-溶解材质.png)
溶解的实现很简单，提供一个溶解阈值，使用颜色贴图或者控制贴图的Alpha通道，来做AlphaTest。当然具体实现是用clip函数丢弃像素。

## 8.1 溶解颜色
为了模仿消融的效果，提供了一个溶解颜色来表示消融的过渡色，过渡色和本来的颜色通过smoothstep来插值，插值参数是溶解程度，溶解程度即是alpha减去溶解阈值。
效果如下图所示：
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/卡通冰-溶解.png)
可以看到溶解的边缘有一个溶解过渡颜色。

# 九、控制贴图
为了方便美术控制效果，额外提供了一张控制贴图，四个通道分别控制：高光强度、边缘光强度、折射强度、溶解Alpha值。

# 十、参考资料

> [Urp下自定义特效管线和后处理特效实现](https://xiaopengcheng.top/2021/10/22/Urp%E4%B8%8B%E8%87%AA%E5%AE%9A%E4%B9%89%E7%89%B9%E6%95%88%E7%AE%A1%E7%BA%BF%E5%92%8C%E5%90%8E%E5%A4%84%E7%90%86%E7%89%B9%E6%95%88%E5%AE%9E%E7%8E%B0/)
> [Unity下的日式卡通渲染实现-着色篇（一）](https://xiaopengcheng.top/2022/01/22/Unity%E4%B8%8B%E7%9A%84%E6%97%A5%E5%BC%8F%E5%8D%A1%E9%80%9A%E6%B8%B2%E6%9F%93%E5%AE%9E%E7%8E%B0-%E7%9D%80%E8%89%B2%E7%AF%87%EF%BC%88%E4%B8%80%EF%BC%89/)
> [Unity下的日式卡通渲染实现-描边篇（三）](https://xiaopengcheng.top/2022/03/12/Unity%E4%B8%8B%E7%9A%84%E6%97%A5%E5%BC%8F%E5%8D%A1%E9%80%9A%E6%B8%B2%E6%9F%93%E5%AE%9E%E7%8E%B0-%E6%8F%8F%E8%BE%B9%E7%AF%87%EF%BC%88%E4%B8%89%EF%BC%89/)