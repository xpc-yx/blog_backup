---
title: scaleform中从unrealscript往actionscript传输数据的方式
tags:
  - scaleform
id: 1666
categories:
  - UE4
date: 2015-10-17 16:06:18
---

在逆战的界面开发中，一般只需要从uc往flash中单向传输数据，因此这里只总结从uc->flash的数据流动方法。flash->uc的数据流动，其实有相对应的方式，比如SetVariableBool函数有对应的GetVariableBool函数。

在unrealscript中，使用scaleform的界面类，都继承自GfxMoviePlayer。

一、传输变量

native function SetVariableString(string path, string s);

native function SetVariableBool(string path, bool b);

native function SetVariableNumber(string path, float f);

我在GfxUIMovie中没找到专门设置int的函数，估计可以用SetVariableNumber替代。关键是理解path的设置，比如对应flash文件的名称是ReBornGuide。那么path可能是ReBornGuide.str或者_root.ReBornGuide.str，具体跟ue3项目的一些设置有关。

这几个函数对应的cpp声明如下：

String：SetVariableString(const FString path, const FString s);

Bool：SetVariableBool(const FString path, UBool b);

Float：SetVariableNumber(const FString path, float f);

有趣的是，这几个函数的字符串参数都是引用，这样恰恰说明了在uc中，字符串是引用类型。

例子：

``` stylus
test.uc中：
String strTest = "测试";
String path = "_root.TestFlash.strTest";
SetVariableString(path，strTest);
TestFlash.as中：
var strTest:String;
```

二、传输数组

native function bool SetVariableStringArray(string path, int index, array<string> Arg);

native function bool SetVariableFloatArray(string path, int index, array<float> Arg);

native function bool SetVariableIntArray(string path, int index, array<int> Arg);

其对应的cpp实现

String：SetVariableStringArray(const FString path,  INT Index，const TArray<FString> arg);

Float：SetVariableFloatArray(const FString path, INT Index，const TArray<FLOAT> arg);

Int：SetVariableFloatArray(const FString path, INT Index，const TArray<INT> arg);

这里Index表示从数组的第几个元素开始，0表示传输全部，arg是要传输的数组。

例子：

``` stylus
test.uc中：
local array<String> strArray;
strArray.AddItem("0");
strArray.AddItem("1");
String path = "_root.TestFlash.strTest";
SetVariableStringArray(path，strArray);
TestFlash.as中：
var strArray:Array = new Array();
```

三、传输复合对象（结构体）

当需要传输整体的数据，或者传输多个数据的时候，可以将数据组合成一个结构体。假设在uc中定义了如下结构体，

``` stylus
struct RankData
{
   var string Name;
   var int Rank;
   var double d;
   var float f;
   var bool b;
};
RankData RD;
```

我们想将其一次性传入as中定义的Object对象,var RD:Object。这里我们可以使用SetVariableObject函数。其定义如下：

native function SetVariableObject(string path, GFxObject Object);

下面的例子很好说明了如何使用该函数。

``` stylus
uc中:
struct RankData
{
   var string Name;
   var int Rank;
   var double d;
   var float f;
   var bool b;
};

function SetFlashVariables()
{
    local GFxObject GfxObj;
    local RankData RD;
    local string path;

    RD.Name = "test";
    RD.Rank = 1;
    RD.d = 1.0;
    RD.f = 1.0;
    RD.b = True;
    GfxObj = CreateObject("Object");
    GfxObj.SetString("Name", RD.Name);
    GfxObj.SetInt("Rank", RD.Rank);
    GfxObj.SetDouble("d", RD.d);
    GfxObj.SetFloat("f", RD.f);
    GfxObj.SetBool("b", RD.b);

    path = "_root.TestFlash.RD"
    SetVariableObject(path, GfxObj);
    GfxObj.DestroyObject();
}

TestFlash.as中:
var RD:Object = new Object();
//在uc中调用了SetFlashVariables函数后，as中就能获得RD的值。
trace(RD.Name);
trace(RD.Name);
trace(RD.f);
trace(RD.d);
trace(RD.b);
```

