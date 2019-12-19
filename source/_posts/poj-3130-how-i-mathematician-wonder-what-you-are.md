---
title: poj 3130 How I Mathematician Wonder What You Are!
tags:
id: 207
categories:
  - ACM-ICPC
date: 2012-07-03 12:30:00
---

半平面交的一个题，也是求多边形的核心。求出这个好像也可以用于解决一些线性规划问题。我用的是N * N的基本算法，每加入一条直线，就对原来求出的半平面交进行处理，产生新的核心。
代码参照台湾的一个网站演算法笔记上的内容和代码。表示这个网站巨不错，求凸包的算法也参照了这个网站上的内容和代码。半平面交的地址：[http://www.csie.ntnu.edu.tw/~u91029/Half-planeIntersection.html#a4](http://www.csie.ntnu.edu.tw/~u91029/Half-planeIntersection.html#a4)

代码思路主要是：先读入所有的多边形顶点，放入一个vector（vp）里面，然后对多边形的每条边求一个半平面。刚开始的时候，用一个vector（Polygon）保存代表上下左右四个无限远角的四个点，表示原始的半平面。然后，用读入的多边形的每条边去切割原来的半平面。
切割的过程是，如果原来（Polygon）中的点在当前直线的指定一侧，那么原来的点还是有效的。如果原来的点和它相邻的下一个点与当前直线相交，那么还需要把交点加入Polygon集合。
还有求交点的方法比较奇葩，类似于黑书上面的那种根据面积等分的方法。

代码如下：
``` stylus
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <vector>
#include <algorithm>
using namespace std;

double fPre = 1e-8;
struct Point
{
    double x;
    double y;
    Point() {}
    Point(double fX, double fY)
    {
        x = fX, y = fY;
    }
};
typedef vector<Point> Polygon;
typedef pair<Point, Point> Line;
Point operator+(const Point a, const Point b)
{
    Point t;
    t.x = a.x + b.x;
    t.y = a.y + b.y;
    return t;
}

Point operator-(const Point a, const Point b)
{
    Point t;
    t.x = a.x - b.x;
    t.y = a.y - b.y;
    return t;
}

Point operator*(Point a, double fD)
{
    Point t;
    t.x = a.x * fD;
    t.y = a.y * fD;
    return t;
}

int DblCmp(double fD)
{
    return fabs(fD) < fPre ? 0 : (fD > 0 ? 1 : -1);
}

double Det(double fX1, double fY1, double fX2, double fY2)
{
    return fX1 * fY2 - fX2 * fY1;
}
//3点叉积
double Cross(Point a, Point b, Point c)
{
    return Det(b.x - a.x, b.y - a.y, c.x - a.x, c.y - a.y);
}
//向量叉积
double Cross(Point a, Point b)
{
    return a.x * b.y - a.y * b.x;
}

//求直线交点的一种简便方法
//平行四边形面积的比例等于高的比例
Point Intersection(Point a1, Point a2, Point b1, Point b2)
{
    Point a = a2 - a1;
    Point b = b2 - b1;
    Point s = b1 - a1;

    return a1 + a * (Cross(b, s) / Cross(b, a));
}

Polygon HalfPlane(Polygon pg, Point a, Point b)
{
    Polygon pgTmp;
    int nN = pg.size();
    for (int i = 0; i < nN; ++i)
    {
        double fC = Cross(a, b, pg[i]);
        double fD = Cross(a, b, pg[(i + 1) % nN]);
        if (DblCmp(fC) >= 0)
        {
            pgTmp.push_back(pg[i]);
        }
        if (fC * fD < 0)
        {
            pgTmp.push_back(Intersection(a, b, pg[i], pg[(i + 1) % nN]));
        }
    }
    return pgTmp;
}

int main()
{
    int nN;
    Point p;
    vector<Point> vp;
    Polygon pg;

    while (scanf("%d", &nN), nN)
    {
        vp.clear();
        for (int i = 0; i < nN; ++i)
        {
            scanf("%lf%lf", &p.x, &p.y);
            vp.push_back(p);
        }
        pg.clear();
        pg.push_back(Point(-1e9, 1e9));
        pg.push_back(Point(-1e9, -1e9));
        pg.push_back(Point(1e9, -1e9));
        pg.push_back(Point(1e9, 1e9));
        for (int i = 0; i < nN; ++i)
        {
            pg = HalfPlane(pg, vp[i], vp[(i + 1) % nN]);
            if (pg.size() == 0)
            {
                printf("0\n");
                break;
            }
        }
        if (pg.size())
        {
            printf("1\n");
        }
    }

    return 0;
}
```