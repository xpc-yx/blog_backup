---
title: uva 107 - The Cat in the Hat
tags:
  - 二分
  - 对数
id: 174
categories:
  - 数学
date: 2012-05-07 19:00:00
---

这是一个很神的数学题吧。基本上过这个题的很多都会wa10多次，而且这个题好像简单的枚举其中的一个指数值都能过，可能是数据量比较小。
但是，这个题还是有数学的解法的。但是，即使找到了这个正确的解法，过题的话，也是一件很困难的事情。题意大致如下：一只猫，高度为H，戴了一个帽子，帽子里面有N只猫（N是常数，且未知），同样帽子里面的猫也戴了帽子，但是这些猫的高度变成了H / (N + 1)，会向下取整。以此递归下去，直到最后的猫的高度都为1为止。现在，给出H和高度为1的猫的数量。要求的是高度大于1的猫的数量，以及所有猫的高度之和。
很别扭吧。通过上面的信息，得出2个式子。假设one代表为高度为1的猫的数量。one = N的n次。H >= (N + 1)的n次。注意第二个式子不一定取等号，因为很多时候都是不能整除的。现在要求N和n。2个方程解2个未知数，应该能解出来。但是，注意的是其中一个还是不等式。。。
指数关系很多时候会转换为对数的关系。所以，继续求对数，有lgH >= n * lg(N + 1)。其中，由第一个式子可以得到n = lg(one) / lg(N)。那么最终转换为：lgH >= (lg(one) / lgN) * lg(N + 1)。换个形式就是lgH / lg(One) >= lg(N + 1) / lgN。现在，已经很清晰了。因为，函数lg(N + 1) / lg(N) 是单调递减的。看到单调的函数，马上就会知道可以二分了。意思是，我们可以二分出一个N让lg(N + 1) / lgN 最接近lgH/lg(One)，而且是小于lgH / lg(One)的。剩下的工作就只是求和而已了。
写二分的时候，有一个地方可以注意一下。因为 lg(N + 1) / lgN 可能会出现除数为0的情况，所以可以进一步转换为lgH * lgN >=lg(N + 1) * lg(one)。 也是求一个N让上面那个不等式2边的值最接近，而且右边小于左边。能很快写对这个题真不是件容易的事情。。。
代码如下：
``` stylus
#include <stdio.h>
#include <math.h>

int main()
{
    int nInitH, nOnes;
    int nN, n;

    while (scanf("%d%d", &nInitH, &nOnes), nInitH + nOnes)
    {
        int nBeg = 1;
        int nEnd = nOnes;
        int nMid;

        while (nBeg <= nEnd)
        {
            nMid = (nBeg + nEnd) / 2;

            double fRes = log10(nInitH) * log10(nMid);
            double fTemp = log10(nMid + 1) * log10(nOnes);
            if (fabs(fRes - fTemp) < 1e-10)
            {
                //printf("Find nN:%d\n", nMid);
                nN = nMid;
                break;
            }
            else if (fTemp > fRes)
            {
                nBeg = nMid + 1;
            }
            else
            {
                nEnd = nMid - 1;
            }
        }

        n = floor(log10(nInitH) / log10(nN + 1) + 1e-9);
        //printf("nN:%d, n:%d\n", nN, n);

        int nSum = 0;
        int nLazy = 0;
        int nNum = 1;
        for (int i = 0; i <= n; ++i)
        {
            nSum += nNum * nInitH;
            nLazy += nNum;
            nNum *= nN;
            nInitH /= (nN + 1);
        }

        printf("%d %d\n", nLazy - nOnes, nSum);
    }

    return 0;
}
```