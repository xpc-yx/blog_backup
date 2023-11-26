---
title: DrawCall、Batches、SetPassCalls的区别和联系
tags: 
- Unity
- DrawCall
- Batches
- SetPassCalls
category: 
- 图形学
- Rendering
date: 2020-06-08 16:25:00
renderNumberedHeading: false
grammar_cjkRuby: true
---

# 一、DrawCall、Batches、SetPassCalls的基本理解
我们先从图形渲染的角度对这些概念做一个基本的理解。
## 1.1 DrawCall
DrawCall实际上指的是一次图形渲染接口的调用，比如OpenGL的glDrawArrays或者glDrawElements的一次调用，以及DirectX的DrawPrimitive或者DrawIndexedPrimitive。因此，DrawCall可以简单理解为一次渲染指令调用。

## 1.2 Batches
我们知道，在调用DrawCall之前，需要设置渲染状态，比如当前使用的Shader、当前shader的参数（材质参数）、深度测试是否开启、模板测试设置等，设置完这些状态后，才会调用DrawCall。我们把设置渲染状态，加载网格数据，然后调用DrawCall这一个过程，叫做一个批次。理论上，我们可以在设置完渲染状态后，调用多个DrawCall，假如一个DrawCall的绘制数量有限制的话，但是通常一个批次也就调用一次DrawCall。
那么所谓合批，就是想办法尽量减少批次。减少批次的关键是减少场景中不同的渲染状态组合，也就是渲染状态切换尽可能少。这样子批次自然最少。批次少了，批次对应的DrawCall自然少了，每个批次需要的渲染状态切换也少了。注意，渲染状态切换类似于DrawCall都是一次渲染指令调用。

## 1.3 SetPassCalls
那么什么是SetPassCalls了。在Shader中有一个Pass的概念，比如一个Shader有2个Pass，那么实际上应用这个Shader的物体会按照Shader的Pass定义顺序渲染2遍，每一遍都是用对应的Pass渲染。Unity的官方文档里面解释SetPassCalls就是Shader中的Pass被切换的次数，因为每个渲染批次都会设置一个Pass，一个Pass就会对应一些渲染状态，当渲染状态变化时候就必须开始新的批次，但是新的批次下Pass可能没有变化

# 二、Unity的DrawCall、Batches、SetPassCalls区别和联系
我们以一个没有开启静态合批的场景运行时的统计数据为例子来说明。我们打开Unity场景的Statistics窗口，
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/UnityStatistics.jpg)
以及Profile窗口，
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/UnityProfileRendering.jpg)
FrameDebug窗口，
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/UnityFrameDebug.jpg)

我们可以得出这个场景的DrawCall是584，Batches也是584，SetPassCalls是192。Statistics中是不会显示DrawCall的，只有在Profile窗口下选中Rendering才能看到。

## 2.1 Unity的DrawCall
根据运行数据，可以得出结论DrawCall数目基本等于Batches。为什么说基本了？因为同一个Batch下，可能分多次调用DrawCall，比如网格过于巨大，可能拆分成多个DrawCall，这个也是符合批次的定义的，因为渲染状态没有切换，这发生在静态合批和动态合批的情况下。
如果没有静态合批和动态合批，那么DC等于Batches，如果有那么DC没有变化，但是Batches等于合并之后的渲染状态切换。

## 2.2 Unity的Batches
Unity的批次实际上就是前面解释的Batches。不过，Batches实际上包含有三类：Static Batches、Dynamic Batches、Instancing Batches，分别对应Unity的静态合批、动态合批、实例化渲染。

## 2.3 Unity的SetPassCalls
根据FrameDebug窗口可以看到，一共是197+24+1+1=233个渲染事件。其中，Clear事件有14个。除去Clear事件后还生效219的事件，不过我们的SetPassCalls是192，还多了17个。我们观察到UI相机有18个DrawMesh事件，点击后发现这个事件使用的都是同样的Pass，如下图所示，
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/UnityUIPass.jpg)
，这些Pass之间除了材质属性外的渲染状态都是一致的，因此还要减去17。
注意，FrameDebug窗口的截图中折叠的部分基本是SRP Batch。
根据这些数据我们可以得出结论，如果支持SRP Batch，一个SetPassCall等于一个SRP Batch；如果不支持SRP Batch，那么一个SetPassCall就是一次Shader的Pass切换。由于Pass切换实际上指的是Shader关键字或者ROP阶段的设置改变，那么其实这个跟SRP是一致的。SRP本质上也是Shader变体切换，而非传统的材质切换。传统的材质切换对应的是Batches。
注明：实验引擎版本是Unity2020.3.12。

## 2.4 总结
至此可以得出最终结论，Unity的DrawCall和Batches数目在没有静态合批和动态合批时候相等，Batches对应的是传统的材质切换，DrawCall是一次Batch内一次到多次的渲染命令调用。SetPassCalls一般会大幅度少于Batches，对应的是SRP Batch或者Pass切换，数目等于FrameDebug中的事件数目减去Clear事件、Draw Mesh事件中重复的Pass数目。

