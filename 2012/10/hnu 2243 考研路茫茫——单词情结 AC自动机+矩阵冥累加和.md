---
title: hnu 2243 考研路茫茫——单词情结 AC自动机+矩阵冥累加和
tags:
  - AC自动机
  - 矩阵冥累加和
id: 289
categories:
  - 字符串
date: 2012-10-18 18:00:00
---

这个题目更奇葩。据说是上一个题的加强版。题意是给定M个模式串，然后给定长度L，问不超过L的文本至少含有一个模式的情况的总种数。
还是用模式串建立Trie图，根据Trie图建立起路径长度为1的矩阵M。
总情况数目为26^1+26^2+...+26^L。不含模式串的情况总数为矩阵N = M^1+M^2+M^3+...+M^L的第一行之和。总情况数目减去不含模式串的情况就是答案。
这里用到了矩阵的一些算法，比如快速冥，还有快速冥求和。但是，我用了操作符重载，最悲剧的是重载后的操作符没有优先级，而我还当作有优先级的在用，所以悲剧了。。。一直样例都过不去。。。唉，最后才发现了这个问题。。。写了260行左右的代码，前面的一部分代码可以当作矩阵操作的模板了。。。Trie图的也不错，过几天估计得打印下来用了。。。

代码如下：
``` stylus
#include <stdio.h>
#include <string.h>
#include <queue>
#include <algorithm>
using namespace std;

typedef unsigned long long INT;
const int MAX_D = 26;
const int MAX_L = 10;
const int MAX_N = 10;
char szPat[MAX_L];

const int MAX_S = 31;
struct Matrix
{
    int nSize;
    INT nD[MAX_S][MAX_S];
    Matrix(int nS)
    {
        Clear(nS);
    }

    Matrix operator = (const Matrix m)
    {
        nSize = m.nSize;
        for (int i = 0; i < nSize; ++i)
        {
            for (int j = 0; j < nSize; ++j)
            {
                nD[i][j] = m.nD[i][j];
            }
        }
        return *this;
    }
    void Clear(int nS)
    {
        nSize = nS;
        memset(nD, 0, sizeof(nD));
    }
    void Unit()
    {
        for (int i = 0; i < nSize; ++i)
        {
            for (int j = 0; j < nSize; ++j)
            {
                nD[i][j] = (i == j ? 1 : 0);
            }
        }
    }
};

Matrix operator+(const Matrix A, const Matrix B)
{
    Matrix C(A.nSize);

    for (int i = 0; i < A.nSize; ++i)
    {
        for (int j = 0; j < A.nSize; ++j)
        {
            C.nD[i][j] = A.nD[i][j] + B.nD[i][j];
        }
    }
    return C;
}

Matrix operator*(const Matrix nA, const Matrix nB)
{
    Matrix nC(nB.nSize);
    for (int i = 0; i < nA.nSize; ++i)
    {
        for (int j = 0; j < nA.nSize; ++j)
        {
            for (int k = 0; k < nA.nSize; ++k)
            {
                nC.nD[i][j] += nA.nD[i][k] * nB.nD[k][j];
            }
        }
    }
    return nC;
}

Matrix operator^(Matrix B, INT nExp)
{
    Matrix ans(B.nSize);

    ans.Unit();
    while (nExp)
    {
        if (nExp % 2)
        {
            ans = ans * B;
        }
        B = B * B;
        nExp >>= 1;
    }
    return ans;
}

//求base^1+base^2++base^N
Matrix SumPowMatrix(Matrix base, INT nN)
{
    if (nN == 1)
    {
        return base;
    }

    Matrix ans = SumPowMatrix(base, nN / 2);
    ans = ans + ((base^(nN / 2)) * ans);//重载运算符保证不了优先级
    if (nN % 2)
    {
        ans = ans + (base^nN);//没优先级啊,必须加括号,查错2个小时了
    }
    return ans;
}

struct Trie
{
    Trie* next[MAX_D];
    Trie* fail;
    int no;
    bool flag;
};
Trie tries[MAX_L * MAX_N];
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

void Insert(Trie* pRoot, char* pszPat)
{
    Trie* pNode = pRoot;
    while (*pszPat)
    {
        int idx = *pszPat - 'a';
        if (pNode->next[idx] == NULL)
        {
            pNode->next[idx] = NewNode();
        }
        pNode = pNode->next[idx];
        ++pszPat;
    }
    pNode->flag = true;
}

void BuildAC(Trie* pRoot, Matrix M)
{
    pRoot->fail = NULL;
    queue<Trie*> qt;
    qt.push(pRoot);

    M.Clear(nP);
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
                if (front->next[i]->fail->flag)
                {
                    front->next[i]->flag = true;
                }
                qt.push(front->next[i]);
            }
            else
            {
                front->next[i] = front == pRoot? pRoot : front->fail->next[i];
            }

            //这里必须要加上front->flag为false的判断么?加不加会生成不同的矩阵
            if (!front->next[i]->flag)
            {
                ++M.nD[front->no][front->next[i]->no];
            }
        }
    }
}

int main()
{
    int nN;
    INT nL;
    Matrix M(0);

    while (scanf("%d%I64u", &nN, &nL) == 2)
    {
        InitTrie(pRoot);
        while (nN--)
        {
            scanf("%s", szPat);
            Insert(pRoot, szPat);
        }
        BuildAC(pRoot, M);

        Matrix tmp(1);
        tmp.nD[0][0] = 26;
        tmp = SumPowMatrix(tmp, nL);
        INT nAns = tmp.nD[0][0];
        Matrix msum = SumPowMatrix(M, nL);
        for (int i = 0; i < msum.nSize; ++i)
        {
            nAns -= msum.nD[0][i];
        }
        printf("%I64u\n", nAns);
    }

    return 0;
}
```