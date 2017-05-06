---
title: hdu 1556 Color the ball 树状数组
tags:
  - 树状数组
id: 252
categories:
  - 数据结构
date: 2012-09-06 12:00:00
---

这个题的意思是给定一个长为N的区间。不断的给某个子区间[A,B]中的每个点涂一次色。最后问每个点的涂色次数。
这个题貌似可以扩展到多维的情况，但是多维的情况下必须用树状数组求和以加快速度，一维的情况直接求和即可。
假如，第一次涂色是对区间[A,B]涂色一次，可以让nNum[nA]++,nNum[nB+1]--即可。因为这样对于区间[0,nA-1]的任意值i有都要nNum[1]+nNum[2]+...+nNum[i] = 0。而对于区间[nA,nB]的任意值i有nNum[1]+nNum[2]+...+nNum[i] = 0。对于区间[nB+1, nN]的任意值i有nNum[1]+nNum[2]+...+nNum[i] = 0。那么重复多次了。如果上述求和nNum[1]+nNum[2]+...+nNum[i] 刚好代表每个结点i的涂色次数，那么这个题就可解了。
用例子验证一下，发现肯定是这样的。证明略了。至于树状数组网上一大堆资料。树状数组模板单一，敲代码太方便了。

代码如下：
``` stylus
#include <stdio.h>
#include <string.h>
#include <algorithm>
using namespace std;

int nNum[100000 + 10];
int nN;
int LowBit(int nI)
{
    return nI & (-nI);
}

void Add(int nI, int nAdd)
{
    while (nI <= nN)
    {
        nNum[nI] += nAdd;
        nI += LowBit(nI);
    }
}

int GetSum(int nI)
{
    int nAns = 0;

    while (nI > 0)
    {
        nAns += nNum[nI];
        nI -= LowBit(nI);
    }
    return nAns;
}

int main()
{
    int nA, nB;

    while (scanf("%d", &nN), nN)
    {
        memset(nNum, 0, sizeof(nNum));

        for (int i = 1; i <= nN; ++i)
        {
            scanf("%d%d", nA, nB);
            Add(nA, 1);
            Add(nB + 1, -1);
        }
        for (int i = 1; i <= nN; ++i)
        {
            printf("%d%s", GetSum(i), i == nN ? "\n" : " ");
        }
    }

    return 0;
}
```