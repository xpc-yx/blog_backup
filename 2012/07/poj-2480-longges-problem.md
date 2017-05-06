---
title: poj 2480 Longge's problem
tags:
  - Σgcd(i n)(1<=i<=n)
id: 233
categories:
  - 数学
date: 2012-07-31 17:00:00
---

题意就是给出个数n，求<span>Σgcd(i,n)(1<=i<=n)。感觉好奇葩的题目，数论的题确实比较难想，没看出跟欧拉函数有什么关系。很纠结，没心情没时间继续想了。看了discussion，然后又去搜了下答案，发现有个哥们也得非常不错，就看了下思路了。
这个题的解法是枚举i(1<=i<=n)，如果i|n，那么答案加上euler(n/i)*i。其实ans = Σi*euler(n/i)(i<=i<=n而且i|n)。意思是从1到n的所有数字i，如果i是n的因子，那么计算i*euler(n/i)，加入答案中，euler是欧拉函数的意思。
为什么是这样的了。比如，1到n中有m个数字和n拥有公共的最大因子i，那么就需要把m*i加入答案中。问题是如何计算m的个数。因为gcd(m,n) = i，可以得到gcd(m/i,n/i)=1，那么m/i就是n/i的乘法群中的数字了，那么一共存在euler(n/i)个m/i了，那么就可以推出m的个数就是euler(n/i)。

代码如下:</span>
``` stylus
#include <stdio.h>
#include <math.h>
#define MAX (6000000)
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

bool IsPrime(long long nN)
{
    if (nN < MAX)return !bPrime[nN];
    long long nMax = sqrt((double)nN) + 1;
    for (int i = 2; i <= nMax; ++i)
    {
        if (nN % i == 0)
            return false;
    }
    return true;
}

long long Euler(long long nN)
{
    long long nAns = 1;

    //printf("nN:%I64d,", nN);
    if (IsPrime(nN))nAns = nN - 1;
    else
        for (int i = 2; i <= nN; ++i)
        {
            if (nN % i == 0)
            {
                nAns *= i - 1;
                nN /= i;
                while (nN % i == 0)
                {
                    nAns *= i;
                    nN /= i;
                }
                if (IsPrime(nN))
                {
                    nAns *= nN - 1;
                    break;
                }
            }
        }

    //printf("nAns:%I64d\n", nAns);
    return nAns;
}

int main()
{
    long long nN;

    InitPrime();
    while (scanf("%I64d", &nN) == 1)
    {
        long long nAns = 0;
        long long nMax = sqrt((double)nN) + 1e-8;
        for (long long i = 1; i <= nMax; ++i)
        {
            if (nN % i == 0)
            {
                //printf("i:%I64d\n", i);
                nAns += i * Euler(nN / i);
                if (i * i != nN)
                    nAns += (nN / i) * Euler(i);
            }
        }
        printf("%I64d\n", nAns);
    }

    return 0;
}
```