---
title: poj 2187 Beauty Contest
tags:
  - 旋转卡壳
  - 最远点对
id: 211
categories:
  - 算法
  - 计算几何
date: 2012-07-07 21:00:00
---

这个题我是按照discussion里面的说法，先求凸包，然后枚举过的。因为开始先把求凸包算法里面的用到了数组名搞混了，无故wa了好多次。后面求凸包换了种算法过了。结果发现bug是搞混了数组名，然后把前面wa掉的代码下载下来，改好之后也都过了。
这个题主要是凸包算法需要处理有重复点，有多点共线之类的情况。那个按极角排序后，再求凸包的算法，对共点共线处理的不是很好，不过那个算法也过了这个题。有个直接按坐标排序后，再求上凸包和下凸包的算法，可以处理共点共线的情况。这个算法比较优美啊，既不需要找y坐标最小的点，也不需要按极角排序，直接按坐标排序下，然后求凸包即可。
这个算法的一点解释：[http://www.algorithmist.com/index.php/Monotone_Chain_Convex_Hull](http://www.algorithmist.com/index.php/Monotone_Chain_Convex_Hull)
另外，演算法笔记：[http://www.csie.ntnu.edu.tw/~u91029/ConvexHull.html#a3](http://www.csie.ntnu.edu.tw/~u91029/ConvexHull.html#a3)上也有提到这个算法，我也是从这上面看到的。
这个算法可以假设是Graham排序基准点在无限远处，于是夹角大小的比较可以直接按水平坐标比较。

代码如下：

``` stylus
#include <stdio.h>
#include <algorithm>
#include <math.h>
using namespace std;
struct Point
{
    int x, y;
    bool operator<(const Point p) const
    {
        return x < p.x || x == p.x  y < p.y;
    }
};
Point pts[50100];
Point pcs[50100];
int nN;
int nM;
inline int SDis(const Point a, const Point b)
{
    return (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y);
}

double Det(double fX1, double fY1, double fX2, double fY2)
{
    return fX1 * fY2 - fX2 * fY1;
}

double Cross(Point a, Point b, Point c)
{
    return Det(b.x - a.x, b.y - a.y, c.x - a.x, c.y - a.y);
}

void Convex()
{
    sort(pts, pts + nN);

    nM = 0;
    for (int i = 0; i < nN; ++i)
    {
        while(nM >= 2  Cross(pcs[nM - 2], pcs[nM - 1], pts[i]) <= 0)
        {
            nM--;
        }
        pcs[nM++] = pts[i];
    }
    for (int i= nN - 2, t = nM + 1; i >= 0; --i)
    {
        while (nM >= t  Cross(pcs[nM - 2], pcs[nM - 1], pts[i]) <= 0)
        {
            nM--;
        }
        pcs[nM++] = pts[i];
    }
    nM--;//起点会被重复包含
}

int main()
{
    while (scanf("%d", nN) == 1)
    {
        for (int i = 0; i < nN; ++i)
        {
            scanf("%d%d", pts[i].x, pts[i].y);
        }
        Convex();
        int nMax = -1;
        for (int i = 0; i < nM; ++i)
        {
            for (int j = i + 1; j < nM; ++j)
            {
                nMax = max(nMax, SDis(pcs[i], pcs[j]));
            }
        }
        printf("%d\n", nMax);
    }

    return 0;
}
```

也可以用旋转卡壳算法来求最远点对，此题的完整代码如下：

``` stylus
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <vector>
#include <algorithm>
using namespace std;

struct Point
{
    int x, y;
    bool operator < (const Point p)const
    {
        return x < p.x || x == p.x  y < p.y;
    }
};

double Det(double fX1, double fY1, double fX2, double fY2)
{
    return fX1 * fY2 - fX2 * fY1;
}

double Cross(Point a, Point b, Point c)
{
    return Det(b.x - a.x, b.y - a.y, c.x - a.x, c.y - a.y);
}

//输入点集合,输出凸包
void Convex(vector<Point> in, vector<Point> out)
{
    int nN = in.size();
    int nM = 0;

    sort(in.begin(), in.end());
    out.resize(nN);

    for (int i = 0; i < nN; ++i)
    {
        while (nM >= 2  Cross(out[nM - 2], out[nM - 1], in[i]) <= 0)
        {
            nM--;
        }
        out[nM++] = in[i];
    }

    for (int i = nN - 2, t = nM + 1; i >= 0; --i)
    {
        while (nM >= t  Cross(out[nM - 2], out[nM - 1], in[i]) <= 0)
        {
            nM--;
        }
        out[nM++] = in[i];
    }
    out.resize(nM);
    out.pop_back();//起始点重复
}

int SDis(Point a,Point b)
{
    return (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y);
}

int RC(vector<Point> vp)
{
    int nP = 1;
    int nN = vp.size();
    vp.push_back(vp[0]);
    int nAns = 0;
    for (int i = 0; i < nN; ++i)
    {
        while (Cross(vp[i], vp[i + 1], vp[nP + 1]) > Cross(vp[i], vp[i + 1], vp[nP]))
        {
            nP = (nP + 1) % nN;
        }
        nAns = max(nAns, max(SDis(vp[i], vp[nP]), SDis(vp[i + 1], vp[nP + 1])));
    }
    vp.pop_back();
    return nAns;
}

int main()
{
    int nN;
    vector<Point> in, out;
    Point p;
    while (scanf("%d", &nN) == 1)
    {
        in.clear(), out.clear();
        while (nN--)
        {
            scanf("%d%d", p.x, p.y);
            in.push_back(p);
        }
        Convex(in, out);

        printf("%d\n", RC(out));
    }

    return 0;
}
```

关于旋转卡壳的算法描述，网上有很多资料，比如，http://www.cppblog.com/staryjy/archive/2010/09/25/101412.html尤其关于这个求最远点对的。