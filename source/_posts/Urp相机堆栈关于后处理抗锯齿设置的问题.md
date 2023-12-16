---
title: Urp相机堆栈关于后处理抗锯齿设置的问题
tags: 
- Urp
- 相机堆栈
- 后处理抗锯齿
category: 
- 图形学
- Rendering
date: 2021-12-28 11:10:00
renderNumberedHeading: false
grammar_cjkRuby: true
---


# 一、问题起源和影响
## 1.1 Base相机切换导致切换场景时候闪烁
问题是这样的，项目之前一直用场景相机作为Base相机，UI相机作为Overlay相机。渲染顺序是先渲染场景Base相机，然后渲染UI相机。不过，最近打包发现，在部分机器上，一切换场景时候，比如loading界面打开时候，屏幕会出现明显的闪烁，甚至还会花屏。

## 1.2 固定Base相机解决切换场景闪烁
尝试解决：并没有上FrameDebug或者RenderDoc去抓帧分析，比较麻烦。首先，尝试在切换场景之前就隐藏场景相机，发现花屏现象消失了，闪烁问题也大幅度减弱。猜测，是场景切换时候场景相机销毁， 导致必须切换Base相机导致整个相机堆栈都要重建的原因。
解决办法：固定一个空的Base相机，不渲染任何层，场景相机作为Overlay相机挂在Base相机上，然后是UI相机。
结果：原先loading界面闪烁的几个机器都不再闪烁。

## 1.3 尝试强制清除颜色缓冲解决花屏和闪烁
参考网上的文章，比如（[二）unity shader在实际项目中出现的问题————低档机（如小米4）切换游戏场景时花屏问题](https://blog.csdn.net/cgy56191948/article/details/103735487)，猜测这篇文章的应用场景是在固定管线下。在切换场景时候强制多次清除颜色缓冲，同时Base相机设置为SolidColor清除，场景相机本来就有天空盒，以尝试解决部分机型花屏和闪烁问题，结果还是失败。故放弃治疗。沿着固定Base相机的思路继续下去。

## 1.4 固定Base相机开启SMAA掉帧严重
由于MSAA会成倍增加RT的带宽和内存，带宽又是性能非常敏感的因素，所以放弃了。刚好Unity的Urp渲染管线支持SMAA和FXAA后处理抗锯齿，因此选择了后处理抗锯齿。
由于为了解决切换场景闪烁问题，固定空的Base相机，然后Base相机开启后处理抗锯齿，结果发现我的红米K30 Ultra掉帧非常严重，之前可以稳定30fps，改完之后在主场景只能跑到15fps左右。一开始还怀疑是场景没有合并网格，导致批次过高，编辑器内发现视线较远甚至到800Batches，远超100-200Batches的要求。后面想想，不可能突然掉帧这么严重，结果一FrameDebug，发现SMAA跑了2次。如下图所示：
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/相机堆栈上SMAA多次执行.png)
Base相机一次，场景Overlay相机一次，UI相机不开后处理所以没有。而一次SMAA实际上是三个全屏Pass，性能可想而知。
实际上，我们只想让场景相机有抗锯齿，和之前场景相机作为Base相机的情况保持一致。那么，我们就尝试只给场景相机开启后处理抗锯齿，结果发现完全没有效果。

# 二、Urp的相机堆栈
可以参考Unity中国官方发在知乎上的这篇文章：
[URP 系列教程 | 多相机玩法攻略](https://zhuanlan.zhihu.com/p/351638959)
简而言之，相机堆栈的意思是一系列的相机叠加在一起，Base相机作为基础设置，Base之上可以有任意的Overlay。按照叠加顺序从Base相机开始，一个个渲染，直到渲染完最后的相机，最终再把渲染结果的RT（注意，一个相机堆栈重用一个RT） Blit到屏幕上。

# 三、SMAA无法在Overlay相机单独生效的原因
Urp渲染管线默认使用的是前向渲染器ForwardRenderer，ForwardRenderer里面有两个PostProcessPass，一个是m_PostProcessPass，另一个是m_FinalPostProcessPass，后处理就是在这2个Pass里面实现的。注意，Urp定义的这种Pass只是逻辑上的，实际上可能对应多个渲染Pass。
PostProcessPass的Execute会判断是IsFinalPass来执行RenderFinalPass还是正常的Render。正常的Render主要对应的是UberPost相关的后处理，RenderFinalPass对应的FinalPost相关的后处理。更详细的细节不在此列，看源码吧。
问题在于，Render函数中如下图所示的判断，
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/PostProcess的SMAA判断.jpg)
cameraData是传递给每个Pass的RenderingData的成员，这些都是在渲染相机时候初始化好的。因此，怀疑对于Overlay相机这个标志无法传递到PostProcess。
回到UniversalRenderPipeline的RenderCameraStack函数，如下图所示，
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/overlayCameraData.jpg)
从这部分代码可以看到传递给overlay相机的overlayCameraData是通过baseCameraData初始化的，然后再通过InitializeAdditionalCameraData设置一些额外的参数。然后再去查看InitializeAdditionalCameraData的源码，发现没有设置抗锯齿模式的地方。再去查看InitializeStackedCameraData函数源码，如下所示，
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/urp抗锯齿模式设置.jpg)
最终确定抗锯齿模式是通过base相机设置，而overlay的抗锯齿模式不会生效，。这也就解释了为什么只设置base相机的smaa会导致overlay相机也执行了smaa，单独设置overlay相机的smaa反而无法生效。
那么如何解决了？很简单，在InitializeAdditionalCameraData函数中增加一行代码，将overlay相机的抗锯齿设置传递到overlayCameraData即可。

