---
title: poj 2886 Who Gets the Most Candies? 约瑟夫环和反素数
id: 258
categories:
  - ACM-ICPC
date: 2012-09-14 10:00:00
tags:
  - 约瑟夫环
---

直接模拟约瑟夫环是N^2，况且这题每次移动的距离和方向都是不确定的，只能模拟，如果加快查找和移动的话，可以提高速度，果断用线段树维护当前位置前面有多少个人。
至于反素数指的是求一个小于等于N的数字，使得其因子个数在1-N中是最大的。这个利用一个必要条件暴力搜索即可。
<div>其实就是利用下面这2个性质搜索的。 性质一:一个反素数的质因子必然是从2开始连续的质数。性质二:p=2^t1*3^t2*5^t3*7^t4.....必然t1>=t2>=t3>=....。

代码如下：</div>
``` stylus
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <algorithm>
using namespace std;

int nPrime[16] = {2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53};
int nAns;
int nCN;
const int MAX_N = 500010;
//nPow不会超过20
void InitBest(int nCur, int nI, int nMax, int nN, int nNum)
{
    if (nCur > nN) return;
    if (nNum > nCN){nAns = nCur;nCN = nNum;}
    if (nNum == nCN){nAns = min(nAns, nCur);}
    for (int i = 1; i <= nMax; ++i)
    {
        nCur *= nPrime[nI];
        if (nCur > nN)return;//不加这句优化会超时
        if (nI < 15)
        InitBest(nCur, nI + 1, i, nN, nNum * (i + 1));
    }
}

char szNames[MAX_N][10];
int nValue[MAX_N];
int nTree[MAX_N << 2];
void PushUp(int nRt)
{
    nTree[nRt] = nTree[nRt << 1] + nTree[nRt << 1 | 1];
}

void BuildTree(int nL, int nR, int nRt, int nV)
{
    if (nL == nR)
    {
        nTree[nRt] = nV;
        return;
    }
    int nMid = (nL + nR) >> 1;
    BuildTree(nL, nMid, nRt << 1, nV);
    BuildTree(nMid + 1, nR, nRt << 1 | 1, nV);
    PushUp(nRt);
}

void Add(int nL, int nR, int nRt, int nP, int nV)
{
    if (nL == nR)
    {
        nTree[nRt] += nV;
    }
    else
    {
        int nMid = (nL + nR) >> 1;
        if (nP <= nMid)Add(nL, nMid, nRt << 1, nP, nV);
        else Add(nMid + 1, nR, nRt << 1 | 1, nP, nV);
        PushUp(nRt);
    }
}

int Query(int nL, int nR, int nRt, int nSum)
{
    if (nL == nR)
    {
        return nL;
    }
    int nMid = (nL + nR) >> 1;
    int nLs = nRt << 1;
    int nRs = nLs | 1;
    if (nTree[nLs] >= nSum) return Query(nL, nMid, nLs, nSum);
    else return Query(nMid + 1, nR, nRs, nSum - nTree[nLs]);
}

int main()
{
    //InitBest(1, 0, 15);
    int nN, nK;

    while (scanf("%d%d", &nN, &nK) == 2)
    {
        nK--;
        nAns = 2;
        nCN = 0;
        InitBest(1, 0, 20, nN, 1);
        //printf("ans:%d cn:%d\n", nAns, nCN);
        for (int i = 0; i < nN; ++i)
        {
            scanf("%s%d", szNames[i], nValue[i]);
        }

        BuildTree(0, nN - 1, 1, 1);
        int nTotal = nN;
        int nPos;
        for (int i = 0; i < nAns; ++i)
        {
            nPos = Query(0, nN - 1, 1, nK + 1);
            //printf("nK:%d %s %d\n", nK, szNames[nPos], nValue[nPos]);
            nTotal--;
            Add(0, nN - 1, 1, nPos, -1);
            if (!nTotal)break;
            if (nValue[nPos] >= 0)
            {
                nK = (nK - 1 + nValue[nPos] + nTotal) % nTotal;
            }
            else
            {
                nK = ((nK + nValue[nPos]) % nTotal + nTotal) % nTotal;
            }
        }
        printf("%s %d\n", szNames[nPos], nCN);
    }

    return 0;
}
```