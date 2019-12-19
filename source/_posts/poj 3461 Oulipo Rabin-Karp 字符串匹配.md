---
title: poj 3461 Oulipo Rabin-Karp 字符串匹配
tags:
  - 字符串
id: 268
categories:
  - ACM-ICPC
date: 2012-09-28 10:00:00
---

裸的字符串匹配，子串最长10,000，母串最长1,000,000。
求子串在母串中出现的次数。
如果子串长度较小，那么直接RK匹配即可，hash值相同时候，直接比较字符串是否相同。
但是这个题的子串太长了，还比较字符串会超时，如果不比较字符串理论上是错误的，虽然
出错的概率很小，而且概率还是跟模数的选择以及运算时候是否溢出有关。
刚开始用了int，发现一直wa了，估计就是运算时候就超int了，取模没起到作用。模数的选
择能够提高正确率。Rabin-Karp 字符串匹配虽然比较好写，也很容易理解，但是适用情况感
觉不是很广，比如子串太长了，处理就麻烦了，舍弃子串比较也不是很好。
但是子串不长的话，Rabin-Karp 字符串匹配还是很不错的。
相比而言，这个题用kmp应该会好很多。

代码如下：
``` stylus
#include <stdio.h> 
#include <string.h>
#include <algorithm>
using namespace std;

typedef long long INT;
char szStrM[1000010];
char szStrS[10010];
const INT MOD = 16381 * 4733 + 1;

int main()
{
    int nT;

    scanf("%d", &nT);
    while (nT--)
    {
        scanf("%s%s", szStrS, szStrM);
        INT nMatch = szStrS[0] - 'A';
        INT nPowN = 1;
        int nSizeS = 1;
        char* pszStr = szStrS + 1;
        while (*pszStr)
        {
            nMatch = (26 * nMatch + *pszStr - 'A') % MOD;
            nPowN = (nPowN * 26) % MOD;
            ++nSizeS;
            ++pszStr;
        }
        //prINTf("match:%d\n", nMatch);

        int nSizeM = strlen(szStrM);
        INT nKey = 0;
        for (int i = 0; i < nSizeS; ++i)
        {
            nKey = (26 * nKey + szStrM[i] - 'A') % MOD;
        }
        //prINTf("key:%d\n", nKey);

        int nAns = 0;
        for (int i = 0; i <= nSizeM - nSizeS; ++i)
        {
            //prINTf("key:%d\n", nKey);
            if (nKey == nMatch)
               //  memcpy(szStrS, szStrM + i, nSizeS) == 0)
            {
                ++nAns;
            }
            nKey = (26 * (nKey - nPowN * (szStrM[i] - 'A')) % MOD
                    + szStrM[i + nSizeS] - 'A') % MOD;
            nKey = (nKey + MOD) % MOD;
        }

        printf("%d\n", nAns);
    }

    return 0;
}
```