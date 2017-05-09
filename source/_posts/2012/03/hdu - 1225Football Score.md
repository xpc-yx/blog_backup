---
title: 'hdu - 1225:Football Score'
tags:
  - 字符串
id: 133
categories:
  - 字符串
date: 2012-03-14 14:30:00
---

这是个简单的字符串处理题目。看题目，数据应该不是很大，直接暴力处理可以过。如果为了加快搜索速度，在中间输入过程中排序，再二分很麻烦，速度也快不了多少，因为只是输入的过程中需要查找。但是，这个题其实很好用map做，代码量可以少很多，也很简洁。
写这篇blog的目的是为了提醒自己，容易题再这样错下去，真的很伤人心，学什么都没必要了，当时打算继续搞ACM的目的之一就是为了提高代码正确率。这个题，不仅细节部分没看清楚，而且写代码时候把比较函数里面的one.nLost写成了one.nGet，查错了1个多小时，还让队友帮忙查错了好久，真的很无语。写程序确实可以debug，但是这也让我养成了很严重的依赖debug的习惯。
人生不可以debug，人生不可以重来。记得以前很多次很多事情就是开始无所谓，后面悲催到底，无限后悔。

代码如下：

``` stylus
#include <stdio.h>
#include <string.h>
#include <string>
#include <map>
#include <vector>
#include <algorithm>
#define MAX (100)
using std::map;
using std::string;
using std::vector;
using std::sort;

struct INFO
{
    INFO()
    {
        nScore = nGet = nLost = 0;
    }

    string strName;
    int nScore;
    int nGet;
    int nLost;
    bool operator < (const INFO& one) const
    {
        if (nScore != one.nScore)
        {
            return nScore > one.nScore;
        }
        else if (nGet - nLost != one.nGet - one.nLost)//这里把one.nLost写成了one.nGet
        {
            return nGet - nLost > one.nGet - one.nLost;
        }
        else if (nGet != one.nGet)
        {
            return nGet > one.nGet;
        }
        else
        {
            return strName < one.strName;
        }
    }
};

int main()
{
    int nN;

    //freopen("in.txt", "r", stdin);
    //freopen("out.txt", "w", stdout);
    while (scanf("%d", &nN) == 1)
    {
        int nLast = nN * (nN - 1);
        char szOne[MAX];
        char szTwo[MAX];
        int nOne, nTwo;

        map<string, INFO> myMap;
        for (int i = 0; i < nLast; ++i)
        {
            scanf("%s %*s %s %d:%d", szOne, szTwo, &nOne, &nTwo);
            //printf("%s %s %d %d\n", szOne, szTwo, nOne, nTwo);

            string strOne = szOne;
            myMap[strOne].strName = strOne;
            myMap[strOne].nGet += nOne;
            myMap[strOne].nLost += nTwo;

            string strTwo = szTwo;
            myMap[strTwo].strName = strTwo;
            myMap[strTwo].nGet += nTwo;
            myMap[strTwo].nLost += nOne;

            if (nOne > nTwo)
            {
                myMap[strOne].nScore += 3;
            }
            else if (nOne == nTwo)
            {
                myMap[strOne].nScore += 1;
                myMap[strTwo].nScore += 1;
            }
            else
            {
                myMap[strTwo].nScore += 3;
            }
        }

        map<string, INFO>::iterator it;
        vector<INFO> myVt;
        for (it = myMap.begin(); it != myMap.end(); it++)
        {
            myVt.push_back(it->second);
        }

        sort(myVt.begin(), myVt.end());
        for (int i = 0; i < myVt.size(); ++i)
        {
            printf("%s %d\n", myVt[i].strName.c_str(), myVt[i].nScore);
        }
        printf("\n");
    }

    return 0;
}
```