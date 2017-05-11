---
title: poj 3093 Margaritas on the River Walk
tags:
  - 背包问题变形
id: 246
categories:
  - 算法
  - 动态规划
date: 2012-08-30 22:30:00
---

这是一个动态规划题，据说是背包问题的变形。我动态规划做得很少，解法一直按照算法导论的思想分解重叠子问题。
题意是用钱尽可能多的买物品，每种物品买一个，问有多少种买法。
我也想不出这是什么背包问题的变形，没做过几个背包问题，也没看过背包九讲。还是坚持认为正确的用状态描述成子问题就一定能解题的。今天和队友在做专题时候做到这个题，我一直做了一上午都没出来。
后面发现了个性质就可以直接转换为类似最简单的背包问题了。排序物品价值，从最大物品开始分解子问题，用剩余物品数和钱描述问题的状态。**当前物品是否必须取，是根据当前的钱把剩下的物品全买了之后剩下的钱还是否大于当前物品的价值，如果大于就必须买，否则可以买或者不买。**
**为了正确描述问题的状态，必须事先排序价值数组，因为排序之后可以保证不能买当前物品的时候一定不能买前面的物品，那么我们对前面物品的处理就是正确的了。**至此可以进行最简单的子问题分解了。到最后物品处理完之后（物品数为0），如果钱一点都没减少，那么(0, M) = 0，否则(0, M) = 1。注意这个边界处理，否则会wa。所以，需要先对价值数组排序，并计算出表示前N个物品价值和的数组。
做不出来的时候，翻了下别人的解法，一头雾水。看来还是算法导论的思想指导意义大多了。。。

代码如下：
``` stylus
#include <stdio.h> 
#include <string.h>
#include <algorithm>
using namespace std;
typedef long long INT;
INT nAns[40][1010];
INT nValue[100];
INT nSum[100];
INT nN, nM;

INT GetAns(INT nNum, INT nMoney)
{
    if (nAns[nNum][nMoney] == -1)
    {
        if (nNum == 0)
        {
            nAns[nNum][nMoney] = 1;
            if (nMoney == nM)
            {
                nAns[nNum][nMoney] = 0;
            }
        }
        else
        {
            INT nRet = 0;

            if (nMoney - nSum[nNum - 1] >= nValue[nNum])
            {
                nRet = GetAns(nNum - 1, nMoney - nValue[nNum]);
            }
            else
            {
                if (nMoney >= nValue[nNum])
                {
                    nRet += GetAns(nNum - 1, nMoney - nValue[nNum]);
                }
                nRet += GetAns(nNum - 1, nMoney);
            }

            nAns[nNum][nMoney] = nRet;
        }
    }
    return nAns[nNum][nMoney];
}

int main()
{
    INT nT;

    scanf("%I64d", &nT);
    for (INT i = 1; i <= nT; ++i)
    {
        scanf("%I64d%I64d", &nN, &nM);
        for (INT j = 1; j <= nN; ++j)
        {
            scanf("%I64d", nValue[j]);
        }
        memset(nAns, -1, sizeof(nAns));
        sort(nValue + 1, nValue + nN + 1);
        nSum[0] = 0;
        for (INT j = 1; j <= nN; ++j)
        {
            nSum[j] = nSum[j - 1] + nValue[j];
        }
        printf("%I64d %I64d\n", i, GetAns(nN, nM));
    }

    return 0;
}
```