从上面代表可以看出，GFxObject可以代表一个符号变量，可以设置一个GFxObject的多个属性，然后一次性将这个对象传入flash。GFxObject.uc中有如下Set变量的函数：

``` stylus
native final function SetBool(string Member, bool b);
native final function SetFloat(string Member, float f);
native final function SetDouble(string Member,double d);
native final function SetInt(string Member,int i);
native final function SetString(string Member, string s);
native final function SetObject(string Member, GFxObject val);
```

因此，可以看出可以设置GFxObject各种类型的属性。关键的是还可以设置其GFxObject类型的属性，从而可以嵌套定义。比如结构体中定义另一结构体成员。当需要将多次传输组合为一次时候，也可以使用这种方式，并不需要一定定义结构体。

四、传输结构体数组

假设as中定义如下数组，var RankListDatas:Array = new Array();那么可以用下面代码传输：

``` stylus
//军衔列表每项的数据
struct RankListData
{
    var int Level;//等级
    var string Name;//军衔名
};
var array<RankListData> RankListDatas;
var string path;
function SetFlashRankListDatas()
{
    local int Index;
    local GFxObject GfxRankListDatas;
    local GFxObject GfxTempObj;

    GfxRankListDatas = CreateArray();
    for (Index = 0; Index < RankDatas.Length; Index++)//第0项是多余的
    {        
        GfxTempObj = CreateObject("Object");
        GfxTempObj.SetInt("Level", RankListDatas[Index].Level);
        GfxTempObj.SetString("Name", RankListDatas[Index].Name);
        GfxRankListDatas.SetElementObject(Index, GfxTempObj);
        GfxTempObj.DestroyObject();
    }

    SetVariableObject(path, GfxRankListDatas);
    GfxRankListDatas.DestroyObject();
}
```

从代码里面可以看到，还是用SetVariableObject传输数据。不过，需要用CreateArray()创建GFxObject对象。在as代码中RankListDatas[0].Name就可以访问第一个元素的Name属性了。

GfxRankListDatas.SetElementObject(Index, GfxTempObj)则是将GfxTempObj设置为GfxRankListDatas代表的数组的第Index个元素。

五、传输结构体数组的数组（结构体内部复合结构体数组）

``` stylus
struct AwardData
{
    var string IconSource;
};

struct RankAwardData
{
    var string RankAwardTitle;
    var array<AwardData> AwardDatas;
};
var array<RankAwardData> RankAwardDatas;
var string path;

function SetFlashRankAwardDatas()
{
    local int Index;
    local int i;
    local GFxObject GfxRankAwardDatas;
    local GFxObject GfxTempObj;
    local GFxObject GfxAwardDatas;
    local GFxObject GfxAwardTempObj;

    GfxRankAwardDatas = CreateArray();
    for (Index = 0; Index < RankAwardDatas.Length; Index++)
    {        
        GfxTempObj = CreateObject("Object");
        GfxTempObj.SetString("RankAwardTitle", RankAwardDatas[Index].RankAwardTitle);

        GfxAwardDatas = CreateArray();
        for (i = 0; i < RankAwardDatas[Index].AwardDatas.Length; ++i)
        {
            GfxAwardTempObj = CreateObject("Object");
            GfxAwardTempObj.SetString("IconSource", RankAwardDatas[Index].AwardDatas[i].IconSource);
            GfxAwardDatas.SetElementObject(i, GfxAwardTempObj);
            GfxAwardTempObj.DestroyObject();
        }
        GfxTempObj.SetObject("RankAward", GfxAwardDatas);
        GfxRankAwardDatas.SetElementObject(Index, GfxTempObj);
        GfxAwardDatas.DestroyObject();
        GfxTempObj.DestroyObject();
    }

    SetVariableObject(path, GfxRankAwardDatas);
    GfxRankAwardDatas.DestroyObject();
}
```

从上面代码可以看出，调用GfxTempObj.SetObject("RankAward", GfxAwardDatas)可以设置GFxObject对象的GFxObject属性，从而能够传输复合结构体类型的数组。假设as中对应的数组定义为var RankAwardDatas:Array=new Array();那么，在as代码中RankAwardDatas[0].RankAward.IconSource则能访问该数组第一个元素的结构体成员的IconSource属性。