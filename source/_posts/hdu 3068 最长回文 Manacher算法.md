---
title: hdu 3068 最长回文 Manacher算法
tags:
  - Manacher算法
  - 最长回文串
id: 301
categories:
  - 算法
  - 字符串
date: 2012-10-24 16:30:00
---

该题就是求一个字符串的最长回文子串，就是一个满足本身是回文的最长的子串。
该题貌似可以用后缀数组和扩展kmp做，但是好像后缀数组貌似会tle，改学了下一个专门的叫Manacher算法的东西。。。
这又是一个线性改良算法。找到有篇文章写的不错，链接如下：
[http://www.felix021.com/blog/read.php?2040](http://www.felix021.com/blog/read.php?2040)。
该算法说起来也不是太复杂，比较容易看懂的那种，当然是接触过其它字符串算法的前提下了。记得以前就看了看，硬是没看懂，想不到现在这么快就明白了。
该算法需要额外的O(N)空间。说起来是空间换时间吧。
大概的思路是先预处理字符串，使其成为一个长度一定为偶数的串。而且第一个字符是'$'，假设'$'没有在原串出现过。然后再在原来的每个字符前面加上'#'，最后再加个
'#'。比如，abc就变成了$#a#b#c#。现在再对新的字符串进行处理。
开一个新的数组nRad[MAX]，nRad[i]表示新串中第i个位置向左边和向右边同时扩展并且保持对称的最大距离。如果求出了nRad数组后，有一个结论，nRad[i]-1恰好表示原串对应的位置能够扩展的回文子串长度。这个的证明，应该比较简单，因为新串基本上是原串的2倍了，而且新串每一个有效字符两侧都有插入的#，这个找个例子看下就知道是这样了。
最重要的是如何求出nRad数组。
求这个数组的算法也主要是利用了一些间接的结论优化了nRad[i]的初始化值。比如我们求nRad[i]的时候，如果知道了i以前的nRad值，而且知道了前面有一个位置id，能够最大的向两边扩展距离max。那么有一个结论，nRad[i] 能够初始化为min(nRad[2*id - i], max - i)，然后再进行递增。关键是如何证明这个，这个的证明，对照图片就很清楚了。
证明如下：
当 mx - i > P[j] 的时候，以S[j]为中心的回文子串包含在以S[id]为中心的回文子串中，由于 i 和 j 对称，
以S[i]为中心的回文子串必然包含在以S[id]为中心的回文子串中，所以必有 P[i] = P[j]，见下图。
![](https://c2.staticflickr.com/8/7049/27312602222_9f02e36521_o.png)

当 P[j] > mx - i 的时候，以S[j]为中心的回文子串不完全包含于以S[id]为中心的回文子串中，但是基于
对称性可知，下图中两个绿框所包围的部分是相同的，也就是说以S[i]为中心的回文子串，其向右至少会
扩张到mx的位置，也就是说 P[i] >= mx - i。至于mx之后的部分是否对称，就只能老老实实去匹配了。
![](https://c2.staticflickr.com/8/7322/27312603572_34d229d8e5_o.png)
这个就说明得很清楚了。。。

代码如下：

``` stylus
#include <stdio.h>
#include <string.h>
#include <algorithm>
using namespace std;

const int MAX = 110010 * 2;
char szIn[MAX];
char szOut[MAX];
int nRad[MAX];

int Proc(char* pszIn, char* pszOut)
{
    int nLen = 1;

    *pszOut++ = '$';
    while (*pszIn)
    {
        *pszOut++ = '#';
        nLen++;
        *pszOut++ = *pszIn++;
        nLen++;
    }
    *pszOut++ = '#';
    *pszOut = '\0';

    return nLen + 1;
}

void Manacher(int* pnRad, char* pszStr, int nN)
{
    int nId = 0, nMax = 0;

    //pnRad[0] = 1;
    for (int i = 0; i < nN; ++i) 
    { 
        if (nMax > i)
        {
            pnRad[i] = min(pnRad[2 * nId - i], nMax - i);
        }
        else pnRad[i] = 1;

        while (pszStr[i + pnRad[i]] == pszStr[i - pnRad[i]])
        {
            ++pnRad[i];
        }
        if (pnRad[i] + i > nMax)
        {
            nMax = pnRad[i] + i;
            nId = i;
        }
    }
}

int main()
{
    while (scanf("%s", szIn) == 1)
    {
        int nLen = Proc(szIn, szOut);
        Manacher(nRad, szOut, nLen);
        int nAns = 1;
        for (int i = 0; i < nLen; ++i)
        {
            nAns = max(nRad[i], nAns);
        }
        printf("%d\n", nAns - 1);
    }

    return 0;
}
```