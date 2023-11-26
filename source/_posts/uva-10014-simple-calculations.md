---
title: uva 10014 - Simple calculations
tags:
  - 数学
id: 167
categories:
  - 算法
  - 算法题
date: 2012-05-03 12:00:00
---

说实话，这个题不是我亲自推算出来。一直想到崩溃了，明知道只差一步，硬是无法想出来。实在想不出了，看了下别人解题报告上的解释。真的很惭愧很崩溃。。。这就是一个数列推理的题目吧。
给出一个数列ci（1<=ci<=n)，然后给出数列ai中的a0和a(n+1)。并给出一个公式ai = ( a(i-1) + a(i+1) )  /  2 - ci。题目的意思是让求a1。
大家在很久以前的高中时代一定做过很多的数列题，所以我一看到这个题还是感觉很亲切的。然后就开始推算。我把上面那个公式，从i==1到i==n，全部累加起来。消去2边一样的项，得到一个结果**a1 + an = a0 + a(n+1) - 2Σci(1<=i<=n)**。从这个公式，我只能得到a1和an 的和。想来想去都无法直接求出a1的值。但是，我也知道如果能求出a1，那么ai中的任何其它项都是能求出来的。我猜想a1和an相等，提交当然wa了。然后，我猜想ai是a0和a(n+1)的i分点，提交还是wa了。后面这个猜想倒是合理点，但是还是有不严谨的地方，因为那样，a1的值之和a0，a(n+1)，c1这三个值有关系了。
这个题其实以前我想了一下，没想出来。然后今天重新想的时候可能受以前的影响，限制了一个思路。那就是，再对式子a1 + an =a0 + a(n+1) - 2 Σci(1<=i<=n)进行累加。其实，也有a1 + a(n-1) = a0 + an - 2 Σci(1<=i<=n-1)。这样累加n次，刚好可以把a2-an全部消去。可以得到，一个式子 **(n+1)a1 = n * a0 + a(n+1)- 2  ΣΣ cj(1<=j<=i) (1<=i<=n)**。那么就可以直接求出a1了。
公式：![](http://www.cppblog.com/images/cppblog_com/csu-yx/mathtex.gif)</span>

代码如下：
``` stylus
#include <stdio.h>
#include <string.h>

int main()
{
    int nCases;
    int nN;
    double a0, an1;
    double a1;
    double ci[3000 + 10];
    double c;
    double sum;

    scanf("%d", &nCases);

    while (nCases--)
    {
        scanf("%d", &nN);
        scanf("%lf%lf", &a0, &an1);

        sum = 0.0;
        memset(ci, 0, sizeof(ci));
        for (int j = 1; j <= nN; ++j)
        {
            scanf("%lf", c);
            ci[j] = ci[j - 1] + c;//ci[j]代表数列ci中第1-j项的和
            sum += ci[j];
        }

        a1 = (nN * a0 + an1 - 2 * sum) / (nN + 1);
        printf("%.2f", a1);
        putchar('\n');

        if (nCases)
        {
            putchar('\n');
        }
    }

    return 0;
}
```