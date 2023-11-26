---
title: poj 3714 Raid and hdu 1007 Quoit Design
tags:
  - 最近点对
id: 196
categories:
  - 算法 
  - 算法题
date: 2012-06-22 20:30:00
---

典型的最近点对算法的应用，不过这个题多了个限制条件，就是点分为2类，最短距离必须在不同的类之间。为了满足这个限制，只需要把同类别点直接的距离都当作INF处理即可。
最近点对的算法，算导上面说是nlogn的。但是这个复杂度实现起来略微麻烦点，有一种实现方法是n*logn*logn的，其只对x坐标进行了排序。n*logn的算法需要对x和y分量分别进行排序，还需要用到其它的辅助数组。
第一个题我用了n*logn算法实现了，第二个题则用了n*logn*logn算法实现了。但是时间上相差不大，因为第一个算法每次进行分治时候消耗的O(n)时间也有几次。第二个算法分治时候，需要再次排序的时间也不一定很多，因为可能数据量不够大。
算法的本质就是二分按照X排序好的点数组，n*logn*logn变成n*logn的关键是预先对y也排序好一个点数组，因为按y排序好的点数组，在分治后的合并中要用到。算法更详细的解释请参照算法导论。
poj 3714 代码如下： 
``` stylus
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <algorithm>
using namespace std;
#define MAX_N (100000 * 2 + 10)
const double FINF = 1LL << 60;
struct Point
{
    double x, y;
    int nKind;
};
Point pts[MAX_N], ptsY[MAX_N], ptsTemp[MAX_N];
Point ptsSave[MAX_N];
int nNum;
bool CmpX(const Point a, const Point b)
{
    return a.x < b.x;
}

bool CmpY(const Point a, const Point b)
{
    return a.y < b.y;
}

double Dis(Point a, Point b)
{
    if (a.nKind == b.nKind)
    {
        return FINF;
    }
    else
    {
        return sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y));
    }
}

double FindMinDis(Point pts[], Point ptsY[], Point ptsTemp[], int nBeg, int nEnd)
{
    if (nBeg == nEnd)
    {
        return FINF;
    }
    else if (nBeg + 1 == nEnd)
    {
        return Dis(pts[nBeg], pts[nEnd]);
    }
    else if (nBeg + 2 == nEnd)
    {
        return min(min(Dis(pts[nBeg], pts[nBeg + 1]), Dis(pts[nBeg], pts[nEnd])),
                   Dis(pts[nBeg + 1], pts[nEnd]));
    }
    else
    {
        memcpy(ptsSave + nBeg, ptsY + nBeg, sizeof(Point) * (nEnd - nBeg + 1));//保存当前的Y坐标顺序
        int nMid = (nBeg + nEnd) / 2;
        int nL = nBeg;
        int nR = nMid + 1;
        for (int i = nBeg; i <= nEnd; ++i)
        {
            if (ptsY[i].x - pts[nMid].x <= 0)
            {
                ptsTemp[nL++] = ptsY[i];
            }
            else
            {
                ptsTemp[nR++] = ptsY[i];
            }
        }

        double fAns = min(FindMinDis(pts, ptsTemp, ptsY, nBeg, nMid),
                          FindMinDis(pts, ptsTemp, ptsY, nMid + 1, nEnd));
        int nK = 1;

        for (int i = nBeg; i <= nEnd; ++i)
        {
            if (fabs(ptsSave[i].x - pts[nMid].x) <= fAns)
            {
                ptsTemp[nK++] = ptsSave[i];
            }
        }
        for (int i = 1; i < nK; ++i)
        {
            for (int j = i + 1; j < nK; ++j)
            {
                if (ptsTemp[j].y - ptsTemp[i].y > fAns)
                {
                    break;
                }
                fAns = min(fAns, Dis(ptsTemp[i], ptsTemp[j]));
            }
        }
        return fAns;
    }
}

int main()
{
    int nT;
    int nN;

    //printf("%f", FINF);
    scanf("%d", &nT);
    while (nT--)
    {
        scanf("%d", &nN);
        nNum = nN * 2;
        for (int i = 0; i < nN; ++i)
        {
            scanf("%lf%lf", &pts[i].x, &pts[i].y);
            pts[i].nKind = 1;
        }
        for (int i = nN; i < nNum; ++i)
        {
            scanf("%lf%lf", &pts[i].x, &pts[i].y);
            pts[i].nKind = 2;
        }
        memcpy(ptsY, pts, sizeof(Point) * nNum);
        sort(pts, pts + nNum, CmpX);
        sort(ptsY, ptsY + nNum, CmpY);
        printf("%.3f\n", FindMinDis(pts, ptsY, ptsTemp, 0, nNum - 1));
    }

    return 0;
}
```
hdu 1007 代码如下：
``` stylus
#include <stdio.h>
#include <math.h>
#include <algorithm>
using namespace std;
#define MAX (100000 + 10)
struct Point
{
    double x, y;
};
Point pts[MAX];
Point ptsTemp[MAX];
const double FINF = 1LL << 60;
bool CmpX(const Point a, const Point b)
{
    return a.x < b.x;
}

bool CmpY(const Point a, const Point b)
{
    return a.y < b.y;
}

double Dis(Point a, Point b)
{
    return sqrt((a.x - b.x) * (a.x - b.x) + (b.y - a.y) * (b.y - a.y));
}

double Find(int nL, int nH)
{
    if (nL == nH)
    {
        return FINF;
    }
    else if (nL + 1 == nH)
    {
        return Dis(pts[nL], pts[nH]);
    }
    else if (nL + 2 == nH)
    {
        return min(Dis(pts[nL], pts[nL + 1]), 
                   min(Dis(pts[nL], pts[nH]), Dis(pts[nH], pts[nL + 1])));
    }
    else
    {
        int nMid = (nL + nH) / 2;
        double fAns = min(Find(nL, nMid), Find(nMid + 1, nH));
        int nK = 0;
        for (int i = nL; i <= nH; ++i)
        {
            if (fabs(pts[i].x - pts[nMid].x) <= fAns)
            {
                ptsTemp[nK++] = pts[i];
            }
        }
        sort(ptsTemp, ptsTemp + nK, CmpY);
        for (int i = 0; i < nK; ++i)
        {
            for (int j = i + 1; j < nK; ++j)
            {
                if (ptsTemp[j].y - ptsTemp[i].y >= fAns)
                {
                    break;
                }
                fAns = min(fAns, Dis(ptsTemp[j], ptsTemp[i]));
            }
        }

        return fAns;
    }
}

int main()
{
    int nN;

    while (scanf("%d", &nN), nN)
    {
        for (int i = 0; i < nN; ++i)
        {
            scanf("%lf%lf", &pts[i].x, &pts[i].y);
        }
        sort(pts, pts + nN, CmpX);
        printf("%.2f\n", Find(0, nN -1) * 0.5);
    }

    return 0;
}
```