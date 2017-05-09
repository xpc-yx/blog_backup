---
title: poj 3294 Life Forms 后缀数组求至少出现在K个字符串中的最长公共子串
tags:
  - 后缀数组
id: 299
categories:
  - 字符串
date: 2012-10-24 13:30:00
---

此题就是给出N个字符串，然后求一个最长的子串，它至少出现在N/2+1个字符串中，如果有多个这样的子串，按字典序输出，如果没有这样的子串，输出?。
此题是罗穗骞论文里面的例11，他有讲述具体的解法。要用后缀数组做这样的题真不容易，用后缀数组就感觉是一件非常纠结的事情了。
这个题的解法还是那种模式化的思路。把N个字符串连接成一个，注意中间加不出现在任何一个字符串中的分隔符，然后建立sa数组和height数组等。最后二分答案，根据答案，即子串的长度对height数组进行分组，分组的思路还是罗穗骞论文里面例3的思路，即从到后枚举height数组，把连续大于等于答案的值放做一组，一旦小于答案那么就是新的分组。这个题需要找到一些分组，其中的后缀是能够出现在N个原串中，这个分组的公共前缀就是sa[i]开始的nMid个字符了(nMid是二分时候获得的子串长度)。由于这个题需要按字典序输出多个满足要求的子串，所以麻烦了点。需要在Check函数里面记录这些子串，而且输出答案的时候需要排序，再unique，由于是按height数组的顺序查找的，而sa[i]已经排好序了，所以排序答案的过程可以省略，但是必须unique。想下Check函数里面遍历height数组的过程就知道可能出现重复的子串。。。

代码如下：
``` stylus
#include <stdio.h>
#include <string.h>
#include <algorithm>
using namespace std;
const int MAX_N = 110;
const int MAX_L = 1010;
const int MAX = MAX_N * MAX_L;
int nAns;
char szStr[MAX_L];
char szAns[MAX][MAX_L];
char* pszAns[MAX];
int nNum[MAX];
int nLoc[MAX];
bool bVis[MAX_N];
int sa[MAX], rank[MAX], height[MAX];
int wa[MAX], wb[MAX], wv[MAX], wd[MAX];
bool CmpStr(const char* pszOne, const char* pszTwo)
{
    return strcmp(pszOne, pszTwo) < 0;
}
bool EqualStr(const char* pszOne, const char* pszTwo)
{
    return strcmp(pszOne, pszTwo) == 0;
}
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
bool Check(int nMid, int nN, int nK)
{
    int nCnt = 0;
    int nNo = 0;

    memset(bVis, false, sizeof(bVis));
    for (int i = 1; i <= nN; ++i)
    {
        if (height[i] < nMid)
        {
            nCnt = 0;
            memset(bVis, false, sizeof(bVis));
        }
        else
        {
            if (!bVis[nLoc[sa[i - 1]]])
            {
                ++nCnt;
                bVis[nLoc[sa[i - 1]]] = true;
            }
            if (!bVis[nLoc[sa[i]]])
            {
                ++nCnt;
                bVis[nLoc[sa[i]]] = true;
            }
            if (nCnt == nK)
            {
                for (int j = 0; j < nMid; ++j)
                {
                    szAns[nNo][j] = nNum[sa[i] + j];
                }
                szAns[nNo][nMid] = 0;
                ++nNo;
                nCnt = 0;
            }
        }
    }

    if (nNo > 0) nAns = nNo;
    return nNo > 0;
}
int main()
{
    int nN;
    bool bFirst = true;

    while (scanf("%d", &nN), nN)
    {
        if (bFirst) bFirst = false;
        else putchar('\n');

        int nEnd = 300;
        int nP = 0;
        for (int i = 0; i < nN; ++i)
        {
            scanf("%s", szStr);
            int nLen = strlen(szStr);
            for (int j = 0; j < nLen; ++j)
            {
                nNum[nP] = szStr[j];
                nLoc[nP++] = i;
            }
            nNum[nP] = nEnd;
            nLoc[nP++] = nEnd++;
        }
        nNum[nP] = 0;

        if (nN == 1)
        {
            printf("%s\n\n", szStr);
            continue;
        }
        da(nNum, nP + 1, 500);//500是估计的字符集大小
        calHeight(nNum, nP);

        int nLeft = 1, nRight = strlen(szStr);
        int nTemp = 0, nMid;
        int nK = nN / 2 + 1;
        nAns = 0;
        while (nLeft <= nRight)
        {
            nMid = (nLeft + nRight) >> 1;
            if (Check(nMid, nP, nK))
            {
                nTemp = nMid;
                nLeft = nMid + 1;
            }
            else nRight = nMid - 1;
        }
        if (nTemp == 0)
        {
            printf("?\n");
        }
        else
        {
            for (int i = 0; i < nAns; ++i)
            {
                pszAns[i] = szAns[i];
            }
            //sort(pszAns, pszAns + nAns, CmpStr);
            nAns = unique(pszAns, pszAns + nAns, EqualStr) - pszAns;
            for (int i = 0; i < nAns; ++i)
            {
                printf("%s\n", pszAns[i]);
            }
        }
    }

    return 0;
}
```