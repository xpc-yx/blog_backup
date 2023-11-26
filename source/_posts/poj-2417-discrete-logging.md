---
title: poj 2417 Discrete Logging
tags:
  - 数论
id: 229
categories:
  - 算法 
  - 算法题
date: 2012-07-22 13:30:00
---

这是个求离散对数的问题。以前学密码学基础的时候也接触过，但是没想到acm里面还会有这样的习题。问题的意思是给定素数P，给出方程a^x = b % p，注意有模的方程等式2边都是取模数的意思。解这样的方程有一个固定的算法，叫做baby-step算法。但是，注意限定条件是p必须是素数。
下面的图描述了这个算法：
![](https://c5.staticflickr.com/8/7132/27134956060_0a46748ab7_o.jpg)
![](https://c1.staticflickr.com/8/7278/26802327624_ce592b5e96_o.jpg)
意思很清楚，就是假设x = i * m + j，那么方程可以转化为b*(a^-m)^i  = a^j % p。先计算出右边的值，存储在一张表里面，然后从小到大枚举左边的i（0<=i<m)，率先满足等式的就是最小的解x。
poj上面这个题用map存储(a^j,j)对的时候会超时，改成hash表存储才能过，额，毕竟理论复杂度不是一个数量级的。我的hash表是开了2个数组，一个键，一个值，用来相互验证，槽冲突的话，一直往后找位置。感觉这样的做法没有链式hash复杂度平均的样子。
代码如下：

``` stylus
#include <stdio.h>
#include <math.h>
#include <algorithm>
using namespace std;

#define MAX (1000000)
long long nData[MAX];
long long nKey[MAX];
long long egcd(long long a, long long b, long long x, long long y)
{
    if (b == 0)
    {
        x = 1;
        y = 0;
        return a;
    }
    long long ret = egcd(b, a % b, x, y);
    long long t = x;
    x = y;
    y = t - (a / b) * y;
    return ret;
}

long long GetPos(long long key)
{
    return (key ^ 0xA5A5A5A5) % MAX;
}

void Add(long long key, long long data)
{
    long long nPos = GetPos(key);
    while (nData[nPos] != -1)
    {
        nPos = (nPos + 1) % MAX;
    }
    nData[nPos] = data;
    nKey[nPos] = key;
}

int Query(int key)
{
    int nPos = GetPos(key);

    while (nData[nPos] != -1)
    {
        if (nKey[nPos] == key)
        {
            return nData[nPos];
        }
        nPos = (nPos + 1) % MAX;
    }
    return -1;
}

long long BabyStep(long long nA, long long nB, long long nP)
{
    long long nM = ceil(sqrt((double)(nP - 1)));
    long long x, y;
    egcd(nP, nA, x, y);//y是nA%p的乘法逆
    y = (y + nP) % nP;
    long long nTemp = 1;
    long long c = 1;//c是nA的—m次
    memset(nData, -1, sizeof(nData));
    memset(nKey, -1, sizeof(nKey));
    for (long long j = 0; j < nM; ++j)
    {
        Add(nTemp, j);
        nTemp = (nTemp * nA) % nP;
        c = (c * y) % nP;
    }

    long long r = nB;
    for (int i = 0; i < nM; ++i)
    {
        long long j = Query(r);
        if (j != -1)
        {
            return i * nM + j;
        }
        r = (r * c) % nP;
    }
    return -1;
}

int main()
{
    long long nP, nB, nN;

    while (scanf("%I64d%I64d%I64d", &nP, &nB, &nN) == 3)
    {
        long long nAns = BabyStep(nB, nN, nP);
        if (nAns == -1)printf("no solution\n");
        else printf("%I64d\n", nAns);
    }

    return 0;
}
```