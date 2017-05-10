---
title: poj 1269 Intersecting Lines
tags:
  - 判断两条直线的关系
id: 193
categories:
  - 算法
  - 计算几何
date: 2012-06-20 10:00:00
---

题目意思是给出2条直线，然后判断其是否相交，平行，还是重合。刚开始以为是判断2条线段的关系，用了黑书的模板写了，发现连样例都过不了。后面改了很多才过了。先判断2条直线所在的向量是否平行，这个可以判断这2个向量的叉积是否为0，然后再判断线段是否重合，可以选3点判断叉积是否为0。如果向量不平行的话，直接求交点。求交点的公式是用了黑书里面的方法，先求出2个叉积代表2个三角形的有向面积，然后根据定比分点的关系（面积的比例等于交点分其中一条线段的比例）可以推出计算公式。
有叉积和点积这2个工具确实能方便的解决很多问题。

代码如下：
``` stylus
#include <stdio.h>
#include <string.h>
#include <math.h>
struct Point
{
    double fX;
    double fY;
};
Point beg[2], end[2];
int nN;
const double fPrecision = 1e-8;

double Det(double fX1, double fY1, double fX2, double fY2)
{
    return fX1 * fY2 - fX2 * fY1;
}

double Cross(Point a, Point b, Point c)
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
        return (fD > 0 ? 1 : -1);
    }
}

double DotDet(double fX1, double fY1, double fX2, double fY2)
{
    return fX1 * fX2 + fY1 * fY2;
}

double Dot(Point a, Point b, Point c)
{
    return DotDet(b.fX - a.fX, b.fY - a.fY, c.fX - a.fX, c.fY - a.fY);
}

int BetweenCmp(Point a, Point b, Point c)
{
    return DblCmp(Dot(a, b, c));
}

int SegCross(Point a, Point b, Point c, Point d, Point p)
{
    double s1, s2, s3, s4;
    int d1, d2, d3, d4;
    d1 = DblCmp(s1 = Cross(a, b, c));
    d2 = DblCmp(s2 = Cross(a, b, d));
    d3 = DblCmp(s3 = Cross(c, d, a));
    d4 = DblCmp(s4 = Cross(c, d, b));

    Point e, f;
    e.fX = a.fX - b.fX;
    e.fY = a.fY - b.fY;
    f.fX = c.fX - d.fX;
    f.fY = c.fY - d.fY;
    if (DblCmp(Det(e.fX, e.fY, f.fX, f.fY)) == 0)//2个向量共线
    {
        if (d1 * d2 > 0  d3 * d4 > 0)//不在同一条直线上
        {
            return 0;
        }
        else
        {
            return 2;
        }
    }

    //2条直线相交
    p.fX = (c.fX * s2 - d.fX * s1) / (s2 - s1);
    p.fY = (c.fY * s2 - d.fY * s1) / (s2 - s1);
    return 1;
}

int main()
{
    //freopen("out.txt", "w", stdout);
    while (scanf("%d", &nN) == 1)
    {
        printf("INTERSECTING LINES OUTPUT\n");
        Point p;
        for (int i = 0; i < nN; ++i)
        {
            scanf("%lf%lf%lf%lf", &beg[0].fX, &beg[0].fY, &end[0].fX, &end[0].fY);
            scanf("%lf%lf%lf%lf", &beg[1].fX, &beg[1].fY, &end[1].fX, &end[1].fY);
            int nRet = SegCross(beg[0], end[0], beg[1], end[1], p);
            if (nRet == 0)
            {
                printf("NONE\n");
            }
            else if (nRet == 1)
            {
                printf("POINT %.2f %.2f\n", p.fX, p.fY);
            }
            else
            {
                printf("LINE\n");
            }
        }
        printf("END OF OUTPUT\n");
    }

    return 0;
}
```