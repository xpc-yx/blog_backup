---
title: poj 2551 Ones and poj 2262 Goldbach's Conjecture
tags:
  - 同余
  - 筛素数
id: 213
categories:
  - 数学
date: 2012-07-09 22:00:00
---

第一个题用到了同余的性质，这是数论里面最基本的性质，但是做题时候不一定能够自己发现。题意是n*m = 11111...，给出n，用一个m乘以n得到的答案全是1组成的数字，问1最小的个数是多少。可以转换为n*m=(k*10+1)，那么可以得到(k*10+1)%n==0。
当然最开始的k是1，那么我们不断的增长k = （10*k+1）。看增长多少次，就是有多少个1了。因为要避免溢出，所以需要不断%n。因为同余的性质，所以可以保证%n之后答案不变。
第二个用到素数筛选法。素数筛选法的原理是筛去素数的倍数，由于是从小循环到大的，所以当前的值没被筛掉的话，则一定是素数，这个判断导致复杂度不是n的平方。

poj 2551 代码：
``` stylus
#include <stdio.h>

int main()
{
    int nN;

    while (scanf("%d", &nN) == 1)
    {
        int nCnt = 1;
        int nTemp = 1;
        while (1)
        {
            if (nTemp % nN == 0)break;
            else nTemp = (nTemp * 10 + 1) % nN;
            ++nCnt;
        }
        printf("%d\n", nCnt);
    }

    return 0;
}
```
poj 2262 代码：
``` stylus
#include <stdio.h>
#include <string.h>
#include <math.h>

#define MAX (1000000 + 10)
bool bPrime[MAX];
void InitPrime()
{
    memset(bPrime, true, sizeof(bPrime));
    bPrime[0] = bPrime[1] = false;
    for (int i = 2; i <= MAX; ++i)
    {
        if (bPrime[i])
            for (int j = 2 * i; j <= MAX; j += i)
            {
                bPrime[j] = false;
            }
    }
}

int main()
{
    int nN;

    InitPrime();
    while (scanf("%d", &nN), nN)
    {
        int i;
        for (i = 2; i < nN; ++i)
        {
            if (i % 2 && (nN - i) % 2 && bPrime[i] && bPrime[nN - i])
            {
                printf("%d = %d + %d\n", nN, i, nN - i);
                break;
            }
        }
        if (i == nN)
        {
            printf("Goldbach's conjecture is wrong.\n");
        }
    }

    return 0;
}
```