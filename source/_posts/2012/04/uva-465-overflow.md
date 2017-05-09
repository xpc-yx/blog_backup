---
title: Uva 465 - Overflow
tags:
  - 大数
id: 155
categories:
  - 模拟
date: 2012-04-03 10:00:00
---

这是一道很简单的题吧，大数都不需要用到，可是很悲剧wa了很久。确实写题太不严谨了，出了好多bug，甚至题意都没注意清楚。
这种题我一直忘记忽略前导'0'。还有题目没有给出最长的数字的长度，所以最好用string类。
使用longlong之前最好已经测试了OJ，是用%lld还是%I64d，如果OJ后台是linux下的g++，只能是%lld，Windows下的MinGW32(Dev-C++也一样用的是这个库)要用%I64d才能正确。所以预赛之前需要对普通题进行测试下。还有注意复合逻辑表达式是否写正确了，最近经常写错了，太郁闷了。
给自己提个醒吧，校赛这种题再不能迅速A掉基本太丢人了。
代码如下：
``` stylus
#include <stdio.h> 
#include <limits.h>
#include <string.h>
#include <algorithm>
using namespace std;
#define MAX (10000)
char szIntMax[20];
char szLine[MAX];
char szOne[MAX];
char szTwo[MAX];
char szOper[10];

char* MyItoa(int nNum, char* pszNum, int nBase)
{
    int nLen = 0;
    while (nNum)
    {
        pszNum[nLen++] = nNum % nBase + '0';
        nNum /= nBase;
    }
    reverse(pszNum, pszNum + nLen);
    pszNum[nLen] = '\0';

    return pszNum;
}

bool IsBigger(char* pszOne, int nLenOne, char* pszTwo, int nLenTwo)
{
    //printf(";pszOne:%s, pszTwo:%s\n";, pszOne, pszTwo);
    if (nLenOne != nLenTwo)
    {
        return nLenOne > nLenTwo;
    }
    else
    {
        for (int i = 0; i < nLenOne; ++i)
        {
            if (pszOne[i] != pszTwo[i])
            {
                return pszOne[i] > pszTwo[i];
            }
        }
        return false;
    }
}

int StripHeadZero(char* pszNum)
{
    int nLen = strlen(pszNum);
    int i;

    for (i = 0; i < nLen && pszNum[i] == '0'; ++i);
    if (i == nLen)
    {
        pszNum[0] = '0';
        pszNum[1] = '\0';
        nLen = 2;
    }
    else
    {
        char* pszWrite = pszNum;
        char* pszRead = pszNum + i;
        nLen = 0;
        while (*pszRead)
        {
            *pszWrite++ = *pszRead++;
            ++nLen;
        }
        *pszWrite = '\0';
    }

    return nLen;
}

int main()
{
    int nIntMax = INT_MAX;
    MyItoa(nIntMax, szIntMax, 10);
    int nLenMax = strlen(szIntMax);

    while (gets(szLine))
    {
        if (szLine[0] == '\0')
        {
            continue;
        }

        sscanf(szLine, ";%s%s%s";, szOne, szOper, szTwo);
        printf(";%s %s %s\n";, szOne, szOper, szTwo);
        StripHeadZero(szOne);
        StripHeadZero(szTwo);

        int nLenOne = strlen(szOne);
        int nLenTwo = strlen(szTwo);
        bool bFirst = false;
        bool bSecond = false;

        if (IsBigger(szOne, nLenOne, szIntMax, nLenMax))
        {
            printf(";first number too big\n";);
            bFirst = true;
        }

        if (IsBigger(szTwo, nLenTwo, szIntMax, nLenMax))
        {
            printf(";second number too big\n";);
            bSecond = true;
        }

        if (bFirst || bSecond)
        {
            if (szOper[0] == '+' || (szOper[0] == '*' && szOne[0] != '0' && szTwo[0] != '0'))
            {
                printf(";result too big\n";);
            }
        }
        else
        {
            long long nOne, nTwo;
            sscanf(szLine, "%lld%s%lld", &nOne, szOper, &nTwo);
            long long nResult;

            if (szOper[0] == '+')
            {
                nResult = nOne + nTwo;
            }
            else if (szOper[0] == '*')
            {
                nResult = nOne * nTwo;
            }
            //printf(";%I64d\n";, nResult);
            if (nResult > INT_MAX)
            {
                printf(";result too big\n";);
            }
        }
    }

    return 0;
}
```