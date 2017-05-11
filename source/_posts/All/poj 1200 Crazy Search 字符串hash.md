---
title: poj 1200 Crazy Search 字符串hash
tags:
  - 字符串hash
id: 266
categories:
  - 算法
  - 字符串
date: 2012-09-27 10:00:00
---

这个题是求一个字符串里面出现了多少个长度为N的不同子串，同时给出了母串里面不同字符
的个数NC。
保存子串到set里面直接暴力肯定超时了。这个题有个利用字符串hash的解法，虽然理论上有
bug，但是能过这个题。
利用给出的NC，对长度为N的字符串，将其当作NC进制的数字，求出其值，对值进行hash，
求出不同的hash位置个数。
这个算法其实类似于Karp-Rabin字符串匹配算法。不过，Karp-Rabin算法做了点改进，对
进制为D的字符串求值的时候为了防止溢出会模一个素数，而且不会每次都迭代求下一个子串的
值，而是从当前子串的值直接递推出下一个字符的值。怎么递推了，其实很简单，就是当前值去
掉最高位再乘以D(相当于左移一位,不过是D进制的，不能直接用<<符号)，再加上新的最低位。
Karp-Rabin算法应该主要在于设计出合理的hash算法，比如，用取模hash函数的话，得保
证hash表足够大，否则冲突太多，速度就不会怎么好了。比如这个题，hash表小了就AC不了了。

代码如下：
``` stylus
#include <stdio.h>
#include <string.h>

const int MAX = 13747347;
int nHash[MAX];
char szStr[17000001];
int nN, nNC;
int nW[200];

void Insert(int nKey)
{
    int nPos = nKey;
    while (nHash[nPos] != -1  nHash[nPos] != nKey)
    {
        nPos = (nPos + 1) % MAX;
    }
    nHash[nPos] = nKey;
}

bool Find(int nKey)
{
    int nPos = nKey;
    while (nHash[nPos] != -1 && nHash[nPos] != nKey)
    {
        nPos = (nPos + 1) % MAX;
    }
    return nHash[nPos] != -1;
}

int main()
{
    while (scanf("%d%d%s", &nN, &nNC, szStr) == 3)
    {
        memset(nW, 0, sizeof(nW));
        memset(nHash, -1, sizeof(nHash));
        int nNum = 0;
        int nSize = 0;
        for (char* pszStr = szStr; *pszStr; ++pszStr)
        {
            if (!nW[*pszStr])
            {
                nW[*pszStr] = ++nNum;
            }
            ++nSize;
        }

        int nKey = 0;
        int nAns = 0;
        int nPowN = 1;
        for (int j = 0; j < nN; ++j)
        {
            nKey = (nKey * nNC + nW[szStr[j]]) % MAX;
            nPowN *= nNC;
        }
        nPowN /= nNC;
        if (!Find(nKey))
        {
            Insert(nKey);
            nAns++;
        }

        for (int i = nN; i < nSize; ++i)
        {
            nKey = (nNC * (nKey - nPowN * nW[szStr[i - nN]])
                    + nW[szStr[i]]) % MAX;
            nKey = (nKey + MAX) % MAX;

            if (!Find(nKey))
            {
                Insert(nKey);
                nAns++;
            }
        }

        printf("%d\n", nAns);
    }

    return 0;
}
```