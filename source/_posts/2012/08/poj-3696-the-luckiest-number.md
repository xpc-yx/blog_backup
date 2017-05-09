---
title: poj 3696 The Luckiest number
tags:
  - 数论
id: 237
categories:
  - 数学
date: 2012-08-02 21:00:00
---

这个题很奇葩了。题意是给出个数字L，假如存在一个数K使得L*K = 888...，求888...的最小长度，如果不存在这样的K，那么输出0。我是什么思路也没有了，拖了几天了，数论搞死我了，只能找答案了。
我看到个比较靠谱的推法。首先，888...=111...*8=(10^0+10^1+...+10^m-1)*8=(10^m - 1)/9*8，PS：m代表888...的长度。
好吧，终于化成指数了，现在有8*(10^m-1)/9=K*L，最小的m就是我们要求的答案啦。

方式1：
=> 8 * (10^m-1) = 9 * k * L
=> 8/d*(10^m-1)=9*k*L/d，d=gcd(8,9L)
=> 10^m-1 = 0 % 9 * L / gcd(8, 9L) = 0 % 9*L/gcd(8,L)，(由于gcd(8/d,9L/d)=1，那么10^m-1必然是9*L/d的倍数了)。
=> 10^m = 1 % 9 * L / gcd(8,L)
方式2：
=> 8*(10^m-1)/9 = 0 % L
=> 8*(10^m-1) = 0 % 9*L(这步的推出，比如x/9 = k*n，那么x=9*k*n了，显然成立)
=> 10^m-1 = 0 % 9*L/gcd(9*L,8)，假如，d = gcd(9*L,8)，那么有8/d*(10^m-1)=k*9*L/d，因为8/d不可能是9 *L / d
的倍数，所以10^m-1必定是9*L/d的倍数，所以10^m-1 = 0 % 9*L/gcd(9*L,8))，=>，10^m - 1 = 0 % 9 * L / gcd(L, 8),
(因为gcd(9,8)=1)。
=> 10^m = 1 % 9*L/gcd(8,L)

至此，2种方式都推出了，10^m = 1 % 9*L/gcd(8,L) 。
那么怎么解答这个问题了，这个就用到了欧拉定理了。令p = 9 * L / gcd(8,L)，那么有10^m = 1 % p。由欧拉定理知,Z*p中所有的数字a均满足a^euler(p) = 1 % p。那么，10只要是p的乘法群中就肯定有解了。如果，10不在Z*p中了，肯定是无解的。证明如下：
由a^x = 1%p，可以得到a^(x-1)*a=1%p，要a^(x-1)存在，那么gcd(a,p)|1，那么gcd(a,p)必须是1。综上所述，要满足式子a^m=1%p，必须gcd(p,a)=1，即a必须是p的乘法群中的数字。现在的问题是求最小的m，由欧拉定理知道a^euler(p)=1%p，m再大就开始循环了。但是m可能会更小。比如，我们现在知道最小的m是min，那么有a^min=1%p，因为要满足a^euler(p)=1%p，那么a^euler(p)肯定能变换成(a^min)^k,至于k是多少就不知道了，当然也可以求出来。那么min就是euler(p)的一个因子，而且是最小的一个满足a^min=1%p的因子了。
现在就可以通过枚举euler(p)的因子，找到最小的因子min满足式子a^min = 1 % p就能解决本问题了。注意求a^m%p肯定是通过算法导论上面那种方法的,O(32)或者O(64)的复杂度，还有a*b%m也需要自己模拟，因为可能a*b就溢出了。
代码如下，貌似代码还可以通过其它的改进加快速度。
``` stylus
#include <stdio.h>
#include <math.h>
#include <algorithm>
#include <string.h>
using namespace std;
typedef long long INT;

//10^m = 1 % (9*L / gcd(8, L)),求最小m
//p = 9 * L / gcd(8,L)
//gcd(p,10) != 1则p有2或者5的因子,2^m=1%p或者
//5^m=1%p无解,原式无解
//if(p)素数,m=euler(p) = p - 1
//否则,m一定是euler(p)的最小满足等式的因子
//因为(10^m)^n = 10^euler(p) = 1%p
INT gcd(INT a, INT b)
{
    if (a < b)swap(a, b);
    while (b)
    {
        INT t = a;
        a = b;
        b = t % b;
    }
    return a;
}

INT Euler(INT nN)
{
    INT nAns = 1;
    INT nMax = sqrt((double)nN) + 1;
    for (INT i = 2; i <= nMax; ++i)
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
        }
    }
    if (nN != 1)nAns *= nN - 1;
    return nAns;
}

INT MultMod(INT a, INT b, INT mod)
{
    INT ans = 0;
    while (b)
    {
        if (b  1)
        {
            ans = (ans + a) % mod;
        }
        a = (2 * a) % mod;
        b >>= 1;
    }
    return ans;
}

INT ExpMod(INT base, INT exp, INT mod)
{
    INT ans = 1;
    base %= mod;
    while (exp)
    {
        if (exp  1)
        {
            ans = MultMod(ans, base, mod);
        }
        base = MultMod(base, base, mod);
        exp >>= 1;
    }
    return ans % mod;
}

INT GetAns(INT p)
{
    INT u = Euler(p);
    INT nMax = sqrt((double)u) + 1;
    INT nAns = u;
    for (INT i = 1; i <= nMax; ++i)
    {
        if (u % i == 0)
        {
            if (ExpMod(10, i, p) == 1)
            {
                nAns = i;
                break;
            }
            if (ExpMod(10, u / i, p) == 1)
            {
                nAns = min(nAns, u / i);
            }
        }
    }
    return nAns;
}

int main()
{
    INT nL;
    INT nCase = 1;

    while (scanf("%I64d", &nL), nL)
    {
        INT p = 9 * nL / gcd(nL, 8);
        if (gcd(p, 10) != 1)
        {
            printf("Case %I64d: 0\n", nCase++);
            continue;
        }
        printf("Case %I64d: %I64d\n", nCase++, GetAns(p));
    }

    return 0;
}
```