---
title: uva 10392 - Factoring Large Numbers
tags:
  - 枚举
id: 235
categories:
  - 数学
date: 2012-08-01 19:30:00
---

此题的意思是分解大数字，数字的范围是Longlong级别的，好像不能暴力的样子。但是，题目给出了个条件，最多只有一个因子的大小超过1000000。哈哈，这就是暴点啊。既然，如此直接枚举1000000以内的因子就行了，剩余的部分如果大于10的6次肯定是N的因子了，就不用暴力了。如果小于10的6次肯定是1啦，因为2-1000000的因子都被处理了啊。
这样这个题就不会超时了。确实，暴力是需要技巧的。还要注意uva上要用%lld输入。

``` stylus
#include <stdio.h>
#include <math.h>
typedef long long LL;
#define MAX (6000000)
bool bPrime[MAX];
int nPrime[MAX];
int nNum;

void InitPrime()
{
    LL nMax = sqrt(MAX) + 1;
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
    for (int i = 2; i < MAX; ++i)
    {
        if (!bPrime[i])
            nPrime[nNum++] = i;
    }

}

bool IsPrime(LL nN)
{
    if (nN < MAX) return !bPrime[nN];
    LL nMax = sqrt((double)nN) + 1;
    for (LL j = 0, i = nPrime[j]; i <= nMax; ++j, i = nPrime[j])
    {
        if (nN % i == 0)
        {
            return false;
        }
    }
    return true;
}

int main()
{
    LL nN;

    InitPrime();
    while (scanf("%lld", &nN), nN >= 0)
    {
        if (nN <= 2)
        {
            printf("%-lld\n\n", nN);
            continue;
        }

        int nMax = sqrt((double)nN)+ 1;
        for (LL i = 2; i <= 1000000  i <= nMax; ++i)
        {
            while (nN % i == 0)
            {
                printf("    %-lld\n", i);
                nN /= i;
            }
            if (nN < 6000000  IsPrime(nN))
            {
                break;
            }
        }
        if (nN != 1)
            printf("    %-lld\n", nN);
        printf("\n");
    }

    return 0;
}
```