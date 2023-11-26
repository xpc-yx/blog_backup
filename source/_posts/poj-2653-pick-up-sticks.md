---
title: poj 2653 Pick-up sticks
tags:
  - 直线相交
id: 190
categories:
  - 算法 
  - 算法题
date: 2012-06-17 14:30:00
---

这是一个计算几何的题目。题意是，按顺序给一系列的线段，问最终哪些线段处在顶端。只需要穷举判断，当前的线段会与哪些线段有交点即可。也就是暴力求解，但是线段数目N有10的5次方，平方算法是不能过的。这个题能过的原因是题目描述里面说了，top的stick不会超过1000个。那么修改下暴力的方式题目就能过了。
从小到大枚举每个棍子，判断它是否与后面的棍子相交，如果相交直接把当前棍子的top属性置为false，然后break内层循环。这样就不会超时了，暴力也是需要技巧的，这句话说的很对啊。
判断2条线段是否相交的算法直接按照黑书上的模板代码写了，那个模板代码还不错吧。。。

代码如下：
``` stylus
#include <stdio.h>
#include <string.h>
#include <math.h>
#define MAX_N (100000 + 10)
struct POS
{
    double fX;
    double fY;
};

POS begs[MAX_N], ends[MAX_N];
bool bAns[MAX_N];
int nN;
const double fPrecision = 1e-8;

double Det(double fX1, double fY1, double fX2, double fY2)
{
    return fX1 * fY2 - fX2 * fY1;
}

//以a作为公共点,计算叉积
double Cross(POS a, POS b, POS c)
{
    return Det(b.fX - a.fX, b.fY - a.fY, c.fX - a.fX, c.fY - a.fY);
}

int DblCmp(double fD)
{
    if (fabs(fD) < fPrecision)
    {
        return 0;
    }
    else
    {
        return fD > 0 ? 1 : -1;
    }
}
//
bool IsSegCross(int nI, int nJ)
{
    return (DblCmp(Cross(begs[nI], ends[nI], begs[nJ]))
            ^ DblCmp(Cross(begs[nI], ends[nI], ends[nJ]))) == -2
            (DblCmp(Cross(begs[nJ], ends[nJ], begs[nI]))
               ^ DblCmp(Cross(begs[nJ], ends[nJ], ends[nI]))) == -2;
}

int main()
{
    while (scanf("%d", &nN), nN)
    {
        for (int i = 1; i <= nN; ++i)
        {
            scanf("%lf%lf%lf%lf", &begs[i].fX, &begs[i].fY,
                  &ends[i].fX, &ends[i].fY);
        }

        memset(bAns, true, sizeof(bAns));

        //暴力也是需要技巧的
        for (int i = 1; i < nN; ++i)
        {
            for (int j = i + 1; j <= nN; ++j)
            {
                if (IsSegCross(i, j))
                {
                    bAns[i] = false;
                    break;
                }
            }
        }

        printf("Top sticks:");
        bool bPre = false;
        for (int i = 1; i <= nN; ++i)
        {
            if (bAns[i])
            {
                if (bPre)
                {
                    printf(",");
                }
                bPre = true;
                printf(" %d", i);
            }
        }
        printf(".\n");
    }

    return 0;
}
```