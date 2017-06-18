---
title: poj 1984 Navigation Nightmare 并查集
tags:
  - 并查集
id: 276
categories:
  - ACM-ICPC
date: 2012-10-09 14:00:00
---

并查集应用的变形。题目意思是一个图中，只有上下左右四个方向的边。给出这样的一些边，求任意指定的2个节点之间的距离。
有可能当前给出的信息，没有涉及到要求的2个节点，或者只涉及到了1个节点，那么肯定无法确定它们的距离。或者根据已经给出的边只知道这2个节点在不同的联通分量里面，那么其距离也是无法确定的，根据题目要求，输出-1。
问题是如果能够确定它们在一个联通分量里面，如何确定它们的距离了。这个题的关键在于，只有上下左右四个方向的边，假设每个节点都有一个坐标的话，那么它们相对于代表该联通分量节点的坐标肯定是固定的，那么就不需要考虑图里面有环之类的情况了。这样就可以很方便的应用并查集来解了。
利用并查集，给每个节点附加其它信息，即相对于代表该并查集的节点的坐标（x，y）。在FindSet里面求出坐标，在UnionSet里面修改合并后新加入的另外一个集合的根节点的坐标即可。
代码如下：
``` stylus
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <algorithm>
using namespace std;

const int MAX_N = 40010;
int nN, nM;
int nSets[MAX_N];
int nX[MAX_N];
int nY[MAX_N];
char szInput[MAX_N][100];

void MakeSets(int nNum)
{
    for (int i = 0; i < nNum; ++i)
    {
        nSets[i] = i;
        nX[i] = nY[i] = 0;
    }
}

int FindSets(int nI)
{
    if (nSets[nI] != nI)
    {
        int nPre = nSets[nI];
        nSets[nI] = FindSets(nSets[nI]);
        nX[nI] += nX[nPre];
        nY[nI] += nY[nPre];
    }
    return nSets[nI];
}

void UnionSets(int nBeg, int nEnd, int dx, int dy)
{
    int nA = FindSets(nBeg);
    int nB = FindSets(nEnd);
    if (nA != nB)
    {
        nSets[nB] = nA;//把集合B合并到集合A中
        nX[nB] = nX[nBeg] + dx - nX[nEnd];//因为方向逆过来了,所以是减去
        nY[nB] = nY[nBeg] + dy - nY[nEnd];
    }
}

int main()
{
    int nBeg, nEnd, nL;
    char szDir[10];

    while (scanf("%d%d%*c", &nN, &nM) == 2)
    {
        MakeSets(nN);
        for (int i = 0; i < nM; ++i)
        {
            fgets(szInput[i], 100, stdin);
        }
        int nK;
        int nF1, nF2, nI;
        scanf("%d", nK);
        int nCur = 0;
        while (nK--)
        {
            scanf("%d%d%d", nF1, nF2, nI);
            for (int i = nCur; i < nI; ++i)
            {
                sscanf(szInput[i], "%d%d%d%s", &nBeg,
                       &nEnd, &nL, szDir);
                int dx = 0, dy = 0;
                switch (szDir[0])
                {
                case 'N':
                    dy += nL;
                    break;
                case 'S':
                    dy -= nL;
                    break;
                case 'E':
                    dx += nL;
                    break;
                case 'W':
                    dx -= nL;
                    break;
                }
                UnionSets(nBeg, nEnd, dx, dy);
            }
            nCur = nI;

            if (FindSets(nF1) != FindSets(nF2))
            {
                printf("-1\n");
            }
            else
            {
                printf("%d\n", abs(nX[nF1] - nX[nF2])
                       + abs(nY[nF1] - nY[nF2]));
            }
        }
    }

    return 0;
}
```