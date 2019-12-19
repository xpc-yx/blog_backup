---
title: poj 2115 C Looooops 线性同余方程
tags:
  - 数论
id: 225
categories:
  - ACM-ICPC
date: 2012-07-18 10:00:00
---

这个题目就是解线性同余方程，(a + n*c) % 2的k次 = b % 2的k次。既然以前是学信安的，对数论本来就不排斥，最近还好好看了下算法导论。这个方程转换为n*c = (b-a) % 2的k次。根据数论的知识，  ax = b%n，需要保证gcd(a,n)|b，意思b是gcd(a,n)的倍数，这个一下子也很难解释清楚啊，不满足这个条件，就是没解了。还有，如果有解的话，解的个数就是d = gcd(a,n)。而且其中一个解是x0 = x'(b/ d)，其中x'是用扩展欧几里德算法求出来的，满足关系式a*x'+n*y'=d。
但是这个题不仅仅用到数论的这些知识，因为必须求满足条件的最小解，而如果有解的话是d个，而且满足解x = x0 + i(b/d)，（1<=i<=d)。既然要求最小的解，那么对解mod(n/d)即可了，因为它们之间的差都是n/d的倍数。

代码如下：
``` stylus
#include <stdio.h>
#include <math.h>
#include <algorithm>
using namespace std;

//扩展欧几里德算法
//d = a * x + b * y，d是a和b的最大公约数
long long egcd(long long a, long long b, long long x, long long y)
{
    if (b == 0)
    {
        x = 1;
        y = 0;
        return a;
    }
    else
    {
        long long nRet = egcd(b, a % b, x, y);
        long long t = x;
        x = y;
        y = t - (a / b) * y;
        return nRet;
    }
}

int main()
{
    long long nA, nB, nC, nK;

    while (scanf("%I64d%I64d%I64d%I64d", &nA, &nB, &nC, &nK),
            nA || nB || nC || nK)
    {
        long long x, y;
        long long n = pow((double)2, (double)nK) + 1e-8;
        long long d = egcd(n, nC, x, y);
        long long b = (nB - nA + n) % n;
        if (b % d)//如果d | b失败
        {
            printf("FOREVER\n");
        }
        else
        {
            //printf("y:%I64d, b:%I64d, d:%I64d n:%I64d\n", y, b, d, n);
            y = (y + n) % n;
            long long ans = (y * (b / d)) % (n / d);
            printf("%I64d\n", ans);
        }
    }

    return 0;
}
```