---
title: uva 10061 - How many zero's and how many digits ?
tags:
  - n!末尾多少个0
id: 162
categories:
  - ACM-ICPC
date: 2012-05-02 10:00:00
---

这又是一个数学题，不过我还是比较喜欢做这类数学杂题的。题目意思很简单，给2个十进制数，n和b。如果用b进制表示n!，需要多少位数，这个表示末尾会有多少个0。这个题并不需要什么高深的知识，这一点也是我喜欢做这类题的一个方法。
大家显然都知道求n！用10进制表示末尾会有多少个0的方法，就是求2 * 5最多有多少对。那么，b进制了。方法类似，发散一下想法而已。
我还是先说求多少位数的方法吧。 b的m-1次 看到这个不等式应该有想法了吧。两边同时取logb，就可以得到Σlogi(1<=i 再说怎么求末尾0的，发散下想法，我们也可以对n！中的每个因子试着求b的因子对，一共有多少对。但是，后面发现这样不行，因为比如b是16，1和16是一对因子，2和8是一对因子，4和4是一对因子，也就是因为2也是4的因子，这样计算因子对就会重复了。但是对于b等于10的情况，可以例外而已。
呵呵，考虑其它的方法。求素数因子。任何数字都可以被分解为一些素数因子的乘积，这是毋容置疑的。那么，我们去分解n！中的小于等于b的素数因子，并将其个数存储在数组里面。然后死循环的去分解b的素数因子，能够完全分解一次(具体看下代码，不好描述），ans就加1。否则，已经没有末尾0了。
虽然提交了16次才过。不过最后还算不错吧，只用了0.508s。相比20s的时间界限，很小了。网上有些过的代码，跑一个数据都要几分钟。。。PS：uva上那些神人，怎么用0.0s算出来的，很难想象啊。
这个题目还有个很大的需要注意的地方，就是浮点数的精度问题。前面讲到求位数需要用到log函数，log函数的计算精度就出问题了。
最后需要对和加一个1e-9再floor才能过。特别需要注意这一点，因为开始我的程序过了所有[http://online-judge.uva.es/board/viewtopic.php?f=9t=7137start=30][1]上说的数据还是wa了。而且我还发现log10计算精度高很多，如果log(这个是自然对数)去计算，这个网站上的数据都过不了。

``` stylus

#include <stdio.h>
#include <string.h>
#include <math.h>

int nN, nB;

int nDivisor[1000];

int GetDigit(int nN, int nB)
{
    double fSum = 0.0;
    for (int i = 2; i <= nN; ++i)
    {
        fSum += log10(i);
    }

    fSum /= log10(nB);

    return floor(fSum + 1e-9) + 1;
}

int GetZero(int nN, int nB)
{
    memset(nDivisor, 0, sizeof(nDivisor));

    for (int i = 2; i <= nN; ++i)
    {
        int nTemp = i;

        for (int j = 2; j <= nTemp  j <= nB; ++j)//这样循环就可以进行素数因子分解了
        {
            while (nTemp % j == 0)
            {
                nDivisor[j]++;
                nTemp /= j;
            }
        }
    }

    int nAns = 0;

    while (1)
    {
        int nTemp = nB;

        for (int j = 2; j <= nTemp; ++j)//分解nB
        {
            while (nTemp % j == 0)
            {
                if (nDivisor[j] > 0)//如果还可以继续分解
                {
                    --nDivisor[j];
                }
                else //直接可以goto跳出多重循环了
                {
                    goto out;
                }
                nTemp /= j;
            }
        }
        ++nAns;
    }

out:
    return nAns;
}

int main()
{
    while (scanf("%d%d", &nN, &nB) == 2)
    {
        int nDigit = GetDigit(nN, nB);
        int nZero = GetZero(nN, nB);
        printf("%d %d\n", nZero, nDigit);
    }

    return 0;
}

```


  [1]: http://online-judge.uva.es/board/viewtopic.php?f=9t=7137start=30