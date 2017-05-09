---
title: poj 2407 Relatives 欧拉函数
tags:
  - 数论
  - 欧拉函数
id: 221
categories:
  - 数学
date: 2012-07-15 19:00:00
---

这个题一看就知道是求欧拉函数。欧拉函数描述的正式题意。欧拉函数的理解可以按照算法导论上面的说法，对0-N-1进行筛选素数。那么公式n∏(1-1/p)，其中p是n的素数因子，就可以得到直观的理解了。但是计算的时候，会将这个式子变形下，得到另外一个形式。
如图所示：
![](https://c7.staticflickr.com/8/7391/27312399622_2da18641db_o.jpg)
但是这个题，需要考虑下，有可能n是个大素数，直接进行因子分解的话会超时的。怎么办了，只能在分解的时候判断n是不是已经成为素数了，如果是素数，答案再乘以n-1就行了。为了加快判断，我用5mb的空间搞了个素数表，大于5000000的数字只能循环判断了。

代码如下，注意求欧拉函数的代码部分：

``` stylus
#include <stdio.h>
#include <math.h>
#define MAX (5000000)
bool bPrime[MAX];//false表示素数

void InitPrime()
{
    bPrime[0] = bPrime[1] = true;
    int nMax = sqrt((double)MAX) + 1;
    for (int i = 2; i <= nMax; ++i)
    {
        if (!bPrime[i])
            for (int j = i * 2; j < MAX; j += i)
            {
                bPrime[j] = true;
            }
    }
}

bool IsPrime(int nN)
{
    if (nN < MAX)
    {
        return !bPrime[nN];
    }
    else
    {
        int nMax = sqrt((double)nN) + 1;
        for (int i = 2; i <= nMax; ++i)
        {
            if (nN % i == 0)
            {
                return false;
            }
        }
        return true;
    }
}

int main()
{
    int nN;

    InitPrime();
    while (scanf("%d", &nN), nN)
    {
        if (nN == 1)
        {
            printf("0\n");
            continue;
        }
        int nAns = 1;
        for (int i = 2; i <= nN; ++i)
        {
            if (IsPrime(nN))
            {
                nAns *= nN - 1;
                break;
            }
            if (nN % i == 0)
            {
                nAns *= i - 1;
                nN /= i;
                while (nN % i == 0)
                {
                    nAns *= i;
                    nN /= i;
                }
            }
        }
        printf("%d\n", nAns);
    }

    return 0;
}
```