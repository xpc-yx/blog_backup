---
title: uva 10025 - The ? 1 ? 2 ? ... ? n = k problem
tags:
  - 二分
  - 数学
id: 170
categories:
  - 算法
  - 数学
date: 2012-05-04 13:30:00
---

这也算一个数学类的杂题吧。题目本身比较有意思，解题的思路很需要猜想。题目的意思用+和-去替代式子(? 1 ? 2 ? ... ? n = k)中的？号，对于指定的K，求最小的n。For example: to obtain k = 12 , - 1 + 2 + 3 + 4 + 5 + 6 - 7 = 12 with n = 7。
这个题，我的思路大致如下。首先，K可能是正的也是负的，而且显然负的情况，有相应的正对应情况。那么考虑所有k为正的情况。由于k一定小于等于n*(n+1)/2的，所以可以先求出这样的最小n。这个可以二分搜索，或者直接用解不等式方程(不过这种方法一直wa了)。
然后就剩下的是第二点了，假设a + b = n*(n+1)/2, a - b = k。可以得到 n*(n+1)/2 - k = 2 * b。意思是，必须满足 n*(n+1)/2和k的差为偶数。假如满足了，这样的n是不是一定OK了？？？
答案是肯定的，这一点就是需要猜想的地方了。因为，仔细观察下，1到n的数字可以组合出任意的1到 n*(n+1)/4之间的数字，这个数字即是b。至于证明，可以用数学归纳法从n==1开始证明了。。。至此已经很简单了。
由于求n存在2种不同的方法，而且我开始用解一元二次不等式的方法求的N，出现了浮点误差，一直WA了。后面改成二分才过了。。。

代码如下：
``` stylus
#include <stdio.h> 
#include <math.h>

int GetN(int nK)
{
    int nBeg = 1;
    int nEnd = sqrt(nK * 2) + 2;

    while (nBeg <= nEnd)
    {
        int nMid = (nBeg + nEnd) / 2;
        int nTemp = (nMid * nMid + nMid) / 2;
        if (nTemp >= nK)
        {
            nEnd = nMid - 1;
        }
        else
        {
            nBeg = nMid + 1;
        }
    }

    return nEnd + 1;
}

int main()
{
    int nK;
    int nTest;

    scanf("%d", &nTest);
    while (nTest--)
    {
        scanf("%d", &nK);
        if (nK < 0)
        {
            nK *= -1;
        }
        //int nN = ceil(sqrt(2 * fabs(1.0 * nK) + 0.25) - 0.5 + 1e-9);
        //上面那种方法存在浮点误差,wa了三次
        int nN = GetN(nK);

        while (1)
        {
            if (((nN * nN + nN) / 2 - nK) % 2 == 0)
            {
                printf("%d\n", nN);
                break;
            }
            ++nN;
        }
        if (nTest)
        {
            printf("\n");
        }
    }

    return 0;
}
```