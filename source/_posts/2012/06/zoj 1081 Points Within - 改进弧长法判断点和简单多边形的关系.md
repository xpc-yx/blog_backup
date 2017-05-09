---
title: zoj 1081 Points Within - 改进弧长法判断点和简单多边形的关系
id: 201
categories:
  - 计算几何
date: 2012-06-26 17:00:00
tags:
---

转角法判断点和多边形的关系大家都知道，原理比较简单，在多边形内扫过的转角一定是360度，在边界上和外面则不一定。
实现起来也比较麻烦，浮点误差比较大，而且还要考虑些特殊情况。
在网上找到一种叫做改进弧长法的算法，原理和转角法类似，但是做了很多重要的改进。比如，计算转角改成了计算叉积，根据叉积决定旋转方向，还要根据计算下一个点的象限决定偏转多少，每次偏转的都是90度的倍数。该算法可以方便判断出点在多边形内，还是边界上，还是在多边形外面。

摘自别人对该算法的描述如下：
首先从该书中摘抄一段弧长法的介绍：“弧长法要求多边形是有向多边形，一般规定沿多边形的正向，边的左侧为多边形的内侧域。以被测点为圆心作单位圆，将全部有向边向单位圆作径向投影，并计算其中单位圆上弧长的代数和。若代数和为0，则点在多边形外部；若代数和为2π则点在多边形内部；若代数和为π，则点在多边形上。”
按书上的这个介绍，其实弧长法就是转角法。但它的改进方法比较厉害：将坐标原点平移到被测点P，这个新坐标系将平面划分为4个象限，对每个多边形顶点P ，只考虑其所在的象限，然后按邻接顺序访问多边形的各个顶点P，分析P和P[i+1]，有下列三种情况：
（1）P[i+1]在P的下一象限。此时弧长和加π/2；
（2）P[i+1]在P的上一象限。此时弧长和减π/2；
（3）P[i+1]在Pi的相对象限。首先计算f=y[i+1]*x-x[i+1]*y（叉积），若f=0，则点在多边形上；若f<0，弧长和减π；若f>0，弧长和加π。
最后对算出的代数和和上述的情况一样判断即可。实现的时候还有两点要注意，第一个是若P的某个坐标为0时，一律当正号处理；第二点是若被测点和多边形的顶点重合时要特殊处理。

以上就是书上讲解的内容，其实还存在一个问题。那就是当多边形的某条边在坐标轴上而且两个顶点分别在原点的两侧时会出错。如边(3,0)-(-3,0)，按以上的处理，象限分别是第一和第二，这样会使代数和加π/2，有可能导致最后结果是被测点在多边形外。而实际上被测点是在多边形上（该边穿过该点）。对于这点，我的处理办法是：每次算P和P[i+1]时，就计算叉积和点积，判断该点是否在该边上，是则判断结束，否则继续上述过程。这样牺牲了时间，但保证了正确性。
具体实现的时候，由于只需知道当前点和上一点的象限位置，所以附加空间只需O(1)。实现的时候可以把上述的“π/2”改成1，“π”改成2，这样便可以完全使用整数进行计算。不必考虑顶点的顺序，逆时针和顺时针都可以处理，只是最后的代数和符号不同而已。整个算法编写起来非常容易。

代码如下：
``` stylus
#include <stdio.h>
#include <math.h>

#define MAX (100 + 10)
struct Point
{
    double x,y;
};

Point pts[MAX];
const int OUT = 0;
const int IN = 1;
const int EDGE = 2;
const double fPre = 1e-8;

int DblCmp(double fD)
{
    if (fabs(fD) < fPre)
    {
        return 0;
    }
    else
    {
        return fD > 0 ? 1 : -1;
    }
}

int GetQuadrant(Point p)
{
    return DblCmp(p.x) >= 0 ? (DblCmp(p.y) >= 0 ? 0 : 3) :
               (DblCmp(p.y) >= 0 ? 1 : 2);
}

double Det(double fX1, double fY1, double fX2, double fY2)
{
    return fX1 * fY2 - fX2 * fY1;
}

int PtInPolygon(Point* pts, int nN, Point p)
{
    int i, j, k;
    for (j = 0; j < nN; ++j)
    {
        pts[j].x -= p.x;
        pts[j].y -= p.y;
    }
    int nA1, nA2;
    int nSum = 0;
    nA1 = GetQuadrant(pts[0]);
    for (i = 0; i < nN; ++i)
    {
        k = (i + 1) % nN;
        if (DblCmp(pts[k].x) == 0  DblCmp(pts[k].y) == 0)
        {
            break;//与顶点重合
        }
        int nC = DblCmp(Det(pts[i].x, pts[i].y,
                            pts[k].x, pts[k].y));
        if (!nC  DblCmp(pts[i].x * pts[k].x) <= 0
                 DblCmp(pts[i].y * pts[k].y) <= 0)
        {
            break;//边上
        }
        nA2 = GetQuadrant(pts[k]);
        if ((nA1 + 1) % 4 == nA2)
        {
            nSum += 1;
        }
        else if ((nA1 + 2) % 4 == nA2)
        {
            if (nC > 0)
            {
                nSum += 2;
            }
            else
            {
                nSum -= 2;
            }
        }
        else if ((nA1 + 3) % 4 == nA2)
        {
            nSum -= 1;
        }
        nA1 = nA2;
    }

    for (j = 0; j < nN; ++j)
    {
        pts[j].x += p.x;
        pts[j].y += p.y;
    }

    if (i < nN)
    {
        return EDGE;
    }
    else if (nSum)//逆时针nSum == 4, 顺时针nSum == -4
    {
        return IN;
    }
    else
    {
        return OUT;
    }
}

int main()
{
    int nN, nM;
    int nCase = 1;

    while (scanf("%d%d", &nN, &nM), nN)
    {
        if (nCase > 1)
        {
            printf("\n");
        }

        for (int i = 0; i < nN; ++i)
        {
            scanf("%lf%lf", &pts[i].x, &pts[i].y);
        }
        printf("Problem %d:\n", nCase++);
        for (int i = 0; i < nM; ++i)
        {
            Point p;
            scanf("%lf%lf", p.x, p.y);
            if (PtInPolygon(pts, nN, p))
            {
                printf("Within\n");
            }
            else
            {
                printf("Outside\n");
            }
        }
    }

    return 0;
}
```