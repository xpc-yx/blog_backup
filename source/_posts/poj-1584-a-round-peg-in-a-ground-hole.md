---
title: poj 1584 A Round Peg in a Ground Hole
tags:
  - 凸多边形放圆
id: 205
categories:
  - 算法
  - 计算几何
date: 2012-06-30 20:00:00
---

这个题需要多个计算几何算法。第一个是判断一系列点是否能够构成凸多边形，第二个是判断一个点是否在一个简单多边形内部，第三个是求一个点到一条线段（或者说直线）的距离，第四个是判断一个圆是否则一个凸多边形内部。
其实，我是要判断一个圆是否则一个凸多边形内部而用到算法二和三。其实，有不需要判断圆心是否则多边形内部的算法。算法一的思想，求所有边的偏转方向，必须都是逆时针或者顺时针偏转。算法二则是我前面发的那篇改进弧长法判断点和多边形的关系，算法三尤其简单，直线上面取2点，用叉积求出这三点构成的三角形面积的2倍，再除以底边。算法四则是先判断圆心在多边形内部，然后判断圆心到所有边的距离要大于圆的半径。
贴出代码，纯粹为了以后作为模版使用等，防止遗忘，方便查找，其实现在也能手敲出来了。

代码如下：
``` stylus
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <algorithm>
#include <vector>
using namespace std;

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

struct Point
{
    double x, y;
    bool operator == (const Point p)
    {
        return DblCmp(x - p.x) == 0  DblCmp(y - p.y) == 0;
    }
};

Point operator-(const Point a, const Point b)
{
    Point p;
    p.x = a.x - b.x;
    p.y = a.y - b.y;
    return p;
}

double Det(double fX1, double fY1, double fX2, double fY2)
{
    return fX1 * fY2 - fX2 * fY1;
}

double Cross(Point a, Point b, Point c)
{
    return Det(b.x - a.x, b.y - a.y, c.x - a.x, c.y - a.y);
}

bool IsConvexPolygon(vector<Point> vp)
{
    int nN = vp.size();
    int nDirection = 0;
    bool bLine = true;//避免所有点共线
    for (int i = 0; i < nN; ++i)
    {
        int nTemp = DblCmp(Cross(vp[i], vp[(i + 1) % nN], vp[(i + 2) % nN]));
        if (nTemp)
        {
            bLine = false;
        }
        //这次的方向和上次的方向必须是相同的或者是3点和3点以上共线的情况
        if (nDirection * nTemp < 0)
        {
            return false;
        }
        nDirection = nTemp;
    }
    return bLine == false;
}

int GetQuadrant(Point p)
{
    return p.x >= 0 ? (p.y >= 0 ? 0 : 3) : (p.y >= 0 ? 1 : 2);
}

bool IsPtInPolygon(vector<Point> vp, Point p)
{
    int nN = vp.size();
    int nA1, nA2, nSum = 0;
    int i;

    nA1 = GetQuadrant(vp[0] - p);
    for (i = 0; i < nN; ++i)
    {
        int j = (i + 1) % nN;
        if (vp[i] == p)
        {
            break;
        }
        int nC = DblCmp(Cross(p, vp[i], vp[j]));
        int nT1 = DblCmp((vp[i].x - p.x) * (vp[j].x - p.x));
        int nT2 = DblCmp((vp[i].y - p.y) * (vp[j].y - p.y));
        if (!nC  nT1 <= 0  nT2 <= 0)
        {
            break;
        }
        nA2 = GetQuadrant(vp[j] - p);
        switch ((nA2 - nA1 + 4) % 4)
        {
        case 1:
            nSum++;
            break;
        case 2:
            if (nC > 0)
            {
                nSum += 2;
            }
            else
            {
                nSum -= 2;
            }
            break;
        case 3:
            nSum--;
            break;
        }
        nA1 = nA2;
    }

    if (i < nN || nSum)
    {
        return true;
    }
    return false;
}

double PtDis(Point a, Point b)
{
    return sqrt((a.x - b.x) * (a.x - b.x) + (b.y - a.y) * (b.y - a.y));
}
//点p到直线ab的距离
//h = (2 * Spab) / |ab|
double GetDis(Point a, Point b, Point p)
{
    return fabs(Cross(a, b, p)) / PtDis(a, b);
}

bool IsCircleInPolygon(vector<Point> vp, Point p, double fR)
{
    if (!IsPtInPolygon(vp, p))
    {
        return false;
    }

    int nN = vp.size();
    for (int i = 0; i < nN; ++i)
    {
        if (GetDis(vp[i], vp[(i + 1) % nN], p) < fR)
        {
            return false;
        }
    }
    return true;
}

int main()
{
    int nN;
    double fR, fPx, fPy;
    vector<Point> vp;
    Point p;

    while (scanf("%d%lf%lf%lf", &nN, &fR, &fPx, &fPy), nN >= 3)
    {
        vp.clear();
        for (int i = 0; i < nN; ++i)
        {
            scanf("%lf%lf", &p.x, &p.y);
            vp.push_back(p);
        }

        if (IsConvexPolygon(vp))
        {
            p.x = fPx;
            p.y = fPy;
            if (IsCircleInPolygon(vp, p, fR))
            {
                printf("PEG WILL FIT\n");
            }
            else
            {
                printf("PEG WILL NOT FIT\n");
            }
        }
        else
        {
            printf("HOLE IS ILL-FORMED\n");
        }
    }

    return 0;
}
```