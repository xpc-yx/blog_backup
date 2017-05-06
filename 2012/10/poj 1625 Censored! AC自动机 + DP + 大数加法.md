---
title: poj 1625 Censored! AC自动机 + DP + 大数加法
tags:
  - AC自动机
  - dp
  - 大数加法
id: 293
categories:
  - 字符串
date: 2012-10-20 18:30:00
---

这个题与poj2778dna sequence解法基本一致。只是这个题的答案没有取模，而且文本串不太长。问题是不取模的话就只能输出实际的答案了，就只能用大数了。
而且用大数的话，再用矩阵冥可能就会超时之类的。
这类题还可以用除矩阵冥外的另外一种解法，就是直接dp即可。二维状态，第一维代表文本串长度，第二维代表在AC自动机中的状态。比如dp[i][j]代表长度为i的文本串，转移到Trie图中节点j时候满足不包含任何模式串的答案。剩下的是如何转移状态。转移的话也是考虑next指针数组，设next = tries[j].next[k]，那么有dp[i+1][next] =dp[i+1][next] + dp[i][j]，从0到字母集合大小N枚举k即可。
这个题有一个易错的地方，就是字母集合可能是ascii码在128到256的范围内。而char的范围可能是-128到127或者0到255，这个是根据编译器不同的。所以，直接用字符串数组读入数据后需要再处理下。可以直接将每个字符加128后再处理。
另外，getchar返回的是int，但是与gets之类的函数获得的值的差别也不是那么确定的了。觉得getchar除了对eof之外其余都返回正值。但是，如果char是有符号的话，scanf或者gets之类得到的char数组里面可能就包含负值了。。。
这个可以生成随机文件，再用getchar读入并用%d输出其返回值验证下。验证程序如下：注释掉的部分是生成随机文件的部分。

``` stylus
#include <stdio.h>
#include <stdlib.h>

int main()
{
    char ch;
    freopen("in.txt", "r", stdin);
    //freopen("in.txt", "w", stdout);
    int nNum = 100;
    int nCh;
    do
    {
        printf("%d\n", nCh = getchar());
    }
    while (nCh != EOF);
    /*while (nNum--)
    {
        putchar(rand() % 256);
    }*/

    return 0;
}
```
该题的代码如下：
``` stylus
#include <stdio.h>
#include <string.h>
#include <queue>
#include <algorithm>
using namespace std;

const int MAX_D = 256;
const int MAX_N = 51;
const int MAX_M = 51;
const int MAX_P = 11;
struct Trie
{
    Trie* fail;
    Trie* next[MAX_D];
    int no;
    bool flag;
};
Trie tries[MAX_P * MAX_P];
int nP;
int nN, nM;
Trie* pRoot;
int nHash[MAX_D];
char szPat[MAX_M];

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
        int idx = nHash[*pszPat];
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

        for (int i = 0; i < nN; ++i)
        {
            if (front->next[i])
            {
                Trie* pNode = front;
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
                front->next[i] = front->fail->next[i];
            }
        }
    }
}

const int MAX_L = 200;
struct BigInt
{
    int nD[MAX_L];
    BigInt()
    {
        Clear();
    }
    void Clear()
    {
        memset(nD, 0, sizeof(nD));
    }

    void Print()
    {
        int i = MAX_L - 1;
        while (!nD[i] && i)--i;
        while (i >= 0)
        {
            putchar(nD[i] + '0');
            --i;
        }
    }
    int operator[](int idx) const
    {
        return nD[idx];
    }

    int operator[](int idx)
    {
        return nD[idx];
    }
};
BigInt bi[MAX_M][MAX_D];

BigInt operator+(const BigInt one, const BigInt two)
{
    BigInt ret;

    for (int i = 0, nAdd = 0; i < MAX_L; ++i)
    {
        ret[i] = one[i] + two[i] + nAdd;
        nAdd = ret[i] / 10;
        ret[i] %= 10;
    }

    return ret;
}

void Solve()
{
    BigInt ans;
    for (int i = 0; i <= nM; ++i)
    {
        for (int j = 0; j < nP; ++j)
        {
            bi[i][j].Clear();
        }
    }
    bi[0][0][0] = 1;

    for (int i = 1; i <= nM; ++i)
    {
        for (int j = 0; j < nP; ++j)
        {
            if (tries[j].flag) continue;
            for (int k = 0; k < nN; ++k)
            {
                int nNext = tries[j].next[k] - tries;
                if (tries[nNext].flag == false)
                {
                    bi[i][nNext] = bi[i][nNext] + bi[i - 1][j];
                }
            }
        }
    }

    for (int i = 0; i < nP; ++i)
    {
        ans = ans + bi[nM][i];
    }
    ans.Print();
    printf("\n");
}

int main()
{
    int nT;

    while (scanf("%d%d%d%*c", &nN, &nM, &nT) == 3)
    {
        int nCh;
        int nTmp = 0;
        memset(nHash, 0, sizeof(nHash));
        while (nCh = getchar(), nCh != '\n')
        {
            if (!nHash[nCh])
            {
                nHash[nCh] = nTmp++;
            }
        }
        InitTrie(pRoot);
        while (nT--)
        {
            gets(szPat);
            Insert(pRoot, szPat);
        }
        printf("1");
        BuildAC(pRoot);
        printf("2");
        Solve();
    }

    return 0;
}
```