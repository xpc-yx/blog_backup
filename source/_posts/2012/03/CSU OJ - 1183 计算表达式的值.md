---
title: 'CSU OJ - 1183: 计算表达式的值'
tags:
  - 递归计算表达式
id: 136
categories:
  - 模拟
date: 2012-03-19 10:00:00
---

题目意思很简单就是计算含括号的四则运算表达式的值。这个题目很坑爹，刚做的时候，题目描述里面只说里面会有空格，后面居然把题目描述改了。所以，这个题无论怎么改，都是不对。因为，不知道是哪个坑爹的出题人，把数据里面加了\t，难道出题人以为\t也是空格。估计，后面修改题目描述，也是发现这个问题后才改的。这可是还是哥了，改了无数多遍，不处理非法数据就超时，略过非常数据当然直接WA了。好坑爹。
计算表达式的值，以前严蔚敏书上就说用栈构造出来后缀表达式后再计算值。但是这个方法未免太那个了，首先太麻烦了，虽然算法思路不麻烦。我的做法是直接递归计算即可。碰到左括号递归计算新的表达式，**右括号作为函数终止条件**。否则，按照四则运算的优先级计算当前的表达式。递归算法中需要记录前一个运算符合的优先级，**如果前一个运算符的优先级比现在碰到的运算符的优先级高，那么就应该直接返回答案了**，当前碰到的运算符的计算交给下一次循环好了。

代码如下：
``` stylus
#include <stdio.h>
#define MAX (100 + 10)
char szData[MAX];

void TrimSpace(char* pszData)
{
    char* pszRead = pszData;
    char* pszWrite = pszData;
    while (*pszRead)
    {
        //由于数据中有\t,与先前题目描述不符合,不处理掉就直接超时了
        if (*pszRead != ' ' && *pszRead != '\t')
        {
            *pszWrite++ = *pszRead;
        }
        ++pszRead;
    }
    *pszWrite = '\0';
}

//nKind代表前一个运算符合的优先级,开始时是0,+-是1,*/是2
double Cal(char*& pszData, int nKind)
{
    double fAns = 0.0;
    while (*pszData && *pszData != ')')//表达式终止的条件是到达'\0'或者碰到右括号
    {
        if (*pszData >= '0' && *pszData <= '9')
        {
            fAns = 10 * fAns + *pszData - '0';
            ++pszData;
        }
        else if (*pszData == '+')
        {
            if (nKind >= 1)
            {
                return fAns;
            }
            ++pszData;
            fAns += Cal(pszData, 1);
        }
        else if (*pszData == '-')
        {
            if (nKind >= 1)
            {
                return fAns;
            }
            ++pszData;
            fAns -= Cal(pszData, 1);
        }
        else if (*pszData == '*')
        {
            if (nKind >= 2)
            {
                return fAns;
            }
            ++pszData;
            fAns *= Cal(pszData, 2);
        }
        else if (*pszData == '/')
        {
            if (nKind >= 2)
            {
                return fAns;
            }
            ++pszData;
            fAns /= Cal(pszData, 2);
        }
        else if (*pszData == '(')
        {
            ++pszData;
            fAns = Cal(pszData, 0);
            ++pszData;//移到')'后面
            return fAns;//一个括号内的是一个完整的表达式,因此直接返回
        }
    }

    return fAns;
}

int main()
{
    while (gets(szData))
    {
        TrimSpace(szData);
        char* pszData = szData;
        printf("%.4f\n", Cal(pszData, 0));
    }
}
```
一个递归函数能计算出表达式的值，而且能处理优先级和括号，如果是以前的话，我应该是写不出来的。再把算法的实现细节改改，应该也能计算出浮点数的表达式了。