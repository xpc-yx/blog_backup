---
title: uva 10112 - Myacm Triangles
tags:
id: 172
categories:
  - 算法
  - 算法题
date: 2012-05-07 15:00:00
---

这是一个几何题。题意是给出一系列点，点最多才15个，求一个这里面的三个点组合出来的三角形，其面积是最大的，而且没有任何其它的点在这个三角形的内部和边界上。求三角形的面积，题目上面已经给了公式，也可以用0.5*|a|*|b|*sin(a,b)求，这里的a和b指的是2条边代表的向量。
现在就剩下一个问题了，怎么判断一个点在三角形的内部和边界上。在边界上，比较好判断，判断是否共线，然后再点是在线段的内部。
具体说明下，判断一个点在三角形内部的思路。我用的还是线性规划的思想。**如果该点在三角形的内部，那么任取三角形的一条边，该内部点和剩余的三角形的一个顶点必定在三角形的那条的边的同一侧。**这个方法也可以推广到N边的凸多边形，证明的话很简单，因为线性规划一直在划分区域。所以，划分到最后围起来的区域就是凸多边形的内部了。
至于写代码的话，由于是第一次写这种几何题，写得很凌乱。
``` stylus
#include <stdio.h>
#include <math.h>

#define MAX (20)
int nN;
struct Point
{
    char szLabel[5];
    int x;
    int y;
};
Point points[MAX];

//三点是否共线
bool IsOneLine(int nOne, int nTwo, int nThree)
{
    int nA = points[nTwo].x - points[nOne].x;
    int nB = points[nTwo].y - points[nOne].y;
    int nC = points[nThree].x - points[nOne].x;
    int nD = points[nThree].y - points[nOne].y;

    return (nA * nD == nB * nC);
}

//点nOne和点nTwo是否在直线(nBeg,nEnd)的同一侧(不能在直线上)
bool IsSameSide(int nBeg, int nEnd, int nOne, int nTwo)
{
    //求直线的向量
    int nA = points[nBeg].x - points[nEnd].x;
    int nB = points[nBeg].y - points[nEnd].y;

    //直线方程为nB(x - points[nBeg].x) - nA(y - points[nBeg].y) = 0
    //分别用nOne和nTwo的坐标代入直线方程计算结果，然后将结果相乘
    //乘积必须大于0
    int nRes = (nB * (points[nOne].x - points[nBeg].x) - nA * (points[nOne].y - points[nBeg].y))
               * (nB * (points[nTwo].x - points[nBeg].x) - nA * (points[nTwo].y - points[nBeg].y));

    if (nRes > 0)
    {
        //printf("点:%d,点:%d,在直线nBeg:%d, nEnd:%d的同一侧\n", nOne, nTwo, nBeg, nEnd);
    }
    return nRes > 0;
}

//点是否在三角形(nOne, nTwo, nThree)外部
bool PointOutTriangle(int nOne, int nTwo, int nThree, int nPoint)
{
    //前面3个ifelse是判断点是否在边上
    if (IsOneLine(nOne, nTwo, nPoint))
    {
        if ((points[nOne].x - points[nPoint].x) * (points[nTwo].x - points[nPoint].x) <= 0)
        {
            return false;
        }
    }
    else if (IsOneLine(nOne, nThree, nPoint))
    {
        if ((points[nOne].x - points[nPoint].x) * (points[nThree].x - points[nPoint].x) <= 0)
        {
            return false;
        }
    }
    else if (IsOneLine(nTwo, nThree, nPoint))
    {
        if ((points[nTwo].x - points[nPoint].x) * (points[nThree].x - points[nPoint].x) <= 0)
        {
            return false;
        }
    }

    //下面的IsSameSide如果nPoint在直线的(nOne,nTwo)的外侧也会判断为假
    //所以需要先在上面判断点是否在边的内侧
    return !(IsSameSide(nOne, nTwo, nThree, nPoint)
              IsSameSide(nOne, nThree, nTwo, nPoint)
              IsSameSide(nTwo, nThree, nOne, nPoint));
}

bool IsValid(int nOne, int nTwo, int nThree)
{
    if (IsOneLine(nOne, nTwo, nThree))
    {
        //printf("点:%d,%d,%d共线\n", nOne, nTwo, nThree);
        return false;
    }

    for (int i = 0; i < nN; ++i)
    {
        if (i == nOne || i == nTwo || i == nThree)
        {
            continue;
        }

        if (!PointOutTriangle(nOne, nTwo, nThree, i))
        {
            //printf("点:%d, 在三角形:%d,%d,%d内部\n", i, nOne, nTwo, nThree);
            return false;
        }
    }

    return true;
}

//计算三角形(nOne, nTwo, nThree)的面积
double GetArea(int nOne, int nTwo, int nThree)
{
    return 0.5 * fabs((points[nThree].y - points[nOne].y) * (points[nTwo].x - points[nOne].x)
                      - (points[nTwo].y - points[nOne].y) * (points[nThree].x - points[nOne].x));
}

int main()
{
    while (scanf("%d", &nN), nN)
    {
        for (int i = 0; i < nN; ++i)
        {
            scanf("%s%d%d", points[i].szLabel, &points[i].x, &points[i].y);
        }

        double fMaxArea = 0.0;
        int nI = -1, nJ = -1, nK = -1;
        for (int i = 0; i < nN - 2; ++i)
        {
            for (int j = i + 1; j < nN - 1; ++j)
            {
                for (int k = j + 1; k < nN; ++k)
                {
                    if (IsValid(i, j, k))
                    {
                        //printf("i:%d,j:%d,k:%d valid\n", i, j, k);
                        double fArea = GetArea(i, j, k);
                        //printf("Area:%f\n", fArea);
                        if (fArea > fMaxArea)
                        {
                            nI = i;
                            nJ = j;
                            nK = k;
                            fMaxArea = fArea;
                        }
                    }
                }
            }
        }
        printf("%s%s%s\n", points[nI].szLabel, points[nJ].szLabel, points[nK].szLabel);
    }

    return 0;
}
```