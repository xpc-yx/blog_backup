---
title: poj 1226 Substrings 后缀数组
tags:
  - 后缀数组
id: 297
categories:
  - ACM-ICPC
date: 2012-10-23 12:30:00
---

求N个字符串最长的公共子串。这题数据比较水，暴力第一个字符串的子串也可以过。初学后缀数组，有很多不明白的东西，此题后缀数组的代码在网上也是一把抓。
说实话我确实还不懂后缀数组，但是后缀数组太强大了，只能硬着头皮照着葫芦画瓢了。贴下代码方便以后查阅吧。。。
感觉后缀数组的应用最主要的还是height数组，看懂倍增算法排序后缀已经非常困难了。然后再理解height数组怎么用也不是一件容易的事情。然后貌似height数组最关键的用法是枚举某一个长度的子串时候，比如长度为k，能够用这个k对height数组进行分组，这个罗穗骞的论文里面有个求不重叠最长重复子串的例子说明了这个height数组分组的思路，不过我现在还是不怎么理解。。。

``` stylus
#include <stdio.h>
#include <string.h>
#include <algorithm>
using namespace std;

const int MAX_N = 110;
const int MAX_L = MAX_N * MAX_N;
char szStr[MAX_N];
int nNum[MAX_L];
int nLoc[MAX_L];
bool bVisit[MAX_N];
int sa[MAX_L], rank[MAX_L], height[MAX_L];
int wa[MAX_L], wb[MAX_L], wv[MAX_L], wd[MAX_L];

int cmp(int* r, int a, int b, int l)
{
    return r[a] == r[b]  r[a + l] == r[b + l];
}

//倍增算法,r为待匹配数组,n为总长度,m为字符串范围
void da(int* r, int n, int m)
{
    int i, j, p, *x = wa, *y = wb;

    for (i = 0; i < m; ++i) wd[i] = 0;
    for (i = 0; i < n; ++i) wd[x[i] = r[i]]++;
    for (i = 1; i < m; ++i) wd[i] += wd[i - 1];
    for (i = n - 1; i >= 0; --i) sa[--wd[x[i]]] = i;

    for (j = 1, p = 1; p < n; j *= 2, m = p)
    {
        for (p = 0, i = n - j; i < n; ++i) y[p++] = i;
        for (i = 0; i < n; ++i) if (sa[i] >= j) y[p++] = sa[i] - j;

        for (i = 0; i < n; ++i) wv[i] = x[y[i]];
        for (i = 0; i < m; ++i) wd[i] = 0;
        for (i = 0; i < n; ++i) wd[wv[i]]++;
        for (i = 1; i < m; ++i) wd[i] += wd[i - 1];
        for (i = n - 1; i >= 0; --i) sa[--wd[wv[i]]] = y[i];

        swap(x, y);
        for (p = 1, x[sa[0]] = 0, i = 1; i < n; ++i)
        {
            x[sa[i]] = cmp(y, sa[i - 1], sa[i], j)? p - 1 : p++;
        }
    }
}

//求height数组
void calHeight(int* r, int n)
{
    int i, j, k = 0;
    for (i = 1; i <= n; ++i) rank[sa[i]] = i;
    for (i = 0; i < n; height[rank[i++]] = k)
    {
        if (k) --k;
        for(j = sa[rank[i] - 1]; r[i + k] == r[j + k]; k++);
    }
}

bool Check(int nMid, int nLen, int nN)
{
    int nCnt = 0;

    memset(bVisit, false, sizeof(bVisit));
    for (int i = 2; i <= nLen; ++i)
    {
        if (nMid > height[i])
        {
            nCnt = 0;
            memset(bVisit, false, sizeof(bVisit));
            continue;
        }
        if (!bVisit[nLoc[sa[i - 1]]])
        {
            bVisit[nLoc[sa[i - 1]]] = true;
            ++nCnt;
        }
        if (!bVisit[nLoc[sa[i]]])
        {
            bVisit[nLoc[sa[i]]] = true;
            ++nCnt;
        }
        if (nCnt == nN) return true;
    }

    return false;
}

int main()
{
    int nT;

    scanf("%d", &nT);
    while (nT--)
    {
        int nN;
        int nEnd = 300;
        int nP = 0;
        scanf("%d", nN);
        for (int i = 1; i <= nN; ++i)
        {
            scanf("%s", szStr);
            char* pszStr;
            for (pszStr = szStr; *pszStr; ++pszStr)
            {
                nLoc[nP] = i;
                nNum[nP++] = *pszStr;
            }
            nLoc[nP] = nEnd;
            nNum[nP++] = nEnd++;

            reverse(szStr, szStr + strlen(szStr));
            for (pszStr = szStr; *pszStr; ++pszStr)
            {
                nLoc[nP] = i;
                nNum[nP++] = *pszStr;
            }
            nLoc[nP] = nEnd;
            nNum[nP++] = nEnd++;
        }
        nNum[nP] = 0;

        da(nNum, nP + 1, nEnd);
        calHeight(nNum, nP);

        int nLeft = 1, nRight = strlen(szStr), nMid;
        int nAns = 0;
        while (nLeft <= nRight)
        {
            nMid = (nLeft + nRight) / 2;
            if (Check(nMid, nP, nN))
            {
                nLeft = nMid + 1;
                nAns = nMid;
            }
            else nRight = nMid - 1;
        }
        printf("%d\n", nAns);
    }

    return 0;
}
```