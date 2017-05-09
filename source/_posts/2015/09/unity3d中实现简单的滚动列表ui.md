---
title: unity3d中实现简单的滚动列表ui
tags:
  - unity3d
  - 滚动列表
id: 1638
categories:
  - Unity3d
  - 游戏开发
date: 2015-09-10 20:59:23
---

本来是想实现一个简单的下拉列表的。但是发现u3d的默认ui没有这种控件，来不及学习其它的ui，比如ngui。只能退而求其次，用按钮填充滚动列表来代替下拉列表。

u3d里面实现滚动列表很简单，GUILayout.BeginScrollView和GUILayout.EndScrollView或者GUI.BeginScrollView和GUI.EndScrollView函数对就是一个简单的滚动区域。实际上，这个函数对的使用起来没那么简单方便。为了方便起见，我使用了第一个带布局的函数对，这样就不用操心具体的控件位置。这里我要说的注意点有两个。

第一个是控制滚动条什么时候显示。下面的语句`scrollPosition = GUILayout.BeginScrollView(scrollPosition, GUILayout.Width(userWindowRect.width * 0.95f), GUILayout.Height(userWindowRect.height * 0.8f));`开始一个滚动区域，第二个参数表示水平方向的内容超过的多少后显示水平滚动条，第三个参数则对应垂直滚动条。

第二个是我要写这篇文章的原因。为此我浪费了一天的时间解决。我把scrollPosition定义成局部变量，发现滚动条无法拖动。必须把其定义成类变量或者静态变量，才能有滚动的效果。想想也很容易明白，因为游戏里面的ui终究还是绘制出来的，OnGUI实际上每帧在刷新。如果scrollPosition是局部变量，那么每次刷新，滚动区域肯定停留在同一个位置。

如果要控制滚动列表的显示在窗口哪一个部分，可以在外部添加BeginArea和EndArea函数对。参考下面的例子，实现一个滚动列表。

``` stylus
Rect scrollRect = new Rect(userWindowRect.width * 0.02f, userWindowRect.height * 0.1f, userWindowRect.width * 0.95f, userWindowRect.height * 0.88f);
GUILayout.BeginArea(scrollRect);

scrollPosition = GUILayout.BeginScrollView(scrollPosition, GUILayout.Width(userWindowRect.width * 0.95f), GUILayout.Height(userWindowRect.height * 0.8f));

playerName = GUILayout.TextField(playerName);
for (int i = 0; i < pn.numOfPlayers; ++i)
{
    if (GUILayout.Button(pn.nameList[i] as string))
    {
        playerName = pn.nameList[i] as string;
    }
}

GUILayout.EndScrollView();
GUILayout.EndArea();
```