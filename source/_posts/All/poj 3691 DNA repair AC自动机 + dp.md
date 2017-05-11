---
title: poj 3691 DNA repair AC自动机 + dp
tags:
  - AC自动机
  - dp
id: 295
categories:
  - 算法
  - 字符串
date: 2012-10-21 11:30:00
---

题意是给定一系列模式串。然后给出一个文本串，问至少改变文本串里面多少个字符可以使文本串不包含任何一个模式串。
还是先建立Trie图，然后在Trie图上面进行dp。dp的思路也不是很复杂。dp[i][j]的意思是长度为i的文本串需要改变dp[i][j]个字符顺利到达状态j。需要注意的是长度为i的时候，对应的字符串中的第i-1个字符。刚开始一直没发现这个bug。而且注意中途不能转移到匹配成功的状态上去，多加几个条件控制即可了。。。转移方程，dp[i][j] = min(dp[i][j], dp[i-1][nNext] + szText[i-1] != k)，其中nNext是从状态j可以转移到的非匹配成功的状态，k代表的当前边的权。

代码如下：

``` stylus
#include <stdio.h>
#include <string.h>
#include <queue>
#include <algorithm>
using namespace std;

const int MAX_N = 61;
const int MAX_L = 31;
const int MAX_D = 4;
const int INF = 1110;
char chHash[256];
char szPat[MAX_L];

void InitHash()
{
    chHash['A'] = 0;
    chHash['G'] = 1;
    chHash['C'] = 2;
    chHash['T'] = 3;
}

struct Trie
{
    Trie* fail;
    Trie* next[MAX_D];
    bool flag;
    int no;
};
int nP;
Trie* pRoot;
Trie tries[MAX_N * MAX_L];

Trie* NewNode()
{
    memset(tries[nP], 0, sizeof(Trie));
    tries[nP].no = nP;
    return tries[nP++];
}

void InitTrie(Trie* pRoot)
{
    nP = 0;
    pRoot = NewNode();
}

void Insert(Trie* pRoot, char* pszPat)
{
    Trie* pNode = pRoot;
    while (*pszPat)
    {
        int idx = chHash[*pszPat];
        if (pNode->next[idx] == NULL)
        {
            pNode->next[idx] = NewNode();
        }
        pNode = pNode->next[idx];
        ++pszPat;
    }
    pNode->flag = true;
}

void BuildAC(Trie* pRoot)
{
    pRoot->fail = NULL;
    queue<Trie*> qt;
    qt.push(pRoot);

    while (!qt.empty())
    {
        Trie* front = qt.front();
        qt.pop();

        for (int i = 0; i < MAX_D; ++i)
        {
            if (front->next[i])
            {
                Trie* pNode = front->fail;
                while (pNode && pNode->next[i] == NULL)
                {
                    pNode = pNode->fail;
                }
                front->next[i]->fail = pNode? pNode->next[i] : pRoot;
                front->next[i]->flag |= front->next[i]->fail->flag;
                qt.push(front->next[i]);
            }
            else
            {
                front->next[i] = front == pRoot? pRoot : front->fail->next[i];
            }
        }
    }
}

int nChange[INF][INF];
char szText[INF];

int Solve()
{
    int nLen = strlen(szText);
    for (int i = 0; i <= nLen; ++i)
    {
        for (int j = 0; j < nP; ++j)
        {
            nChange[i][j] = INF;
        }
    }

    int i, j, k;
    nChange[0][0] = 0;
    for (i = 1; i <= nLen; ++i)
    {
        for (j = 0; j < nP; ++j)
        {
            if (tries[j].flag) continue;
            if (nChange[i - 1][j] == INF) continue;
            for (k = 0; k < MAX_D; ++k)
            {
                int nNext = tries[j].next[k] - tries;
                if (tries[nNext].flag) continue;
                //trie是边权树,所以i是从1到len,而且当前字符是szText[i-1]
                int nTemp = nChange[i - 1][j] + (k != chHash[szText[i - 1]]);
                nChange[i][nNext] = min(nChange[i][nNext], nTemp);
            }
        }
    }

    int nAns = INF;
    for (i = 0; i < nP; ++i)
    {
        if (!tries[i].flag)
            nAns = min(nAns, nChange[nLen][i]);
    }
    return nAns == INF? -1 : nAns;
}

int main()
{
    int nN;
    int nCase = 1;

    InitHash();
    while (scanf("%d", &nN), nN)
    {
        InitTrie(pRoot);
        while (nN--)
        {
            scanf("%s", szPat);
            Insert(pRoot, szPat);
        }
        BuildAC(pRoot);
        scanf("%s", szText);
        printf("Case %d: %d\n", nCase++, Solve());
    }

    return 0;
}
```