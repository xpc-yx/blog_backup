---
title: Urp下自定义特效管线和后处理特效实现
tags: 
- urp
- 特效
- 后处理
category: 
- 图形学
- Rendering
date: 2021-10-22 17:15:51
renderNumberedHeading: false
grammar_cjkRuby: true
---


# 一、如何获得颜色缓冲
网上搜索Unity的后处理或者获得屏幕缓冲，大部分会提到用grabpass到一张指定纹理上或者写一个后处理脚本挂在摄像机上。但是这种方式在Urp管线下已经不生效了。urp取消了默认管线抓取颜色缓冲的grabpass，同时也取消了[MonoBehaviour.OnRenderImage](https://docs.unity3d.com/ScriptReference/MonoBehaviour.OnRenderImage.html)，需要使用[ScriptableRenderPass](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@12.1/api/UnityEngine.Rendering.Universal.ScriptableRenderPass.html) 来完成类似的功能。ScriptableRenderPass是urp中的pass基类，urp预定义的pass都继承自该类，我们自定义的pass也需要继承自该类。

## 1.1 Urp的渲染顺序
urp中通过类型RenderPassEvent定义了一些列pass的渲染顺序或者说时机，大致的顺序是ShadowPass->PrePass(Depth Or DepthNormal)->Opaques->SkyBox->Transparents->PostProcessing，这个顺序也是Urp渲染管线的大致执行顺序。每个Pass或者说每个渲染事件都分Before和After，比如BeforePostProcessing和AfterPostProcessing分别表示后处理之前和后处理之后。
说了这么多，现在说结论，我们的特效Pass或者说特效管线就是要插入在BeforePostProcessing这个事件范围内。对了，同一个事件，比如BeforePostProcessing事件内的pass，最终的执行顺序是已加入管线的先后为准的。

## 1.2 Urp内置的CameraOpaqueTexture
那么，我们是一定要自定义一个Pass才能获得颜色缓冲吗？不需要，其实Urp的ForwardRenderer内会在某种情况下给我生成一个颜色缓冲存储到贴图_CameraOpaqueTexture中，通过调用函数SampleSceneColor就得获得屏幕颜色。不过，这个贴图的生成时机是固定的，只会在渲染不透明物体之后，更准确的说是在渲染天空盒之后，通过CopyColorPass把摄像机的颜色缓冲Blit到_CameraOpaqueTexture。同时，需要摄像机或者Urp设置中有开启需要OpaqueTexture或者某个Pass的Input有要求ColorTexture。
假如，不需要颜色缓冲中有半透明物体的信息，那么这个_CameraOpaqueTexture就已经足够了。问题是，特效基本是半透明物体，部分场景物体也可能是半透明物体。所以，默认的_CameraOpaqueTexture大概率满足不了需求。
因此，需要在半透明物体渲染之后再获取一次颜色缓冲。这个可以通过在AfterTransparents或者BeforePostProcessing事件中插入一个CopyColorPass来实现。

# 二、特效渲染管线
说实话，特效同学的要求有点多，要求部分特效受到全屏效果影响部分不受到影响。那么，特效要分成两部分渲染，一部分在全屏特效前，另外一部分在全屏特效后。那么，需要至少4个Pass，全屏特效前的特效Pass->CopyColorPass->全屏特效Pass->全屏特效后的特效Pass。
特效渲染管线如下：
1. EffectPass （渲染后处理特效前的特效）
2. CopyColorPass （拷贝屏幕颜色）
3. UberEffectPostRenderPass （渲染后处理特效）
4. EffectPass（渲染后处理特效后的特效）

其中，中间2个Pass最好是能够根据是否有全屏特效来动态激活。

## 2.1 EffectRenderFeature
Urp中需要定义RenderFeature来配置相应的Pass。因此，我们定义一个专门用于特效管线的Feature。在这个Feature中，我们按照上述的顺序加入这4个Pass，其中2和3根据全屏特效是否存在来判断是否加入渲染管线。

## 2.2 兼容UI特效穿插UI的解决方案
由于发现自定义一个BeforeRenderingPostProcessing的特效Pass来专门渲染特效，会导致所有的特效都在半透明物体之后渲染，而UI都是在半透明Pass渲染的，ShaderTag是UniversalForward，这样子会导致根据UI的Canvas来动态计算UI特效的sortingOrder以解决UI特效穿插UI的问题失效。因此，需要去除后处理特效前的特效pass，将这个Pass对应的特效改成默认的UniversalForward的ShaderTag。
那么，特效渲染管线最终是：
1. Urp默认的DrawObjectsPass（渲染后处理特效前的特效，兼容解决UI特效穿插界面问题的方案）
2. CopyColorPass （拷贝屏幕颜色）
3. UberEffectPostRenderPass （渲染后处理特效）
4. EffectPass（渲染后处理特效后的特效）

关键代码如下，在这个Feature中还定义ColorRT的名字和采样方式、全屏后处理超级Shader的名字等。

``` csharp
public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
{
    renderer.EnqueuePass(mEffectBeforePostProcessRenderPass);

    if (UberEffectPostRenderPass.IsPostProcessEnable())
    {
        mCopyColorRenderTarget.Init(RenderTargetName);
        mCopyColorPass.Setup(renderer.cameraColorTarget, mCopyColorRenderTarget, RenderTargetSampling);
        renderer.EnqueuePass(mCopyColorPass);
        renderer.EnqueuePass(mUberEffectPostRenderPass);
    }

    renderer.EnqueuePass(mEffectAfterPostProcessRenderPass);
}

public override void Create()
{
    Instance = this;

    //后处理特效前的特效pass（UniversalForward就会在后处理之前，因此不需要定义专门的Pass，专门的Pass会造成SortingOrder排序失效，UI无法遮挡特效）
    //mEffectBeforePostProcessRenderPass = new EffectRenderPass(new ShaderTagId("EffectBeforePostProcess"));
	//mEffectBeforePostProcessRenderPass.renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;

    //拷贝颜色缓冲pass
    mSamplingMaterial = CoreUtils.CreateEngineMaterial(Shader.Find("Hidden/Universal Render Pipeline/Sampling"));
    mCopyColorMaterial = CoreUtils.CreateEngineMaterial(Shader.Find("Hidden/Universal Render Pipeline/Blit"));
    mCopyColorPass = new CopyColorPass(RenderPassEvent.BeforeRenderingPostProcessing, mSamplingMaterial, mCopyColorMaterial);

    //特效后处理超级Pass
    mUberEffectPostRenderPass = new UberEffectPostRenderPass();
    mUberEffectPostRenderPass.renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;

    //后处理特效后的特效pass
    mEffectAfterPostProcessRenderPass = new EffectRenderPass(new ShaderTagId("EffectAfterPostProcess"));
    mEffectAfterPostProcessRenderPass.renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
}
```
Urp的ForwardRender配置如图：
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/EffectRenderFeature.jpg)
## 2.3 EffectRenderPass
特效渲染Pass用于渲染普通的特效，Pass跟Shader的对应方式是ShaderTag。关键代码如下，

