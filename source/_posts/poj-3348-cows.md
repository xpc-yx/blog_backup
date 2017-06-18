---
title: poj 3348 Cows
tags:
  - 凸包
  - 凸多边形面积
id: 199
categories:
  - ACM-ICPC
date: 2012-06-24 19:00:00
---

这个题用到2个计算几何算法。求解凸包和简单多边形面积。凸包算法详细解释见算法导论。求解多边形面积的思想是将多边形分解为三角形，一般是假设按顺序取多边形上面连续的2点与原点组合成一个三角形，依次下去用叉积求有向面积之和，最后取绝对值即可。注意，这些点必须是在多边形上逆时针或者顺时针给出的，而求出凸包刚好给了这样的一系列点。
凸包代码，其实先找出一个y坐标最小的点，再对剩下的所有点按极角排序。然后对排序后的点进行一个二维循环即可。二维循环的解释是当加入新的点进入凸包集合时候，如果与以前加入的点形成的偏转方向不一致，那么前面那些点都需要弹出集合。

代码如下：
``` stylus
#include <stdio.h>
#include <string.h>
#include <algorithm>
#include <math.h>
using namespace std;
#define MAX_N (10000 + 10)

struct Point
{
    double x, y;
    bool operator <(const Point p) const
    {
        return y < p.y || y == p.y  x < p.x;
    }
};

Point pts[MAX_N];
int nN;
Point ans[MAX_N];
int nM;

double Det(double fX1, double fY1, double fX2, double fY2)
{
    return fX1 * fY2 - fX2 * fY1;
}

double Cross(Point a, Point b, Point c)
{
    return Det(b.x - a.x, b.y - a.y, c.x - a.x, c.y - a.y);
}

bool CrossCmp(const Point a, const Point b)
{
    double cs = Cross(pts[0], a, b);
    return cs > 0 || cs == 0  a.x < b.x; 
}

void Scan()
{
    nM = 0;
    sort(pts + 1, pts + nN, CrossCmp);//对所有点按极角排序,逆时针偏转

    //第0-2个点，其实不会进入第二重循环的
    //从第3个点开始，就依次检查与凸包中前面点形成的边的偏转方向
    //如果不是逆时针偏转，则弹出该点
    for (int i = 0; i < nN; ++i)
    {
        while (nM >= 2  Cross(ans[nM - 2], ans[nM - 1], pts[i]) <= 0)
        {
            nM--;
        }
        ans[nM++] = pts[i];
    }
}

double GetArea()
{
    double fAns = 0.0;
    Point ori = {0.0, 0.0};
    for (int i = 0; i < nM; ++i)
    {
        fAns += Cross(ori, ans[i], ans[(i + 1) % nM]);
    }
    return fabs(fAns) * 0.5;
}

int main()
{
    while (scanf("%d", &nN) == 1)
    {
        for (int i = 0; i < nN; ++i)
        {
            scanf("%lf%lf", &pts[i].x, &pts[i].y);
            if (pts[i] < pts[0])
            {
                swap(pts[i], pts[0]);//pts[0]是y坐标最小的点
            }
        }

        Scan();//扫描出凸包
        double fArea = GetArea();
        printf("%d\n", (int)(fArea / 50));
    }

    return 0;
}
```