# 四、FXAA只能在最后一个相机生效（通常是UI相机）
SMAA的问题解决了。结果发现FXAA也无法生效，那只能继续查源码咯。
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/applyFinalPostProcessing.jpg)
如上截图所示，发现前向渲染器是根据标志applyFinalPostProcessing，来判断是否应用FinalPostProcessPass。而这个标志要求三个条件，相机堆栈开启了后处理、当前是最后一个相机、Base相机开启了FXAA，如果做了三的源码修改（Overlay的抗锯齿设置生效），那么需要是UI相机开启了FXAA。
FrameDebug的结果如下所示：
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/FXAA.jpg)

问题：开启了FXAA，UI界面肉眼可见的变模糊了，编辑器中都能体现出来。最终打算放弃FXAA，低端机选择不开抗锯齿，中高端机器开启SMAA。由于前述只对场景相机开启抗锯齿，因此不修改urp源码的情况下，FXAA是不会被激活的。

# 五、固定空Base相机引入的新问题
对比如下2个截图：
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/空base相机的问题.jpg)
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/场景相机作为Base.jpg)
第一个有额外空的Base相机，第二个直接使用场景相机作为Base相机。对比发现，Base相机无论如何会有Clear操作；然后还有一个渲染天空盒的操作。
如果我们把Base相机的天空盒模式改成颜色或者未初始化，就不会渲染天空盒。但是，对比第二张截图，天空盒是在渲染场景不透明物体后渲染的。因此，引入一个固定的Base相机会造成天空盒渲染顺序不对，导致效果出现问题，以及性能也会出现问题（一开始渲染天空盒导致Early-Z无法生效，OverDraw大幅度增加）。

## 5.1 解决天空盒渲染问题
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/Urp天空盒渲染条件.jpg)
根据上述代码截图，发现Urp的前向渲染强制只有Base相机才能激活天空盒渲染。我们直接去掉这个非isOverlayCamera判断即可。不过，需要Base相机设置为SolidColor清除方式；如果场景中还有额外的相机也需要注意不要设置天空盒，同样UI相机也是。

## 5.2 解决额外的Clear操作
我们对自定义的角色、场景、特效Pass加了对Base相机的限制，可以去除额外的2个Clear操作。最终Base相机就只有一个创建RT时候的Clear操作。这样Base相机的额外销毁可以降到最低。
FrameDebug场景渲染结果如下：
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/优化空的Base相机渲染和天空盒问题.jpg)

# 六、最终结论
## 6.1 固定空的Base相机避免切换场景闪烁
为了修复部分机型切换场景闪烁问题，固定一个空的base相机，并且ui相机固定为最后一个overlay相机。如此可以避免切换场景时候，Base相机会切换，从而避免闪烁问题。
为了兼容overlay相机支持SMAA和渲染天空盒，需要修改Urp的源码，如上所述。

## 6.2 中高端机器开启SMAA
为了兼容固定Base相机的情况下，单独设置场景相机的抗锯齿，需要修改urp源码支持overlay相机单独设置抗锯齿，从而只对场景overlay相机开启SMAA，Base相机不跑没必要的抗锯齿。同时UI相机不开抗锯齿，以避免UI模糊以及性能压力。

## 6.3 低端机不开启抗锯齿
低端机不开启抗锯齿。根据上述讨论，在不修改urp源码的前提下，低端机的场景相机无法开启FXAA。UI相机开启FXAA会导致UI肉眼可见模糊。所以最终选择低端机不开启任何抗锯齿。

## 6.4 优化结果
之前切换场景闪烁的机器都不再有花屏和闪烁现象；开启场景相机抗锯齿的情况下，红米k30 ultra从15fps左右恢复到稳定30fps。
果然是后处理猛如虎，带宽猛如虎。

# 七、参考资料

> [（二）unity shader在实际项目中出现的问题————低档机（如小米4）切换游戏场景时花屏问题](https://blog.csdn.net/cgy56191948/article/details/103735487)
> [URP 系列教程 | 多相机玩法攻略](https://zhuanlan.zhihu.com/p/351638959)