``` csharp
public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
{
    DrawingSettings drawingSettings = CreateDrawingSettings(mShaderTag, ref renderingData, SortingCriteria.CommonTransparent);
    FilteringSettings filteringSettings = new FilteringSettings(RenderQueueRange.all);
    context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref filteringSettings);
}
```
有个需要注意的地方是物体渲染的排序方式要用SortingCriteria.CommonTransparent，毕竟特效都是半透明物体。这个标志是Urp默认的渲染半透明物体的排序方式，理论上是从后到前的顺序渲染。

## 2.4 UberEffectPostRenderPass
后处理特效Pass为了兼容面片类型的扭曲特效和全屏类型的色散、黑白屏、径向模糊特效，调用了2次绘制函数。第一次是用context.DrawRenderers绘制普通的物体；第二次是用cmd.DrawMesh绘制一个全屏三角形。同时为了支持，场景中出现多个全屏特效，该Pass中保存了一个材质数组，同时根据优先级来排序，优先级高的先渲染，这样就可以实现多个全屏特效的叠加效果。
代码如下，

``` csharp
public void AddMaterial(Material mat, int order = 0)
{
    var matOrder = mMaterialOrders.Find((temp) => temp.Mat == mat);

    if (matOrder == null)
    {
        matOrder = new MaterialOrder();
        matOrder.Mat = mat;
        mMaterialOrders.Add(matOrder);
    }
    matOrder.Order = order;

    mMaterialOrders.Sort((a, b) => a.Order - b.Order);
}

public void RemoveMaterial(Material mat)
{
    mMaterialOrders.RemoveAll((temp) => temp.Mat == mat);
}

public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
{
    DrawingSettings drawingSettings = CreateDrawingSettings(new ShaderTagId("UberEffectPost"), ref renderingData, SortingCriteria.RenderQueue | SortingCriteria.SortingLayer);
    FilteringSettings filteringSettings = new FilteringSettings(RenderQueueRange.all);
    context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref filteringSettings);

    if (mMaterialOrders == null || mMaterialOrders.Count == 0)
    {
        return;
    }

    CommandBuffer cmd = CommandBufferPool.Get();
    using (new ProfilingScope(cmd, mProfilingSampler))
    {
        //set V,P to identity matrix so we can draw full screen quad (mesh's vertex position used as final NDC position)
        cmd.SetViewProjectionMatrices(Matrix4x4.identity, Matrix4x4.identity);
        for (int i = 0; i < mMaterialOrders.Count; ++i)
        {
            Material mat = mMaterialOrders[i] != null ? mMaterialOrders[i].Mat : null;
            if (mat != null && mat.shader.name == mUberEffectPostShaderName)
            {
                cmd.DrawMesh(RenderingUtils.fullscreenMesh, Matrix4x4.identity, mat, 0, 0);
            }
        }

        cmd.SetViewProjectionMatrices(renderingData.cameraData.camera.worldToCameraMatrix, renderingData.cameraData.camera.projectionMatrix); // restore
    }
    context.ExecuteCommandBuffer(cmd);
    CommandBufferPool.Release(cmd);
}
```

