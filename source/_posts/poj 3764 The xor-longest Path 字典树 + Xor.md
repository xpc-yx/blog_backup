---
title: poj 3764 The xor-longest Path 字典树 + Xor
tags:
  - 字典树
id: 282
categories:
  - 算法 
  - 算法题
date: 2012-10-12 10:30:00
---

这题意思很简单。求一棵树里面的一条路径，使得其异或权(就是将路径里面所有边的权值异或起来)最大。
这个题有两步。第一步是假定根为节点0，求出根到其它节点的异或距离，保存在数组xor里面，这个dfs一下即可。然后，用xor[i]^xor[j]就能代表节点i到节点j的路径。这个结论可以这么看。如果，i和j之间的路径经过根节点，那么上面的结论肯定是正确的。如果，该路径不经过根，那么xor[i]和xor[j]必定保护从根到某个节点的相同的一段子路径，根据异或的性质，这段子路径会被消掉，所以这个结论也是这确的。。。
第二步就是枚举，xor[i]^xor[j]使得结果最大了。如果直接暴力，平方的算法肯定会超时的。
由于每个值可以表示成2进制，如果把其它xor值都保存在字典树里面，用当前的xor[i]去字典树
里面，一遍就可以找到异或最大值。
另外，由于树的点数太多，只能用邻接表，用vector模拟邻接表果断超时了。。。改成静态链表才过。。。

代码如下：
``` stylus
#include <stdio.h>
#include <string.h>
#include <algorithm>
#include <vector>
using namespace std;

const int MAX = 100010;
int nXor[MAX];
bool bVis[MAX];
int nFirst[MAX];
struct Edge
{
    int nE;
    int nW;
    int nNext;
};
Edge egs[MAX * 2];

struct Node
{
    Node* pSons[2];
};
Node nodes[MAX * 32];
Node* pRoot = nodes[0];
int nNew;

void GetBCode(int nL, int* nBCode, int nLen)
{
    nLen = 0;
    while (nLen <= 30)
    {
        nBCode[nLen++] = nL % 2;
        nL >>= 1;
    }
    reverse(nBCode, nBCode + nLen);
}

void Insert(int nL)
{
    int nLen = 0;
    int i = 0;
    int nBCode[32];

    GetBCode(nL, nBCode, nLen);
    Node* pNode = pRoot;

    while (i < nLen)
    {
        if (pNode->pSons[nBCode[i]])
        {
            pNode = pNode->pSons[nBCode[i]];
        }
        else
        {
            memset(nodes + nNew, 0, sizeof(nodes[nNew]));
            pNode->pSons[nBCode[i]] = nodes + nNew;
            pNode = nodes + nNew;
            ++nNew;
        }
        ++i;
    }
}

int FindMax(int nL)
{
    int nLen = 0;
    int nAns = 0;
    int i = 0;
    int nBCode[32];
    Node* pNode = pRoot;

    GetBCode(nL, nBCode, nLen);
    while (i < nLen)
    {
        int nBest = (nBCode[i] == 0 ? 1 : 0);
        int nBad = (nBCode[i] == 0 ? 0 : 1);
        if (pNode->pSons[nBest])
        {
            nAns = 2 * nAns + nBest;
            pNode = pNode->pSons[nBest];
        }
        else if (pNode->pSons[nBad])
        {
            nAns = 2 * nAns + nBad;
            pNode = pNode->pSons[nBad];
        }
        else break;
        ++i;
    }

    return nAns ^ nL;
}

void Dfs(int nV, int nL)
{
    nXor[nV] = nL;
    bVis[nV] = true;
    for (int e = nFirst[nV]; e != -1; e = egs[e].nNext)
    {
        if (!bVis[egs[e].nE])
        {
            Dfs(egs[e].nE, nL ^ egs[e].nW);
        }
    }
}

int main()
{
    int nN;
    int nU, nV, nW;

    while (scanf("%d", &nN) == 1)
    {
        for (int i = 0; i < nN; ++i) nFirst[i] = -1;
        for (int i = 1, j = 0; i < nN; ++i)
        {
            scanf("%d%d%d", &nU, &nV, &nW);
            egs[j].nE = nV;
            egs[j].nW = nW;
            egs[j].nNext = nFirst[nU];
            nFirst[nU] = j++;
            egs[j].nE = nU;
            egs[j].nW = nW;
            egs[j].nNext = nFirst[nV];
            nFirst[nV] = j++;
        }

        memset(bVis, false, sizeof(bool) * nN);
        Dfs(0, 0);

        memset(nodes[0], 0, sizeof(Node));
        nNew = 1;
        int nAns = 0;

        for (int i = 0; i < nN; ++i)
        {
            nAns = max(nAns, FindMax(nXor[i]));
            Insert(nXor[i]);
        }
        printf("%d\n", nAns);
    }

    return 0;
}
```