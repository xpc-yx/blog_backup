---
title: 'poj 1703 Find them, Catch them 并查集'
tags:
  - 并查集
id: 274
categories:
  - 算法
  - 数据结构
date: 2012-10-08 12:30:00
---

并查集应用的变形。
给出的是2个节点是敌对关系的信息，最后询问任意2个节点的关系。根据这些信息，
节点之间可能是敌对的，也可能不是的（因为敌人的敌人就是朋友），也可能给出的
信息根本描述不了它们的关系。
看起来跟原始的并查集应用差远了。。。
有个比较直接的做法，那么就是把不在一个集合的节点直接用并查集合并在一起。这样的话，
如果询问的2个节点在同一个并查集里面，那么它们之间的关系是确定的，否则无法确定它们的
关系。
现在还有一个问题是，在同一个并查集里面的2个节点是敌对关系还是朋友关系。。。
可以给每个节点另外附加个信息，记录其距离并查集根节点的距离。如果，询问的2个节点距离
其根节点的距离都是奇数或者都是偶数，那么这2个节点是朋友关系，否则是敌对关系。。。

代码如下：
``` stylus
#include <stdio.h>
#include <string.h>
#include <algorithm>
using namespace std;

const int MAX_N = 100010;
int nSets[MAX_N];
int nDis[MAX_N];

int nN, nM;

void MakeSets(int nNum)
{
    for (int i = 0; i < nNum; ++i)
    {
        nSets[i] = i;
        nDis[i] = 0;
    }
}

int FindSet(int nI)
{
    if (nSets[nI] != nI)
    {
        int nPre = nSets[nI];
        nSets[nI] = FindSet(nSets[nI]);
        nDis[nI] = (nDis[nI] + nDis[nPre]) % 2;
    }
    return nSets[nI];
}

void UnionSet(int nI, int nJ)
{
    int nA = FindSet(nI);
    int nB = FindSet(nJ);
    if (nA != nB)
    {
        nSets[nA] = nB;
        nDis[nA] = (nDis[nI] + nDis[nJ] + 1) % 2;
    }
}

int main()
{
    int nT;

    scanf("%d", nT);
    while (nT--)
    {
        scanf("%d%d", nN, nM);
        MakeSets(nN);
        char szOper[10];
        int nA, nB;
        while (nM--)
        {
            scanf("%s%d%d", szOper, &nA, &nB);
            if (szOper[0] == 'D')
            {
                UnionSet(nA, nB);
            }
            else
            {
                int nX = FindSet(nA);
                int nY = FindSet(nB);
                if (nX == nY)
                {
                    if (nDis[nA] == nDis[nB])
                    {
                        printf("In the same gang.\n");
                    }
                    else
                    {
                        printf("In different gangs.\n");
                    }
                }
                else
                {
                    printf("Not sure yet.\n");
                }
            }
        }
    }

    return 0;
}
```