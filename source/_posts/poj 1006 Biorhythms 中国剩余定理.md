---
title: poj 1006 Biorhythms 中国剩余定理
tags:
  - 数论
id: 272
categories:
  - 算法
  - 算法题
date: 2012-10-03 10:30:00
---

此题本来模拟即可，但是注意有容易出错的地方。
这题主要是可以用中国剩余定理来做。
根据题意可以抽象出这样的模型。给出三个数A,B,C分别是模23,28,33后的余数，求最小的数字
使得其模23,28,33分别为A,B,C，并且要大于给定的数字D。
中国剩余定理很好的解决了这种余数问题。令模数为Ni,余数为Ai,设Mi = N1*N2*...*Ni-1*Ni+1*...*Nn，
那么答案一定满足形式ans = <span>Σ</span>Ai*Mi*(Mi对Ni的乘法逆) % N。(N为所有Ni的乘积)。
很明显，由于ans的第i项有Mi因子，所以模N1-Ni-1和Ni+1-Nn肯定是0，而Ai*Mi*(Mi对Ni的乘法逆) %Ni就是Ai。这样就满足了要求。
代码如下：
``` stylus
#include <stdio.h>
#include <algorithm>
#include <string.h>
#include <vector>
using namespace std;

int Egcd(int nN, int nM, int nX, int nY)
{
    if (nM == 0)
    {
        nX = 1, nY = 0;
        return nN;
    }
    int nRet = Egcd(nM, nN % nM, nX, nY);
    int nT = nX;
    nX = nY;
    nY = nT - (nN / nM) * nY;
    return nRet;
}

int main()
{
    int nA, nB, nC, nD;
    int nDays = 21252;
    int nCase = 1;

    while (scanf("%d%d%d%d", &nA, &nB, &nC, &nD),
            nA != -1 || nB != -1 || nC != -1 || nD != -1)
    {
        int nFirst = 0;
        nA %= 23;
        nB %= 28;
        nC %= 33;
        int nM1= 28 * 33, nM2 = 23 * 33, nM3 = 23 * 28;
        int nN1, nN2, nN3, nTemp;
        Egcd(23, nM1, nTemp, nN1);
        Egcd(28, nM2, nTemp, nN2);
        Egcd(33, nM3, nTemp, nN3);
        nFirst = (nA * nM1 * nN1 + nB * nM2 * nN2 + nC * nM3 * nN3) % nDays;
        while (nFirst <= nD)nFirst += nDays;
        printf("Case %d: the next triple peak occurs in %d days.\n",
               nCase++, nFirst - nD);
    }

    return 0;
}
```