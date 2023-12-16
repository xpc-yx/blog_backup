---
title: Matcap的原理和应用
tags:
- Matcap
category: 
- 图形学
- Rendering
date: 2022-9-19 17:15:51
renderNumberedHeading: false
grammar_cjkRuby: true
---


# 一、概念和原理
## 2.1 什么是Matcap
  什么是Matcap？Matcap实际上是Material Capture的缩写，即材质捕捉。实际上，这是一种离线渲染方案。类似光照烘焙，将光照或者其它更复杂环境下的渲染数据存储到一张2D贴图上， 再从这张2D贴图进行采样进行实时渲染。

[Materials (MatCap)](https://help.sketchfab.com/hc/en-us/articles/115003065883-Materials-MatCap-)这篇文章对Matcap的定义是：
MatCap (Material Capture) shaders are complete materials, including lighting and reflections. They work by defining a color for every vertex normal direction relative to the camera. 

## 2.2 如何理解Matcap
Matcap是一种在视线空间下使用单位法线采样单位球的离线渲染算法。
- 为什么是视线空间？因为视线空间下，相机变化就可以看到不同的渲染结果。
- 为什么使用法线去采样了？法线是描述表面朝向的向量，与渲染结果强相关，法线跟物体的曲率强相关等，因此这种算法经常用于 sculpting上。


## 2.3 Matcap的特点
Matcap的特点总结如下：
 - 使用视线空间下的法线向量采样2D贴图，作为光照和反射结果。
 - 在缺乏光照烘焙的环境下，可以一定程度上替代或者模拟光图。
 - 但是，Matcap代表的2D贴图不局限于光照信息，也可以理解为某种环境下的最终渲染结果。
 - 由于是离线方案，因此计算非常廉价，很适合低端机器或者特定场合下使用。

# 二、如何实现Matcap
## 2.1 如何获得Matcap贴图
按照定义，matcap贴图是一张2D贴图，内部包含一个单位球，表示光照信息。如何获得这样的贴图了？
- 从网上的材质库下载
  比如，[matcaps](https://github.com/nidorx/matcaps)
- 引擎预览材质球然后截图。
![材质预览matcap](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/材质预览matcap.png)
如上图，可以把右边的预览结果紧贴着球体进行截图。
当然，如果严格按照定义，Matcap表示的是光照信息，不是所有材质预览的结果都可以当作Matcap贴图。

## 2.2 如何采样Matcap贴图

``` cpp?linenums
// -------------------------------
// Vertex
// -------------------------------
VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
output.normalWS = normalInput.normalWS;

// -------------------------------
// Fragment
// -------------------------------
float3 viewNormal = mul((float3x3)GetWorldToViewMatrix(), normalWS);
float2 matCapUV = viewNormal.xy * 0.5 + 0.5;
half3 matcapColor = SAMPLE_TEXTURE2D(_Matcap, sampler_Matcap, matCapUV).rgb;
```
从上述glsl代码可以看出，需要把法线转换到视线空间，然后再将法线偏移到[0,1]的范围内，然后取xy分量作为uv，对matcap纹理进行采样。

# 三、Matcap的问题
## 3.1 边缘瑕疵
有时候使用Matcap渲染，模型上会出现一条线或者缝隙。可能的原因是采样到了贴图的边缘部分，而有些matcap贴图制作上不太好，边缘区域过大。
![matcap边缘瑕疵](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/matcap边缘瑕疵.png)
如上图所示：左边的matcap贴图就是一个非常不规范的matcap贴图，球没有紧贴边缘，而是出现大量空白部分，导致兔子的边缘出现大量的灰色边缘。
解决方式有两种，一种是强制采样内部的像素；另一种方式是修改采样算法，使得更合理避免出现边缘区域。
## 3.2 单点采样
对于平面来说，其法线朝着同一个方向的，因此会出现整个平面获得的matcap颜色都是同一个像素点，与正常的光照结果相差很大。我们希望的是，即使是一个平面，不同的像素点也是有不同的光照结果。

## 3.3 解决办法
### 3.1.1 缩放uv
第一种方式是对matcapUV进行缩放，比如缩小uv可以使得避免采样边缘区域。

``` cpp
float2 matCapUV = viewNormal.xy * 0.5 * _MatcapUVScale + 0.5;
```
这种方式可以简单的解决边缘瑕疵问题，但是无法解决单点采样。


### 3.1.2 使用视线空间下单位球的法线
![matcap优化](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/matcap优化.png)
如上图所示，在Matcap的定义中，我们处于视线空间内，视线方向始终是（0，0，1）。我们最终要使用的是单位球的N方向。假设反射方向是R，可以计算得到N是(Rx，Ry，Rz+1)。那么问题转化为求反射向量R。我们可以用视线空间的顶点和法线求得视线空间下的R，然后用视线空间的R去代替单位球上的反射向量R即可，即使两个方向向量不能等价，也可以得到相应正确的结果。
这种算法可以显著优化平面的单点采样问题。
![matcap优化对比](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/matcap优化对比.png)

从上图可以看出，对于平面来说，两种算法的效果差异非常明显。

# 四、Matcap与其它效果的结合
下面的测试均以如下Matcap贴图为例。
![matcap输入](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/matcap输入.png)
## 4.1 基础颜色
如果把Matcap当作光照的结果，那么可以额外提供基础颜色来控制最终结果。比如，提供基础颜色贴图和基础颜色，乘以到matcap上作为最终输出。
![matcap基础色](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/matcap基础色.png)
## 4.2 法线贴图
既然matcap需要用到法线，那么可以额外提供法线贴图去修改像素的法线。
![matcap法线](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/matcap法线.png)
从上图可以看出，法线对最终的渲染结果影响显著。

## 4.3 自发光
类似正常的光照计算，可以在matcap的结果之上，再叠加自发光。

## 4.4 模拟高光
matcap本身已经是光照计算的结果，因此理论上贴图内带有了漫反射、高光、反射的信息。但是，通常情况下，matcap主要包括的还是漫反射信息，或者说表现不出明显的高光信息。
有一种简单模拟高光的方式，提供一个高光阈值，使用matcap减去该颜色阈值，然后除以1-阈值。最终结果再用原matcap颜色相乘避免过曝。
![matcap高光](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/matcap高光.png)

## 4.5 Cubemap反射
同时，可以额外利用cubemap计算静态反射结果叠加到最终着色上。
![matcap反射](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/matcap反射.png)

## 4.6 模拟边缘光
利用dot(normalWS, viewDirWS)计算出边缘光的强度，再将边缘光颜色与强度相乘叠加到最终着色结果上即可。

## 4.7 模拟折射
折射一种扭曲的效果，因此我们可以通过扭曲matcap的采样位置和反射的采样位置来模拟折射。同时，可以乘以边缘光的强度来模拟菲尼尔效应，也就是边缘光强的地方折射更强。然后，利用这个扭曲强度去偏移matcap的uv和反射向量，即可在一定程度上模拟折射的效果。
![matcap折射](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/matcap折射.png)
如上图所示，边缘的红色是边缘光；同时，噪声贴图作为折射扭曲强度贴图让边缘光看起来比较细碎，用来模拟折射效果。

## 4.8 光照强度
同时，也可以计算出真实的光照强度，将光照强度乘以matcap颜色，让matcap的着色结果受到灯光影响。不过，这跟matcap的初衷不太一致。


# 五、参考资料

> [Materials (MatCap)]([Matcap的原理和应用](xsjapp://doc/b62819d2-d505-4107-8b34-5a176c25bc82#xsj_1702740535139))
> [https://github.com/nidorx/matcaps](https://github.com/nidorx/matcaps)
> [MatCap Shader 改进：解决平面渲染和环境反射问题](https://zhuanlan.zhihu.com/p/79040521)