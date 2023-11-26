---
title: poj 1401 Factorial
tags:
id: 223
categories:
  - 算法 
  - 算法题
date: 2012-07-16 21:30:00
---

这个题目是求N！后面有多少个0，注意N可能最大到10的9次。哈哈，直接枚举1-N有多少个2和5的因子，然后取小的值肯定会超时的。但是，我还是试了下，果断超时了。
那就只有想数学结论了，果断想到1-N中能被2整除的数字有N / 2。哈哈，再往后思考下，发现1-N中能被4整除的数字有N / 4个，再往后就是N / 8，一直到N 除以2的某个次方为0为止，那么把所有的值加起来就是2的因子的个数了。求5的因子的个数也是这样的方法了。
很明显，5的因子的个数一定会小于等于2的因子的个数。那么直接求5的因子的个数就行了。由于，N / 5的时候用到了向下取整，所以不能用等比数列求和公式，怎么把答案弄成一个公式，还不知道了。
PS：其实我这种思路的灵感来自于筛选素数的方法了。

代码如下：
``` stylus
#include <stdio.h>
#include <algorithm>
#include <math.h>
using namespace std;

int GetAns(int nN)
{
    int nAns = 0;
    while (nN)
    {
        nAns += nN / 5;
        nN /= 5;
    }
    return nAns;
}

int main()
{
    int nT;

    scanf("%d", &nT);
    while (nT--)
    {
        int nN;
        scanf("%d", &nN);
        printf("%d\n", GetAns(nN));
    }

    return 0;
}
```