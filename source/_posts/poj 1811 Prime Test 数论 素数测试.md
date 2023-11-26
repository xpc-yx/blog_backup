---
title: poj 1811 Prime Test 数论 素数测试
tags:
  - 数论
id: 264
categories:
  - 算法
  - 算法题
date: 2012-09-24 10:30:00
---

代码如下：
``` stylus
#include <stdio.h>
#include <time.h>
#include <math.h>
#include <stdlib.h>
#include <algorithm>
using namespace std;
typedef unsigned long long LL;
#define MAX (5000000)
bool bPrime[MAX];
void InitPrime()
{
    int nMax = sqrt((double)MAX) + 1;
    bPrime[0] = bPrime[1] = true;
    for (int i = 2; i <= nMax; ++i)
    {
        if (!bPrime[i])
        {
            for (int j = 2 * i; j < MAX; j += i)
            {
                bPrime[j] = true;
            }
        }
    }
}
LL multAndMod(LL a, LL b, LL n)
{
    LL tmp = 0;
    while (b)
    {
        if(b & 1)
        {
            tmp = (tmp + a) % n;
        }
        a = (a << 1) % n;
        b >>= 1;
    }
    return tmp;
}
//计算a^u%n
LL ModExp(LL a, LL u, LL n)
{
    LL d = 1;
    a %= n;
    while (u)
    {
        if (u & 1)
        {
            d = multAndMod(d, a, n);
        }
        a = multAndMod(a, a, n);
        u >>= 1;
    }
    return d % n;
}
//判断nN是不是合数
bool Witness(LL a, LL nN)
{
    LL u = nN - 1, t = 0;//将nN-1表示为u*2^t
    while (u % 2 == 0)
    {
        t++;
        u >>= 1;
    }
    LL x0 = ModExp(a, u, nN);//x是a^u
    LL x1;
    for (int i = 1; i <= t; ++i)
    {
        x1 = multAndMod(x0, x0, nN);
        if (x1 == 1 && x0 != nN - 1 && x0 != 1)
        {
            return true;
        }
        x0 = x1;
    }
    if (x1 != 1)
    {
        return true;
    }
    return false;
}
//素数测试
bool MillerRabin(LL nN)
{
    //if (nN < MAX)return !bPrime[nN];
    const int TIME = 10;
    for (int i = 0; i < TIME; ++i)
    {
        LL a = rand() % (nN - 1) + 1;
        if (Witness(a, nN))
        {
            return false;
        }
    }
    return true;
}
LL gcd(LL a, LL b)
{
    if (a < b)swap(a, b);
    while (b)
    {
        LL t = a;
        a = b;
        b = t % b;
    }
    return a;
}
//启发式寻找nN的因子
LL PollardRho(LL n, LL c)
{
    LL i = 1, t = 2;
    LL x, y;
    LL ans;
    srand(time(NULL));  
    y = x = rand() % n;
    while(1)
    {
        i++;
        x = (multAndMod(x, x, n) + c) % n;
        ans = gcd(y - x, n);
        if(ans > 1 && ans < n)
            return ans;
        if(x == y)
            return n;
        if(t == i)
        {
            y = x;
            t <<= 1;
        }
    }
}
LL FindMin(LL nN, LL c)
{
    //printf("nN:%I64u\n", nN);
    if (MillerRabin(nN) || nN <= 1)
    {
        return nN;
    }
    LL p = nN;
    while (p >= nN) p = PollardRho(p, c--);
    if (p > 1)
        p = FindMin(p, c);//分解p的最小因子
    if (p < nN)
    {
        LL q = nN / p;
        q = FindMin(q, c);//找到q的最小因子
        p = min(p, q);
    }
    return p;
}
int main()
{
    int nTest;
    srand(time(NULL));
    //InitPrime();
    scanf("%d", &nTest);
    while (nTest--)
    {
        LL nN;
        scanf("%I64u", &nN);
        if (nN > 2 && nN % 2 == 0)
        {
            printf("2\n");
        }
        else if (nN == 2 || MillerRabin(nN))
        {
            printf("Prime\n");
        }
        else
        {
            printf("%I64u\n", FindMin(nN, 181));
        }
    }
    return 0;
}
```