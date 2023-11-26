---
title: hdu 4294 Multiple 数论 + bfs
tags:
  - 搜索
  - 数论
id: 262
categories:
  - 算法
  - 算法题
date: 2012-09-18 10:00:00
---

这是前天成都网赛的题，比赛时候确实一点思路也没有。比完之后看了人家的解题报告，还是不会怎么搜出答案，太弱了。
题意是给出N,K，求M，使得M是N的正倍数，而且M用K进制表示后所需要的不同数字(0,1,2,3,...,k-1)最少，如果有多组这样的情况，求出最小的M。很数学的题意。
用到了一个结论，就是任意数字的正倍数均可以用不超过2个不同数字的数得到。
证明如下：
任意数M % N 总共有N种结果，假如有N+1个不同的M，那么肯定有2个M对N取模后的结果是相同，这个是所谓鸽巢原理。那么，我取a,aa,aaa,...,aaaaaaaaaa....，总共N+1个，同样满足上面的结论。那么我取那2个对N取模相同的数字相减得到数字aaaaa...000....，这个数字肯定是N的倍数。
综合上面的证明，只能得到2个数字肯定能表示N的倍数。但是不能说形式就是aaaaa...000....。

到了这里我还是一点思路都没有，一点都不知道怎么搜索。。。
想了1个多小时，无头绪，问过了这题的同学，还是无头绪。看解题报告，他们的代码写得太牛了，完全看不懂，无头绪。也许也是我对bfs理解太浅，才看不懂他们的搜索代码。而且，我连可以搜索的地方都没有找到，都不知道搜什么了。
想了好久，昨天吃饭的时候，终于发现可以对余数进行搜索。
对于任意的N，其余数就是范围是[0, N -1]。这个其实就可以代表状态了，或者代表bfs中的点了。从当前余数转移到其它余数的是MOD * K +  A 或者 MOD * K + B，如果要转移到得余数以前没被搜过，那就可以转移过去。这个刚好就是一个优化了。也可以看成是子问题了。但是，dfs完全不行。刚开始用dfs，绝对的超时。
用dfs也是我对思路理解不深，侥幸认为能过。。。后面发现，这题完全和bfs吻合。[0, N -1]刚好代表N个点，我要通过从外面的一个点，最短的遍历到点0，可以bfs或者最短路算法。这题我觉得还有个难点就是保存答案，因为答案最长的长度可能是N(N<=10000)，所以把答案直接放到节点里面肯定不行的。但是，我还仔细看过算法导论。因此想到了可以利用bfs搜索出来的那颗树或者最短路算法跑出来的那颗树，从目标节点逆序寻找答案，找到出发节点之后，再把答案reverse一下就行了。
这题还得注意0不能是N的倍数，所以注意bfs(0,i)这种情况的处理。

代码如下：
``` stylus
#include <stdio.h>
#include <string.h>
#include <queue>
#include <algorithm>
using namespace std;

const int MAX_N = 10010;
int nOut[MAX_N];
int nOLen;
int nAns[MAX_N];
int nALen;
bool bMod[MAX_N];
int nFather[MAX_N];
int nChoose[MAX_N];
int nN;
int nK;
bool bFind;

int Cmp(int* A, int nLA, int* B, int nLB)
{
    if (nLA != nLB)
    {
        return nLA - nLB;
    }
    for (int i = 0; i < nLA; ++i)
    {
        if (A[i] != B[i])
        {
            return A[i] - B[i];
        }
    }
    return 0;
}

void Bfs(int nA, int nB)
{
    memset(bMod, false, sizeof(bMod));
    queue<int> que;
    que.push(0);
    int nTemp;
    bool bFirst = true;
    bFind = false;

    if (nA > nB)swap(nA, nB);
    //printf("nA:%d, nB:%d\n", nA, nB);
    while (!que.empty())
    {
        //printf("nMod:%d\n", que.front());
        int nMod = que.front();
        que.pop();
        if (nMod == 0)
        {
            if (bFirst)bFirst = false;
            else
            {
                bFind = true;
                break;
            }
        }

        nTemp = (nMod * nK + nA) % nN;
        if (!(nMod == 0  nA == 0)  !bMod[nTemp])
        {
            nFather[nTemp] = nMod;
            nChoose[nTemp] = nA;
            que.push(nTemp);
            bMod[nTemp] = true;
            //printf("nTemp:%d\n", nTemp);
        }
        if (nA == nB)continue;
        nTemp = (nMod * nK + nB) % nN;
        if (!bMod[nTemp])
        {
            nFather[nTemp] = nMod;
            nChoose[nTemp] = nB;
            que.push(nTemp);
            bMod[nTemp] = true;
            //printf("nTemp:%d\n", nTemp);
        }
    }

    if (bFind)
    {
        int nF = 0;
        nALen = 0;
        do
        {
            nAns[nALen++] = nChoose[nF];
            nF = nFather[nF];
        }
        while (nF);
        reverse(nAns, nAns + nALen);
    }
}

int main()
{
    while (scanf("%d%d", &nN, &nK) == 2)
    {
        bool bOk = false;
        nOLen = 0;
        for (int i = 1; i < nK; ++i)
        {
            Bfs(i, i);
            if (bFind)
            {
                if (nOLen == 0 || Cmp(nOut, nOLen, nAns, nALen) > 0)
                {
                    nOLen = nALen;
                    memcpy(nOut, nAns, sizeof(int) * nALen);
                }
                bOk = true;
            }
        }
        if (!bOk)
            for (int i = 0; i < nK; ++i)
            {
                for (int j = i + 1; j < nK; ++j)
                {
                    Bfs(i, j);
                    if (bFind)
                    {
                        if (nOLen == 0 || Cmp(nOut, nOLen, nAns, nALen) > 0)
                        {
                            nOLen = nALen;
                            memcpy(nOut, nAns, sizeof(int) * nALen);
                        }
                    }
                }
            }
        for (int k = 0; k < nOLen; ++k)
        {
            printf("%d", nOut[k]);
        }
        printf("\n");
    }

    return 0;
}
```