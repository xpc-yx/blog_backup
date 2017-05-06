---
title: poj 3468 A Simple Problem with Integers 线段树成段延迟更新
tags:
  - 树状数组
id: 260
categories:
  - 数据结构
date: 2012-09-16 11:00:00
---

用线段树成段更新不能立即全部更新，必须搞延迟操作。其实，就是针对每个节点，另外搞一个域表示延迟
更新的数目。然后，在更新操作和查找操作的时候都把父亲节点的延迟域往2个儿子走。
这个题是要成段增加值，所以在写PushDown函数的时候要注意，只能给儿子节点加上父亲节点压过来的值乘以儿子区间的长度。这题貌似用树状数组也可以做，不过解法肯定意思不是那么直白的。不过速度肯定会快。
树状数组解法：[http://kenby.iteye.com/blog/962159](http://kenby.iteye.com/blog/962159)
线段树网上流行的解法都是开最多节点数目4倍的数组。以位置1作为根，每个位置其实代表的是一个区间。某人位置1代表1-N或者0-(N-1)区间，具体看题目了。那么2就代表区间1-(1+N)/2，3就代表区间(1+N)/2+1 - N了。
至于lazy标记还是搞个大数组，意义和线段树数组一样，搞清楚之后写起来都比较简单，最重要的是变形来解决一些要求奇怪的题目。

``` stylus
#include <stdio.h>
#include <string.h>
#include <algorithm>
using namespace std;
typedef long long INT;

const INT MAX_N = 100010;
const INT INF = 0x7ffffffffffffffLL;
INT nTree[MAX_N << 2];
INT nAdd[MAX_N << 2];
INT nN, nQ;

void PushUp(INT nRt)
{
    nTree[nRt] = nTree[nRt << 1] + nTree[nRt << 1 | 1];
}

void BuildTree(INT nL, INT nR, INT nRt)
{
    nAdd[nRt] = 0;
    if (nL == nR)
    {
        scanf("%I64d", nTree[nRt]);
        return;
    }

    INT nMid = (nL + nR) >> 1;
    BuildTree(nL, nMid, nRt << 1);
    BuildTree(nMid + 1, nR, nRt << 1 | 1);
    PushUp(nRt);
}

void PushDown(INT nL, INT nR, INT nRt)
{
    INT nMid = (nL + nR) >> 1;
    INT nLs = nRt << 1;
    INT nRs = nLs | 1;

    if (nAdd[nRt])
    {
        nAdd[nLs] += nAdd[nRt];
        nAdd[nRs] += nAdd[nRt];
        nTree[nLs] += (nMid - nL + 1) * nAdd[nRt];
        nTree[nRs] += (nR - nMid) * nAdd[nRt];
        nAdd[nRt] = 0;
    }
}

void Update(INT nL, INT nR, INT nRt, INT nX, INT nY, INT nV)
{
    if (nL >= nX && nR <= nY)
    {
        nTree[nRt] += nV * (nR - nL + 1);
        nAdd[nRt] += nV;
        return;
    }

    PushDown(nL, nR, nRt);
    INT nMid = (nL + nR) >> 1;
    if (nX <= nMid) Update(nL, nMid, nRt << 1, nX, nY, nV);
    if (nY > nMid) Update(nMid + 1, nR, nRt << 1 | 1, nX, nY, nV);
    PushUp(nRt);
}

INT Query(INT nL, INT nR, INT nRt, INT nX, INT nY)
{
    if (nL >= nX && nR <= nY)
    {
        return nTree[nRt];
    }
    PushDown(nL, nR, nRt);
    INT nAns = 0;
    INT nMid = (nL + nR) >> 1;
    if (nX <= nMid) nAns += Query(nL, nMid, nRt << 1, nX, nY);
    if (nY > nMid) nAns += Query(nMid + 1, nR, nRt << 1 | 1, nX, nY);
    return nAns;
}

int main()
{
    INT nTemp;
    while (scanf("%I64d%I64d", &nN, &nQ) == 2)
    {
        BuildTree(1, nN, 1);

        while (nQ--)
        {
            char szCmd[10];
            INT nX, nY, nV;
            scanf("%s", szCmd);
            if (szCmd[0] == 'Q')
            {
                scanf("%I64d%I64d", &nX, &nY);
                printf("%I64d\n", Query(1, nN, 1, nX, nY));
            }
            else
            {
                scanf("%I64d%I64d%I64d", &nX, &nY, &nV);
                Update(1, nN, 1, nX, nY, nV);
            }
        }
    }

    return 0;
}
```