# 三、后处理特效
## 3.1 屏幕扭曲
屏幕扭曲的效果最简单，只是偏移uv坐标即可。实现方式很多，基本上是采样噪声或者法线贴图来偏移uv坐标，核心代码大概如下：

``` csharp
	half2 screenUV = input.screenPos.xy / input.screenPos.w;
	float2 uvDiffuse = input.uv + float2(_ScreenDistortionU, _ScreenDistortionV) * _Time.y;
	float4 diffuseTex = tex2D(_ScreenDistortionDiffuse, TRANSFORM_TEX(uvDiffuse, _ScreenDistortionDiffuse));
	half2 offset = float2(diffuseTex.r, diffuseTex.g) * _ScreenDistortStrength;
	screenUV = screenUV + offset; return half4(SampleScreenColor(screenUV).rgb, 1);
```
以上代码计算了2次偏移，第一次偏移是计算噪声图的uv，第二次是计算颜色缓冲的uv，也就是屏幕uv。
效果如下，中间的部分放了一个扭曲面片特效。
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/屏幕扭曲.jpg)

## 3.2 色散
色散的原理也很简单，计算一个偏移的uv，分别在两个方向上计算r和b，不偏移的位置计算g，合并起来作为完整的颜色输出。

``` csharp
    half2 deltaUv = half2(_ColorDispersionStrength * _ColorDispersionU, _ColorDispersionStrength * _ColorDispersionV);
	result.r = SampleScreenColor(screenUV + deltaUv).r;
	result.g = SampleScreenColor(screenUV).g;
	result.b = SampleScreenColor(screenUV - deltaUv).b;
```

![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/色散.png)

## 3.3 黑白屏
黑白屏的关键实现代码也很短。但是想出来不太容易。网上大部分实现，就是简单的灰度化加上和屏幕颜色的插件。后面发现特效同学要的东西其实就是网上找了位特效大佬用ASE生成的shader效果，拿到代码后，过滤掉生成的冗余代码发现核心就是下面2个插值计算。

``` csharp
    half luminosity = dot(screenColor.rgb, half3(0.299, 0.587, 0.114));
    float smoothstepResult = smoothstep(_BlackWhiteThreshold, _BlackWhiteThreshold + _BlackWhiteWidth, luminosity.x);
    result = lerp(_BlackWhiteWhiteColor,_BlackWhiteBlackColor, smoothstepResult);
```
关键代码是smoothstep，在阈值和阈值+阈值范围之间曲线插值，返回的值再用来插值白屏颜色色和黑屏颜色。
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/黑白屏.png)

