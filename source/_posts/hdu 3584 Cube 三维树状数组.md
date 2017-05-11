---
title: hdu 3584 Cube 三维树状数组
tags:
  - 三维树状数组
id: 254
categories:
  - 算法
  - 数据结构
date: 2012-09-10 11:30:00
---

这个题意思是翻转一个01立方体。翻转多次后再查询某个点的值。
还是利用上一篇文章的思想，把翻转操作转换为单点更新操作。把查询操作转换为利用树状数组查询和的方式。这样每次操作的复杂度都是logN的3次。而直接翻转立方体的复杂度是N的3次。
这个题最麻烦的地方是空间想象能力。因为要翻转8个点才能完成一次立方体翻转。比如，翻转(x,y,z)相当于以该点作为左上角做一个无限立方体，把该立方体翻转。这样就会翻转多余的部分，那么需要把多翻转的部分翻转回来。最后的思考结果发现，只要对每个顶点翻转一次即可。至于为什么这样，自己去计算重复翻转的部分就会明白了。刚好确实是把每个点翻转了一次。

代码如下：
``` stylus
#include <stdio.h>
#include <string.h>
#include <algorithm>
using namespace std;

const int MAX_N = 110;
int nSum[MAX_N + 10][MAX_N + 10][MAX_N + 10];
int nN, nM;

int LowBit(int nPos)
{
    return nPos & (-nPos);
}

void Add(int nX, int nY, int nZ)
{
    for (int i = nX; i <= nN; i += LowBit(i))
    {
        for (int j = nY; j <= nN; j += LowBit(j))
        {
            for (int k = nZ; k <= nN; k += LowBit(k))
            {
                nSum[i][j][k]++;
            }
        }
    }
}

int Query(int nX, int nY, int nZ)
{
    int nAns = 0;

    for (int i = nX; i > 0; i -= LowBit(i))
    {
        for (int j = nY; j > 0; j -= LowBit(j))
        {
            for (int k = nZ; k > 0; k -= LowBit(k))
            {
                nAns += nSum[i][j][k];
            }
        }
    }
    return nAns;
}

int main()
{
    int nCmd;
    int nX, nY, nZ;
    int nX1, nY1, nZ1;
    int nX2, nY2, nZ2;

    while (scanf("%d%d", &nN, &nM) == 2)
    {
        memset(nSum, 0, sizeof(nSum));
        while (nM--)
        {
            scanf("%d", &nCmd);
            if (nCmd == 0)
            {
                scanf("%d%d%d", &nX, &nY, &nZ);
                printf("%d\n", Query(nX, nY, nZ) % 2);
            }
            else
            {
                scanf("%d%d%d%d%d%d", &nX1, &nY1, &nZ1, &nX2, &nY2, &nZ2);
                if (nX1 > nX2)swap(nX1, nX2);
                if (nY1 > nY2)swap(nY1, nY2);
                if (nZ1 > nZ2)swap(nZ1, nZ2);
                Add(nX1, nY1, nZ1);

                Add(nX2 + 1, nY1, nZ1);
                Add(nX1, nY2 + 1, nZ1);
                Add(nX1, nY1, nZ2 + 1);

                Add(nX1, nY2 + 1, nZ2 + 1);
                Add(nX2 + 1, nY1, nZ2 + 1);
                Add(nX2 + 1, nY2 + 1, nZ1);

                Add(nX2 + 1, nY2 + 1, nZ2 + 1);
            }
        }
    }

    return 0;
}
```