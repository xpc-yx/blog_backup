---
title: 'POJ百练 - 2820:古代密码 AND POJ百练 - 2801:填词'
tags:
  - 编码
id: 61
categories:
  - ACM-ICPC
date: 2011-11-18 10:00:00
---

链接: [http://poj.grids.cn/practice/2820 ](http://poj.grids.cn/practice/2820)
链接: [http://poj.grids.cn/practice/2801](http://poj.grids.cn/practice/2801)

为啥把这2个不相干的题目放在一起了...说实话这其实也是二个容易的题目,尤其第二个更容易想到...第一个也许暂时
没那么容易想出来。。。
而且感觉第一个古代密码还挺有意思的...判断一个字符串是否能够通过移位和替换方法加密成另外一个字符串。。。
至于第二个,各位去看看题目吧。。。
也是个解法跟题目不大相关的题目。。。
这2个题最大的特点和共同点就是解法和题目意思想去甚远。。。
所以我觉得做这种二丈和尚摸不早头脑的题,思维应该往跟题意背离的方向思考。。。

尤其第一个题，如果只看代码,即使代码可读性再好，也不知道代码有何意义，有何目的，跟题意有啥关系。。。
不过第一个居然轻松AC了,虽然我2b得搞了个ce和re出来了...
第一个的转换方法是,计算出现的字符'A'-'Z'的出现次数,然后从大小排序,如果针对加密后的字符串得到的结果一直大于等于
加密前的字符串得到的结果,表明答案是YES...具体还是看代码吧...
``` stylus
#include <stdio.h>
#include <string.h>
#include <algorithm>

using std::sort;
bool Greater(int one, int two)
{
    return one > two;
}

int main()
{
    char szOne[110];
    char szTwo[110];
    int nNumOne[26];
    int nNumTwo[26];

    while (scanf("%s%s", szOne, szTwo) == 2)
    {
        memset(nNumOne, 0, sizeof(int) * 26);
        memset(nNumTwo, 0, sizeof(int) * 26);

        char* psz = szOne;
        while (*psz)
        {
            ++nNumOne[*psz - 'A'];
            ++psz;
        }
        psz = szTwo;
        while (*psz)
        {
            ++nNumTwo[*psz - 'A'];
            ++psz;
        }
        sort(nNumOne, nNumOne + 26, Greater);
        sort(nNumTwo, nNumTwo + 26, Greater);
        bool bIsYes = true;
        for (int i = 0; i < 26; ++i)
        {
            if (nNumOne[i] < nNumTwo[i])
            {
                bIsYes = false;
                break;
            }
        }
        if (bIsYes)
        {
            printf("YES\n");
        }
        else
        {
            printf("NO\n");
        }
    }

    return 0;
}
```