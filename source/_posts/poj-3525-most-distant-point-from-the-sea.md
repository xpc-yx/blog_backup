---
title: poj 3525 Most Distant Point from the Sea
tags:
  - 二分
id: 209
categories:
  - 算法 
  - 算法题
date: 2012-07-05 18:30:00
---

这个题的题意是给定一个凸多边形表示的海岛，求海岛离大海最远的距离。可以转化为一个凸多边形内部最多能够放入一个多大的圆。
显然可以对圆的半径进行二分，但是怎么确定圆心了。确定是否存在圆心，可以把原来的凸多边形往内部移动r（圆的半径）的距离之后，再对新的多边形求半平面交，如果半平面交存在（是个点即可），那么当前大小的圆能够放入。
求半平面交的算法可以用上一篇中的 N \* N 复杂度的基本算法。
本题还涉及到一个知识，就是如何把一条直线往逆时针方向或者顺时针方向移动R的距离。其实，可以根据单位圆那种思路计算。因为相当于以原来直线上的一点为圆心，以r为半径做圆，而且与原来的直线成90的夹角，那么后来点的坐标是（(x0 + cos(PI / 2 +θ ))，（y0 + sin(PI / 2 + θ))），转化一下就是(x0 - sinθ，y0 + cosθ)。那么直接可以求出dx = (vp[i].y - vp[(i + 1) % nN].y) \*  fR / fDis，dy = (vp[(i + 1) % nN].x - vp[i].x) \*  fR / fDis，fDis是线段的长度。

代码如下：
``` stylus
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <algorithm>
#include <vector>
using namespace std;

const double fPre = 1e-8;

struct Point
{
    double x,y;
    Point(){}
    Point(const Point p){x = p.x, y = p.y;}
    Point(double fX, double fY):x(fX), y(fY){}
    Point operator+(const Point p)
    {
        x += p.x;
        y += p.y;
        return *this;
    }
    Point operator+=(const Point p)
    {
        return *this = *this + p;
    }

    Point operator-(const Point p)
    {
        x -= p.x;
        y -= p.y;
        return *this;
    }
    Point operator*(double fD)
    {
        x *= fD;
        y *= fD;
        return *this;
    }
};
typedef vector<Point> Polygon;
int DblCmp(double fD)
{
    return fabs(fD) < fPre ? 0 : (fD > 0 ? 1 : -1);
}

double Cross(Point a, Point b)
{
    return a.x * b.y - a.y * b.x;
}

double Det(double fX1, double fY1, double fX2, double fY2)
{
    return fX1 * fY2 - fX2 * fY1;
}

double Cross(Point a, Point b, Point c)
{
    return Det(b.x - a.x, b.y - a.y, c.x - a.x, c.y - a.y);
}

Point Intersection(Point a1, Point a2, Point b1, Point b2)
{
    Point a = a2 - a1;
    Point b = b2 - b1;
    Point s = b1 - a1;
    return a1 + a * (Cross(b, s) / Cross(b, a));
}

Polygon Cut(Polygon pg, Point a, Point b)
{
    Polygon pgRet;
    int nN = pg.size();

    for (int i = 0; i < nN; ++i)
    {
        double fC = Cross(a, b, pg[i]);
        double fD = Cross(a, b, pg[(i + 1) % nN]);

        if (DblCmp(fC) >= 0)
        {
            pgRet.push_back(pg[i]);
        }
        if (DblCmp(fC * fD) < 0)
        {
            pgRet.push_back(Intersection(a, b, pg[i], pg[(i + 1) % nN]));
        }
    }
    //printf("pgRet number:%d\n", pgRet.size());
    return pgRet;
}

double Dis(Point a, Point b)
{
    return sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y));
}
//返回半平面的顶点个数
int HalfPlane(Polygon vp, double fR)
{
    Polygon pg;
    pg.push_back(Point(-1e9, -1e9));
    pg.push_back(Point(1e9, -1e9));
    pg.push_back(Point(1e9, 1e9));
    pg.push_back(Point(-1e9, 1e9));
    int nN = vp.size();
    for (int i = 0; i < nN; ++i)
    {
        double fDis = Dis(vp[i], vp[(i + 1) % nN]);
        double dx = (vp[i].y - vp[(i + 1) % nN].y) * fR / fDis;
        double dy = (vp[(i + 1) % nN].x - vp[i].x) * fR / fDis;
        Point a = vp[i], b = vp[(i + 1) % nN], c(dx, dy);
        a += c;
        b += c;
        //printf("%f %f %f %f\n", a.x, a.y, b.x, b.y);
        pg = Cut(pg, a, b);
        if (pg.size() == 0)
        {
            return 0;
        }
    }
    return pg.size();
}

int main()
{
    int nN;
    vector<Point> vp;

    while (scanf("%d", &nN), nN)
    {
        vp.clear();
        Point p;
        for (int i = 0; i < nN; ++i)
        {
            scanf("%lf%lf", &p.x, &p.y);
            vp.push_back(p);
        }
        double fMin = 0.0, fMax = 10000.0;
        while (DblCmp(fMin - fMax))
        {
            double fMid = (fMin + fMax) / 2;
            int nRet = HalfPlane(vp, fMid);
            //printf("fMid:%f, nRet:%d\n", fMid, nRet);
            if (nRet == 0)
            {
                fMax = fMid;
            }
            else
            {
                fMin = fMid;
            }
        }
        printf("%.6f\n", fMax);
    }

    return 0;
}
```