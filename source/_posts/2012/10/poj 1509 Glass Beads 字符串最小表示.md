---
title: poj 1509 Glass Beads 字符串最小表示
tags:
  - 字符串最小表示
id: 291
categories:
  - 字符串
date: 2012-10-19 11:00:00
---

赤裸裸的字符串最小表示题。所谓字符串最小表示指的是给定一个字符串，假设其可以循环移位，问循环左移多少位能够得到最小的字符串。
算法即是周源的最小表示法，搜索可以找到相关论文和ppt。
该算法其实也不是太复杂，思路可以这样理解。假设原字符串为s，设s1 = s + s; s2 = s1循环左移1位;现在处理s1和s2，实际写程序的时候可以通过下标偏移和取模得到s1和s2，而并不需要生成。
处理过程是这样的，设i和j分别指向s1和s2的开头。我们的目的是找到这样的i和j，假设k是s的长度，满足条件s1[i,i+k-1] = s2[j,j+k-1] 并且s1[i,i+k-1] 是所有满足条件的字符串中最小的字符串，如果有多个这样的s1[i,i+k-1] 那么我们希望i最小。
其实这个算法主要是做了一个优化，从而把时间搞成线性的。比如，对于当前的i和j，我们一直进行匹配，也就是s1[i,i+k] = s2[j,j+k] 一直满足，突然到了一个位置s1[i+k] != s2[j+k]了，现在我们需要改变i和j了。但是，我们不能只是++i或者++j。而是根据s1[i+k]>s2[j+k]的话i =i + k + 1，否则j = j + k + 1。这样的瞬移i或者j就能够保证复杂度是线性的了。
问题是如何证明可以这样的瞬移。其实，说穿了也很简单。因为s1[i,i+k - 1] = s2[j,j+k -1]是满足的，只是到了s1[i+k]和s2[j+k]才出现问题了。假如s1[i+k]>s2[j+k]，那么我们改变i为区间[i+1,i+k]中任何一个值m都不可能得到我们想要的答案，这是因为我们总可以在s2中找到相应的比s1[m,m+k-1]小的字符串s2[j+m-i,j+m-i+k-1]，因为有s1[i+k]>s2[j+k]。同样对于s1[i+k]<s2[j+k]的情况。
文字可能描述的不是很清楚。看PPT能够根据图进行分析。

代码如下：
``` stylus
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <algorithm>
#include <string>
#include <iostream>
using namespace std;

int GetMin(string str)
{
    int nSize = str.size();
    int i = 0, j = 1, k = 0;

    while (i < nSize && j < nSize && k < nSize)
    {
        char chDif = str[(i + k) % nSize]
                     - str[(j + k) % nSize];
        if (!chDif) ++k;
        else
        {
            if (chDif > 0) i = i + k + 1;
            else j = j + k + 1;
            if (i == j) ++j;
            k = 0;
        }
    }
    return min(i, j);
}

int main()
{
    string str;
    int nN;

    scanf("%d", &nN);
    while (nN--)
    {
        cin >> str;
        printf("%d\n", GetMin(str) + 1);
    }

    return 0;
}
```