## 3.4 径向模糊
径向模糊的思想是沿着到中点的方向采样几个点，然后平均。代码如下，这里假定是6次采样。

``` csharp
    half2 dir = screenUV - half2(_RadialBlurHorizontalCenter, _RadialBlurVerticalCenter);
	half4 blur = 0;
	for (int i = 0; i < 6; ++i)
	{
		half2 uv = screenUV + _RadialBlurWidth * dir * i;
		blur += SampleScreenColor(uv);
	}
	blur /= 6;
    result = lerp(result, blur, saturate(_RadialBlurStrength));
```

不过，以上代码不一定能满足美术的需求。比如dir是否需要归一化，lerp时候是否需要考虑距离中点的远近等都会影响最终的效果。
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/径向模糊.png)

 ## 3.5 色散和径向模糊的结合
  如果先计算色散的DeltaUv，再将取屏幕颜色替换为屏幕扭曲的话，就能得到一个色散和径向模糊结合的效果，关键代码如下：
 
``` csharp
	half2 deltaUv = half2(_ColorDispersionStrength * _ColorDispersionU, _ColorDispersionStrength * _ColorDispersionV);
	result.r = RadialBlur(screenUV + deltaUv, screenColor).r;
	result.g = RadialBlur(screenUV, screenColor).g;
	result.b = RadialBlur(screenUV - deltaUv, screenColor).b;
```
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/色散和径向模糊的结合.png)

## 3.6 黑白屏和其它后处理效果的结合
实现方式是，如果开启了黑白屏，将屏幕颜色都应用一次黑白屏，然后再进行其它的处理，比如色散的代码修改为如下，
``` csharp
    half2 deltaUv = half2(_ColorDispersionStrength * _ColorDispersionU, _ColorDispersionStrength * _ColorDispersionV);
	half4 tempScreenColor = SampleScreenColor(screenUV + deltaUv);
#if _BLACKWHITE
    tempScreenColor = BlackWhite(tempScreenColor);
#endif
	result.r = tempScreenColor.r;
	
	tempScreenColor = SampleScreenColor(screenUV);
    #if _BLACKWHITE
        tempScreenColor = BlackWhite(tempScreenColor);
    #endif
	result.g = tempScreenColor .g;
	
	tempScreenColor = SampleScreenColor(screenUV - deltaUv);
    #if _BLACKWHITE
        tempScreenColor = BlackWhite(tempScreenColor);
    #endif
	result.b = tempScreenColor .b;
```
黑白屏和色散结合：
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/黑白屏和色散.jpg)
黑白屏和径向模糊结合：
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/黑白屏和径向模糊结合.jpg)
黑白屏和色散、径向模糊结合：
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/黑白屏和色散、径向模糊结合.jpg)

## 3.7 UberEffectPost超级Shader
具体实现上，我是用一个超级shader将这些功能整合到一起（除了屏幕扭曲，特效的需求是面片）形成一个UberShader。不同的效果通过shader_feature_local的开关来控制，这样既不用增加额外的大小和内存，也更方便美术同学的使用，整合到一起也是美术提出来的。
材质界面如下，
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/UberEffectPost.jpg)

## 3.8 UberEffectPost脚本
该脚本继承自MonoBehavior，用于判断是否存在全屏特效以及全屏特效材质、全屏特效优先级设置，并且在材质改变时候将后处理材质传入Pass等。
另外，美术同学要求加的后处理参数控制曲线也是在该脚本中，截图如下：
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/UberEffectPostScript.jpg)

这些参数曲线相对于TimeLine来说，可以更快的生成动态变化的后处理效果，减少美术去编辑TimeLine的工作量，不过自由度会有所降低。

# 四、参考资料

>1、[OnRenderImage](https://docs.unity3d.com/ScriptReference/MonoBehaviour.OnRenderImage.html)
>2、[仿.碧蓝幻想versus黑白闪后处理shader分享(build_in 与urp双版本)](https://zhuanlan.zhihu.com/p/419814256)