# 三、DrawCall相关的性能优化
## 3.1 为什么需要降低DrawCall
 一谈起游戏优化，尤其是渲染优化，大家就说降低DrawCall，降低批次。实际上，大部分人都没法正确区分，Unity引擎下DrawCall、Batch、SetPassCall这三个概念。DrawCall或者批次高，并不是性能低下的直接原因，真正的原因是批次高，导致渲染状态切换过多。而渲染状态切换实际上是发生的渲染管线的CPU阶段，使用图形API，比如OpenGL或者DirectX来完成的。这样CPU会花费大量的时间提交渲染指令给GPU，CPU占用过高，但是GPU的渲染指令队列并没有饱和，GPU执行渲染指令的速度很快，因此GPU的负荷可能还没上来，GPU在等待CPU提交渲染指令，整个渲染流水线没有最高速的跑起来。当然如果GPU也忙不过来，那么不仅仅需要降低批次，Shader复杂度和OverDraw应该是重点关注对象。
 
 ## 3.2 如何降低批次
 ### 3.2.1 静态合批
 静态合批实际上是引擎在打包或者烘焙时候，将同材质的物体合并成一个更大的物体，这样相同材质的物体只需要一次渲染状态设置和一次DrawCall调用，也就一个批次。由于合并生成大的模型后，会占用额外的内存空间，比如三个同材质的立方体的网格就是一个简单的立方体，合并后的网格占用是三个世界空间立方体的组合，因此有时候需要考虑静态合批带来的内存增长。
 
 ### 3.2.2 动态合批
 动态合批是静态合批在运行时的体现。Unity对动态合批有一些限制，比如限制模型顶点属性不能超过900等，具体可以参考[Dynamic batching](https://docs.unity3d.com/2021.2/Documentation/Manual/dynamic-batching.html)。动态合批由于是运行是合并网格，因此不仅会增大内存，还会占用CPU时间。动态合批一般应用在一些小物体的合并上，比如小的道具或者特效等。
 
 ### 3.4.3 Instancing Draw
 Instancing Draw实际上是图形接口支持的一种技术，可以翻译为实例化渲染，可以参考文档：[实例化](https://learnopengl-cn.github.io/04%20Advanced%20OpenGL/10%20Instancing/)。这种技术通常应用在重复的物体大量出现的情况下，比如说草地、树木、星星，这种只有位置或者朝向、缩放等不一样。实例化渲染可以通过指定每物体属性（正常的每顶点属性是每个顶点不一样）来传入这种每个物体不一样的属性，从而避免使用不同的材质。在OpenGL中是使用glVertexAttribDivisor来设置属性的更新速度，从而指定每物体属性。
 至于Unity的Instancing，参考文档：[GPU instancing](https://docs.unity3d.com/Manual/GPUInstancing.html)。关键点：GPU instancing不能和SRP Batcher、Static Batcher并存，SRP Batcher、Static Batcher的优先级更高；GPU instancing不支持 SkinnedMeshRenderers（蒙皮）； Graphics.DrawMeshInstanced或者Graphics.DrawMeshInstancedIndirect是主动Instancing，如果不调用这2个函数，那么Unity会尝试Instancing（如果Shader支持Instancing，且没有开启SRP Batch），这会有额外的CPU消耗。
 
 ### 3.4.4 SRP Batcher
 参考文档：[Scriptable Render Pipeline (SRP) Batcher](https://docs.unity.cn/2019.4/Documentation/Manual/SRPBatcher.html)。关键点：只有可编程管线才支持，默认管线不能支持；Shader必须支持SRP Batcher；只支持Mesh和SkinMesh，不支持粒子系统；不能与 Instancing Draw兼容；如果使用了MaterialPropertyBlock，SRP Batcher无法开启。
 SRP Batcher本质上是Shader变体级别的合批优化，根据前面的分析等价于一次SetPassCall。具体原理还是参考Unity 的官方文档。
 
 ### 3.4.6 合批方法的优先级
 根据Unity优化DC的官方文档[Optimizing draw calls](https://docs.unity3d.com/2021.2/Documentation/Manual/optimizing-draw-calls.html)，合批方法的优先级如下：

 1.SRP Batcher and static batching
 2.GPU instancing
 3.Dynamic batching
 其中SRP和静态合批是最高优先级，并且是可以兼容的（对于使用SRP Batcher兼容Shader的物体），因此可以同时启用静态合批和SRP Batcher。不过，经过实验发现上述实验场景在开启了SRP Batcher后，再去打开静态合批，Batches并没有多少什么变化，猜测是场景内使用同样材质的物体过少，相反使用同样Shader变体的物体较多。

 ### 3.4.5 合批总结
 对于目前的可编程管线，优先使用的都是SRP，因此Shader要尽可能兼容SRP Batcher。对于特殊情况，比如渲染草地这种，才需要舍弃SRP Batcher去使用实例化渲染。对于不支持SRP Batcher的Shader，动态合批和静态合批才可能会被开启。动态合并和静态合批都要增大内存，动态合批还会占用CPU，限制条件还非常多。所以，首选SRP Batcher和Instancing。
由于SRP Batcher不能降低DrawCall和Batcher，实际上降低的是SetPassCall；但是静态合批和动态合批可以降低Batcher，但是不能降低DrawCall。所以，在一些低端机器上，Batcher过多可能引起问题的话，还是得开启传统的静态合批，不过这会需要打开网格读写，合并网格也会增大包体和内存。因此出现这种情况的话，最好的选择应该是只开启SRP Batcher，然后让美术手工合并网格和贴图。

# 四、参考资料

> [DrawCall，Batches，SetPass calls是什么？原理？【匠】](https://blog.csdn.net/qq_30259857/article/details/110062397)
> [The Rendering Statistics window](https://docs.unity.cn/cn/2022.1/Manual/RenderingStatistics.html)
> [Unity Profiler中常见的WaitForTargetFPS、Gfx.WaitForPresent 和 Graphics.PresentAndSync](https://blog.csdn.net/yudianxia/article/details/79398590)
> [Draw call batching](https://docs.unity3d.com/2021.2/Documentation/Manual/DrawCallBatching.html)
> [Optimizing draw calls](https://docs.unity3d.com/2021.2/Documentation/Manual/optimizing-draw-calls.html)
