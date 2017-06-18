---
title: poj 1284 Primitive Roots
tags:
  - 原根的个数
id: 231
categories:
  - ACM-ICPC
date: 2012-07-25 16:30:00
---

这个题是求原根的个数。所谓原根，意思是给定一个数n，存在数g，g^j能够产生乘法群Zn*中所有的数字。即g^j = {x|x与n互质,1<=x<n}。如果n是奇素数p(大于2的素数)，那么满足g^j={1,2,...,p-1}。
这个题目要求求原根的个数。由费马定理由,对任意1<=x<p，即Zp*中的数字，都由x^(p-1) = 1 % p。从费马定理可以看出，再往下计算就开始循环了。那么有,x^i%p(1<=i<p) = {1, 2, 3,...,p-1},意思是能够生成Zp*中的所有数字。
根据上面的那个式子可以得到，x^i%(p-1)(1<=i<p) = {0, 1, 2,...,p-2}。 如果由gcd(x,p-1) = 1,那么必然存在某个x^i，使得x^i*x = (p-1)%p。
因此可以得到，原根的个数是p-1的乘法群中元素的个数，也就是欧拉函数(p-1)。

代码如下：
``` stylus
#include <stdio.h>
#include <math.h>
#define MAX (5000000)
bool bPrime[MAX];
void InitPrime()
{
    int nMax = sqrt((double)MAX) + 1;
    bPrime[0] = bPrime[1] = true;
    for (int i = 2; i <= nMax; ++i)
    {
        if (!bPrime[i])
        {
            for (int j = 2 * i; j < MAX; j += i)
            {
                bPrime[j] = true;
            }
        }
    }
}
bool IsPrime(int nN)
{
    if (nN < MAX)return !bPrime[nN];
    int nMax = sqrt((double)nN) + 1;
    for (int i = 2; i <= nMax; ++i)
    {
        if (nN % i == 0)
            return false;
    }
    return true;
}
int main()
{
    int nN;
    InitPrime();
    while (scanf("%d", &nN) == 1)
    {
        nN--;
        int nAns = 1;
        if (IsPrime(nN))
        {
            nAns = nN - 1;
        }
        else
        {
            for (int i = 2; i <= nN; ++i)
            {
                if (nN % i == 0)
                {
                    nAns *= i - 1;
                    nN /= i;
                    while (nN % i == 0)
                    {
                        nAns *= i;
                        nN /= i;
                    }
                    if (IsPrime(nN))
                    {
                        nAns *= nN - 1;
                        break;
                    }
                }
            }
        }
        printf("%d\n", nAns);
    }
    return 0;
}
```