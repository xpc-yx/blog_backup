---
title: uva 408 - Uniform Generator
tags:
  - 数论
id: 227
categories:
  - 数学
date: 2012-07-20 11:00:00
---

这是今天想通的一个数论题，还是挺有意思的，想出来的那一瞬间yeah了一下，可是我悲剧的粗心习惯，还是交了3次才过，nm数中间空格都错了，又忘记打空行，明明字符串从25列开始，中间是4个空格的，我nc的打了5个空格，就pe了，还有不仔细看输出要求，没有输出空行，最近真没状态啊。
其实，这个题想通了就很简单了，还是数论里面的群的概念，就是加法群的生成群啊，打着随机数的幌子而已。由于又没有限定种子，限定对答案也没有影响，假设种子是0，那么数列可以表示为a*step，数列要能够生成0 - mod-1中所有的数字，那么就有a*step = b % mod(0<=b<mod)。
哈哈，上面那个式子就是a*x=b%n这个线性同余方程了，只是有很多b了。要方程有解，不是需要满足条件gcd(a,n)|b么，意思b是gcd(a,n)的整数倍了。但是0<=b<n啊，b会是1了，那么gcd(a,n)一定是1了哦。那么直接判断gcd(step,mod)是否为1就行了，哈哈。
关于线性同余方程a*x=b%n，要有解的条件gcd(a,n)|b的解释，还是参看算法导论或者其它资料吧。。。

代码就非常简单了，如下：
``` stylus
#include <stdio.h>
#include <algorithm>
using namespace std;

int gcd(int a, int b)
{
    if (a < b)swap(a, b);
    while (b)
    {
        int t = a;
        a = b;
        b = t % b;
    }
    return a;
}

int main()
{
    int nStep, nMod;

    while (scanf("%d%d", &nStep, &nMod) == 2)
    {
        printf("%10d%10d    %s\n\n", nStep, nMod,
               gcd(nStep, nMod) == 1 ? "Good Choice" : "Bad Choice");
    }

    return 0;
}
```