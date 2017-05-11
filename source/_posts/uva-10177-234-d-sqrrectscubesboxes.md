---
title: uva 10177 - (2/3/4)-D Sqr/Rects/Cubes/Boxes?
tags:
  - 不同矩形(体 超体)计数
id: 160
categories:
  - 算法
  - 数学
date: 2012-04-14 10:00:00
---

这是一道数学题吧。想清楚之后就发现就是求累加和。
问题是给定一个正方形(体,超体)，求其中的所有的正方形(体,超体),长方形(体,超体)。 比如，4 * 4的正方形中，有14个正方形，22个长方形，4 * 4 * 4的立方体中有36个正方体，180个长方体。依次类推，超正方体指的是四维空间。
观察一下一个4*4正方形中，仔细验证一下就会发现，正方形的个数是 Σ(4 - i + 1) * (4 - i + 1)(其中i从1到4)，长方形的个数是Σ(4 - i + 1) (其中j从1到4) * Σ(4 - j + 1)(其中j从1到4)。如果变成3维的就多一层k，k也从1变化到4。如果变成4维的就再多一层l，l也从1变化到4。
然后变换一下，就可以得到s2(n) = 1^1 + 2^2 + ... + n^n，s3(n)则是对立方的累加和，s4(n)则是对四次方的累加和。
再计算r2(n)。可以先把正方形包括在内计算出所有的和。那么r2(n) = Σ(n - i + 1) * Σ(n - j + 1) - s2(n)。如果直接进行这个式子的求和话很复杂。再观察一下这个式子，因为n - i + 1的变化范围就是1到n，那么上面的式子可以变化为 r2(n) = ΣΣi * j - s2(n)。意思是求i*j的和，i和j都是从1变化到n。很简单就可以得到r2(n) = pow(n * (n + 1) / 2, 2) - s2(n)。同样的求和可以得到，r3(n) = pow(n * (n + 1) / 2, 3) - s3(n)。r4(n) = pow(n * (n + 1) / 2, 4) - s4(n)。
另外如果不知道平方和，立方和，四次方和的公式，也可以迭代计算，复杂度也是O(100)。这样的话，根本不需要使用这些难记忆的公式了。

代码如下：

``` stylus
#include <stdio.h> 
#include <math.h>
unsigned long long s2[101];
unsigned long long r2[101];
unsigned long long s3[101];
unsigned long long r3[101];
unsigned long long s4[101];
unsigned long long r4[101];

int main()
{
    unsigned long long i = 0;
    while (i <= 100)
    {
        s2[i] = i * (i + 1) * (2 * i + 1) / 6;//平方和
        s3[i] = i * i * (i + 1) * (i + 1) / 4;//立方和
        s4[i] = i * (i + 1) * (6 * i * i * i + 9 * i * i + i - 1) / 30;//四次方和
        r2[i] = pow(i * (i + 1) / 2, 2) - s2[i];
        r3[i] = pow(i * (i + 1) / 2, 3) - s3[i];
        r4[i] = pow(i * (i + 1) / 2, 4) - s4[i];
        ++i;
    }

    int nN;
    while (scanf(";%d";, nN) != EOF)
    {
        //printf(";%I64u %I64u %I64u %I64u %I64u %I64u\n";, s2[nN], r2[nN], s3[nN], r3[nN], s4[nN], r4[nN]);
        printf(";%llu %llu %llu %llu %llu %llu\n";, s2[nN], r2[nN], s3[nN], r3[nN], s4[nN], r4[nN]);
    }

    return 0;
}
```