---
title: poj 3264 Balanced Lineup St算法建立Rmq
tags:
  - rmq
id: 303
categories:
  - 算法
  - 数据结构
date: 2012-10-25 18:30:00
---

ST算法可以说就是个二维的动态规划，黑书上有解释。
``` stylus
#include <stdio.h>
#include <string.h>
#include <algorithm>
#include <math.h>
using namespace std;

const int MAX_I = 50010;
const int MAX_J = 20;

int nMax[MAX_I][MAX_J];
int nMin[MAX_I][MAX_J];
int nArr[MAX_I];
int nN, nQ;

void InitRmq(int nN)
{
    for (int i = 1; i <= nN; ++i)
    {
        nMax[i][0] = nMin[i][0] = nArr[i];
    }

    for (int j = 1; (1 << j) <= nN; ++j)
    {
        for (int i = 1; i + (1 << j) - 1 <= nN; ++i)
        {
            nMax[i][j] = max(nMax[i][j - 1],
                             nMax[i + (1 << (j - 1))][j - 1]);
            nMin[i][j] = min(nMin[i][j - 1],
                             nMin[i + (1 << (j - 1))][j - 1]);                
        }
    }
}

int Query(int nA, int nB)
{
    int k = (int)(log(1.0 * nB - nA + 1) / log(2.0));
    int nBig = max(nMax[nA][k], nMax[nB - (1 << k) + 1][k]);
    int nSml = min(nMin[nA][k], nMin[nB - (1 << k) + 1][k]);
    return nBig - nSml;
}

int main()
{
    while (scanf("%d%d", &nN, &nQ) == 2)
    {
        for (int i = 1; i <= nN; ++i)
        {
            scanf("%d", &nArr[i]);
        }
        InitRmq(nN);
        for (int i = 0; i < nQ; ++i)
        {
            int nA, nB;
            scanf("%d%d", &nA, &nB);
            printf("%d\n", Query(nA, nB));
        }
    }

    return 0;
}
```