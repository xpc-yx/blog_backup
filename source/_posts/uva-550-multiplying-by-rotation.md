---
title: uva 550 - Multiplying by Rotation
tags:
  - 数学
  - 递归
id: 176
categories:
  - ACM-ICPC
date: 2012-05-08 21:30:00
---

这也是一个数学题，刚开始还真以为好难的样子，需要用到什么数论的理论啊。其实，只要去找规律就行了。
题意是给出一个进制，一个数字的最低位，和另外的一个数字，比如10进制，第一个数字的最低位是7，第二个数字是4，根据这些信息，和规则（XXXXX7 * 4 = 7XXXXX，例子: 179487 * 4 = 717948 ）求出第一个数字的最小长度。这个规则的意思是乘积是把第一个数字的最低位移动到最高位上去就行了。
貌似很难的样子，其实用笔在纸上求一下XXXXX7 * 4 = 7XXXXX就会发现。XXXXX7的每一位都是能够确定的，当然顺序是从最低位到最高位开始。因为知道最低位，所以次低位一定是最低位*第二个数%base。以此类推，递归下去即可。最终条件是，没有进位了，而且乘积+原来的进位==最低位。
我用的递归完全可以改成循环的形式，这样速度应该会快些。

代码如下：

``` stylus

#include <stdio.h>

int nBase;
int nTwo;
int nOneLow;

int GetMin(int nLow, int nCarry, int nNum)
{
    //printf("nLow:%d, nCarry:%d, nNum:%d\n", nLow, nCarry, nNum);
    int nTemp = nCarry + nLow * nTwo;
    if (nTemp == nOneLow)
    {
        return nNum;
    }

    return GetMin(nTemp % nBase, nTemp / nBase, nNum + 1);
}

int main()
{
    //freopen("out.txt", "w", stdout);
    while (scanf("%d%d%d", &nBase, &nOneLow, &nTwo) == 3)
    {
        printf("%d\n", GetMin(nOneLow, 0, 0) + 1);
    }

    return 0;
}

```