---
title: poj 1988 Cube Stacking 并查集
tags:
  - 并查集
id: 278
categories:
  - 算法
  - 算法题
date: 2012-10-10 10:00:00
---

也是个题意比较奇葩的题目。有2个操作，1个是把一个元素所在的栈，放到另外1个元素所在的栈面。另外一个操作是统计某个元素下面有多少个元素(当然是在同一个栈中）。貌似，需要记录每个元素下面的元素是什了，既然要记录这个就不能用并查集的路径压缩了。不压缩路径的话，肯定会超时的。怎么办了。。。
其实，可以这么考虑，以每个栈的栈底元素作为并查集的代表元素。压缩路径后，每个元素或者是根元素或者其父亲元素就是根元素。所以，另外对每个节点附加个信息代表该节点的高度，栈底元素高度为0。再附加个信息代表每个并查集元素总数目，这样就可以在合并集合时候修改信息，并且压缩路径也能保证答案正确。。。

代码如下：
``` stylus
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <algorithm>
using namespace std;

const int MAX = 30010;
int nSets[MAX];
int nNum[MAX];
int nRank[MAX];

void MakeSets(int nN)
{
    for (int i = 0; i < nN; ++i)
    {
        nSets[i] = i;
        nNum[i] = 1;
        nRank[i] = 0;
    }
}

int FindSet(int nI)
{
    if (nSets[nI] != nI)
    {
        int nPre = nSets[nI];
        nSets[nI] = FindSet(nSets[nI]);
        nRank[nI] += nRank[nPre];
    }

    return nSets[nI];
}

void Move(int nX, int nY)
{
    int nA = FindSet(nX);
    int nB = FindSet(nY);
    //printf("nA:%d,nB:%d\n", nA, nB);
    if (nA != nB)
    {
        nSets[nA] = nB;
        nRank[nA] += nNum[nB];
        nNum[nB] += nNum[nA];
    }
}

int main()
{
    int nP;
    char szOper[10];
    int nX, nY;

    scanf("%d", &nP);
    MakeSets(MAX);
    while (nP--)
    {
        scanf("%s", szOper);
        if (szOper[0] == 'M')
        {
            scanf("%d%d", &nX, &nY);
            Move(nX, nY);
        }
        else
        {
            scanf("%d", &nX);
            FindSet(nX);
            printf("%d\n", nRank[nX]);
        }
    }

    return 0;
}
```