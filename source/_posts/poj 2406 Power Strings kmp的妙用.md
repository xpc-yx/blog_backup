---
title: poj 2406 Power Strings kmp的妙用
tags:
  - 字符串
id: 270
categories:
  - 算法 
  - 算法题
date: 2012-09-30 11:30:00
---

这个题是求一个字符串的最小重复单元的重复次数，那么求出最小重复单元的长度即可。这个题有3种方法，方法一：直接枚举长度为[1,len/2]内的子串，暴力就过了。方法二：将原串重复一次形成一个新串，用原串去匹配新串，但是得从第二个位置开始匹配，第一次成功匹配的位置减一就代表最小重复单元的长度。方法三：利用kmp的next函数，如果len能够整除len-next[len]，那么len-next[len]就代表最小重复单元的长度。
方法一明显是对的，数据不强的情况下就能水过了。方法二也不是那么容易想到的，不过将原串扩展为2倍的做法也不是太奇葩，比如判断2个循环串是否相等就可以用这个办法做。
方法三就比较难理解了。
方法三的理解：
next[len]代表的是str的最长前缀(使得这个前缀与同样长度的后缀相等)的长度。所谓的next
数组就是长度为1-len的str的满足上述描述的最长前缀的长度。如果len是len-next[len]的倍数，假设m= len-next[len] ，那么str[1-m] = str[m-2 * m]，以此类推下去，m肯定是str的最小重复单元的长度。假如len不是len-next[len]的倍数， 如果前缀和后缀重叠，那么最小重复单元肯定str本身了，如果前缀和后缀不重叠，那么str[m - 2 * m] != str[len-m,len]，所以str[1-m]!= str[m - 2 * m] ,最终肯定可以推理出最小重复单元是str本身，因为只要不断递增m证明即可。

方法三的代码如下：

``` stylus
#include <stdio.h>
#include <string.h>
#include <algorithm>
using namespace std;

char szStr[1000010];
int nNext[1000010];

void GetNext(char* szStr, int nLen, int* nNext)
{
    nNext[0] = -1;
    for (int i = 1, j = -1; i < nLen; ++i)
    {
        while (j > -1  szStr[i] != szStr[j + 1])
        {
            j = nNext[j];
        }
        if (szStr[i] == szStr[j + 1])
        {
            ++j;
        }
        nNext[i] = j;
    }
}

int main()
{
    while (scanf("%s", szStr), strcmp(szStr, "."))
    {
        int nLen = strlen(szStr);

        GetNext(szStr, nLen, nNext);
        if (nLen % (nLen - nNext[nLen - 1] - 1))
        {
            printf("1\n");
        }
        else
        {
            printf("%d\n", nLen / (nLen - nNext[nLen - 1] - 1));
        }
    }

    return 0;
}
```