---
title: poj 1265 Area
tags:
  - pick定理
id: 203
categories:
  - 计算几何
date: 2012-06-28 16:00:00
---

此题用到了几个知识，一个是求多边形面积的公式。然后是，根据顶点都在整点上求多边形边界上的顶点数目的方法。最后一个是pick定理。根据前面2个信息和pick定理算出在多边形内部的整点的个数。
求多边形面积的方法还是叉积代表有向面积的原理，把原点看做另外的一个点去分割原来的多边形为N个三角形，然后把它们的有向面积加起来。
判断边界上点的个数是根据Gcd（dx,dy)代表当前边上整数点的个数的结论。这个结论的证明其实也比较简单，假设dx = a，dy = b。初始点是x0，y0，假设d = Gcd（a，b）。那么边上的点可以被表示为（x0 + k * (a / d)，y0 + k * （b / d))。为了使点是整数点，k必须是整数，而且0 求多边形内部点的个数用的是pick定理。面积 = 内部点 + 边界点 / 2 - 1。

代码如下：
``` stylus
#include <stdio.h>
#include <string.h>
#include <algorithm>
#include <math.h>
using namespace std;
#define MAX (100 + 10)

struct Point
{
    double x, y;
};
Point pts[MAX];

int nN;
const int IN = 1;
const int EAGE = 2;
const int OUT = 3;
const double fPre = 1e-8;

double Det(double fX1, double fY1, double fX2, double fY2)
{
    return fX1 * fY2 - fX2 * fY1;
}

double Cross(Point a, Point b, Point c)
{
    return Det(b.x - a.x, b.y - a.y, c.x - a.x, c.y - a.y);
}

double GetArea()
{
    double fArea = 0.0;
    Point ori = {0.0, 0.0};

    for (int i = 0; i < nN; ++i)
    {
        fArea += Cross(ori, pts[i], pts[(i + 1) % nN]);
    }
    return fabs(fArea) * 0.5;
}

int gcd(int nX, int nY)
{
    if (nX < 0)
    {
        nX = -nX;
    }
    if (nY < 0)
    {
        nY = -nY;
    }
    if (nX < nY)
    {
        swap(nX, nY);
    }
    while (nY)
    {
        int nT = nY;
        nY = nX % nY;
        nX = nT;
    }
    return nX;
}

int main()
{
    int nT;
    int nI, nE;
    double fArea;

    scanf("%d", &nT);
    int dx ,dy;

    for (int i = 1; i <= nT; ++i)
    {
        scanf("%d", &nN);
        nI = nE = 0;
        pts[0].x = pts[0].y = 0;
        for (int j = 1; j <= nN; ++j)
        {
            scanf("%d%d", &dx, &dy);
            pts[j].x = pts[j - 1].x + dx;
            pts[j].y = pts[j - 1].y + dy;
            nE += gcd(dx, dy);
        }
        fArea = GetArea();
        nI = (fArea + 1) - nE / 2;
        printf("Scenario #%d:\n%d %d %.1f\n\n", i, nI, nE, fArea);
    }

    return 0;
}
```