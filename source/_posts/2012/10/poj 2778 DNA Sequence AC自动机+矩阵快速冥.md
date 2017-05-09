---
title: poj 2778 DNA Sequence AC自动机+矩阵快速冥
tags:
  - AC自动机
  - 矩阵快速冥
id: 287
categories:
  - 字符串
date: 2012-10-18 10:30:00
---

题意很简单，假定文本集就是A,C,T,G，给定M个模式串，问你长度为N的文本不出现这些模式串的可能性到底有多少种。。。
确实非常不直观的样子。。。
解法是先学学AC自动机，建立起Trie图，根据trie图可以得到长度为1的路径矩阵，然后再快速冥得到长度为N的路径矩阵。
说起来都非常纠结，没学过AC自动机更加无法理解。学AC自动机之前据说得先学Trie树和KMP才好理解。学AC自动机搞Trie图就花费了近2天了，然后弄懂这个题又是一天，好在基本明白了。马上快比赛了，从长春换到金华也不知道是好是坏。。。还是弱菜啊。。。
贴下我的Trie图+快速冥(直接二分了,没有写成数论里面那种算法)...
``` stylus
#include <stdio.h>
#include <string.h>
#include <algorithm>
#include <queue>
using namespace std;

typedef long long INT;
const int MOD = 100000;
const int MAX_P = 100;
const int MAX_D = 4;
int nIdx[256];
char szPat[MAX_P];
INT nMatrix[MAX_P][MAX_P];
INT B[MAX_P][MAX_P];
INT A[MAX_P][MAX_P];

void InitIdx()
{
    nIdx['A'] = 0;
    nIdx['C'] = 1;
    nIdx['T'] = 2;
    nIdx['G'] = 3;
}

struct Trie
{
    Trie* fail;
    Trie* next[MAX_D];
    int no;
    bool flag;
    Trie()
    {
        fail = NULL;
        memset(next, 0, sizeof(next));
        no = 0;
        flag = false;
    }
};
Trie tries[MAX_D * MAX_P];
int nP;
Trie* pRoot;

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

void Insert(char* pszPat)
{
    Trie* pNode = pRoot;

    while (*pszPat)
    {
        if (pNode->next[nIdx[*pszPat]] == NULL)
        {
            pNode->next[nIdx[*pszPat]] = NewNode();
        }
        pNode = pNode->next[nIdx[*pszPat]];
        ++pszPat;
    }
    pNode->flag = true;
}

int BuildAC(Trie* pRoot)
{
    memset(nMatrix, 0, sizeof(nMatrix));

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
                if (front->next[i]->fail->flag == true)
                {
                    front->next[i]->flag = true;
                }

                qt.push(front->next[i]);
            }
            else
            {
                front->next[i] = front == pRoot? pRoot : front->fail->next[i];
            }

            if (front->next[i]->flag == false)
            {
                nMatrix[front->no][front->next[i]->no]++;
            }
        }
    }

    return nP;//节点总个数
}

void MultyMatrix(INT A[][MAX_P], INT B[][MAX_P], INT C[][MAX_P], int nSize)
{
    for (int i = 0; i < nSize; ++i)
    {
        for (int j = 0; j < nSize; ++j)
        {
            INT nSum = 0;
            for (int k = 0; k < nSize; ++k)
            {
                nSum = (nSum + A[i][k] * B[k][j]) % MOD;
            }
            C[i][j] = nSum;
        }
    }
}

void CopyMatrix(INT A[][MAX_P], INT B[][MAX_P], int nSize)
{
    for (int i = 0; i < nSize; ++i)
    {
        for (int j = 0; j < nSize; ++j)
        {
            A[i][j] = B[i][j];
        }
    }
}

void MatrixPower(INT M[][MAX_P], int nSize, INT nP)
{
    if (nP == 1)
    {
        CopyMatrix(A, M, nSize);
        return;
    }

    MatrixPower(M, nSize, nP / 2);
    MultyMatrix(A, A, B, nSize);
    if (nP % 2)
    {
        MultyMatrix(B, M, A, nSize);
    }
    else
    {
        CopyMatrix(A, B, nSize);
    }
}

int main()
{
    INT nM, nN;

    InitIdx();
    while (scanf("%I64d%I64d", &nM, &nN) == 2)
    {
        InitTrie(pRoot);
        while (nM--)
        {
            scanf("%s", szPat);
            Insert(szPat);
        }
        int nSize = BuildAC(pRoot);

        MatrixPower(nMatrix, nSize, nN);
        INT nAns = 0;
        for (int i = 0; i < nSize; ++i)
        {
            nAns = (nAns + A[0][i]) % MOD;
        }
        printf("%I64d\n", nAns % MOD);
    }

    return 0;
}
```