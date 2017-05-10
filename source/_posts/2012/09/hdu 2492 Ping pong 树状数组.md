---
title: hdu 2492 Ping pong 树状数组
tags:
  - 树状数组
id: 256
categories:
  - 算法
  - 数据结构
date: 2012-09-12 10:00:00
---

此题是求一个数字序列中，长度为3的子序列(a,b,c)，且满足条件a<=b<=c或者c<=b<=a的子序列的个数。
明显枚举每个b，求每个b左边的a的个数和右边c的个数，以及左边c的个数和右边a的个数，然后累加左右乘积求和即可。刚开始只求了满足条件a<=b<=c的部分，而且忘记用64位了。wa了几次。求左边a的个数其实就是求小于等于b的数字的个数，这个刚好可以用树状数组或者线段树求。具体见代码。

代码如下：
``` stylus
#include <stdio.h>
#include <string.h>
#include <algorithm>
using namespace std;
typedef long long INT;
const INT MAX_N =  100010;
const INT N = 20010;
INT nN;
INT nNum[N];
INT nTree[MAX_N + 10];
INT nLeft[2][N], nRight[2][N];

INT LowBit(INT nI)
{
    return nI  & (-nI);
}

void Add(INT nI, INT nAdd)
{
    while (nI <= MAX_N)
    {
        nTree[nI] += nAdd;
        nI += LowBit(nI);
    }
}

INT Query(INT nPos)
{
    INT nAns = 0;
    while (nPos > 0)
    {
        nAns += nTree[nPos];
        nPos -= LowBit(nPos);
    }
    return nAns;
}

int main()
{
    INT nT;

    scanf("%I64d", &nT);
    while (nT--)
    {
        scanf("%I64d", &nN);
        memset(nTree, 0, sizeof(nTree));
        for (INT i = 1; i <= nN; ++i)
        {
            scanf("%I64d", nNum[i]);
            nLeft[0][i] = Query(nNum[i]);
            nLeft[1][i] = Query(MAX_N) - Query(nNum[i] - 1);
            Add(nNum[i], 1);
        }
        memset(nTree, 0, sizeof(nTree));
        for (INT i = nN; i >= 1; --i)
        {
            nRight[0][i] = Query(MAX_N) - Query(nNum[i] - 1);
            nRight[1][i] = Query(nNum[i]);
            Add(nNum[i], 1);
        }
        INT nAns = 0;
        for (INT i = 1; i <= nN; ++i)
        {
            nAns += nLeft[0][i] * nRight[0][i] + nLeft[1][i] * nRight[1][i];
        }
        printf("%I64d\n", nAns);
    }

    return 0;
}
```