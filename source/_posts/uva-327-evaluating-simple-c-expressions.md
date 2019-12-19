---
title: uva 327 - Evaluating Simple C Expressions
tags:
  - 字符串
id: 181
categories:
  - ACM-ICPC
date: 2012-06-10 22:00:00
---

这个题目的意思是要计算一些c语言表达式的值。这些表达式有+-还有++，--操作符与a-z这些变量组合而成。a-z的权值是1-26。比如，表达式 c+f--+--a，得出值是9，其它变量的值也需要计算出来。
这个题目感觉比较麻烦，刚开始一点思路也没有，还写了个错误的方法，浪费了时间。后面我的思路是 （+，-） （--，++）（变量）（--，++），这个匹配式子的意思是先处理二元操作符，然后处理前置，再处理变量，再处理后置，如果发现没有后置操作符，则把读取的数据重新写回数据流里面，下次再处理。

代码如下：
``` stylus
#include <stdio.h>
#include <string.h>
#include <sstream>
#include <algorithm>
using namespace std;
struct INFO
{
    char ch;
    int nValue;
    char chAdd;
    bool operator < (const INFO info) const
    {
        return ch < info.ch;
    }
};

INFO infos[200];
char szLine[200];

bool GetNextChar(stringstream ss, char ch)
{
    while (ss >> ch)
    {
        if (ch != ' ');
        {
            return true;
        }
    }
    return false;
}

int main()
{
    while (gets(szLine))
    {
        printf("Expression: %s\n", szLine);
        memset(infos, 0, sizeof(infos));
        stringstream ss(szLine);
        char ch;
        int nNum = 0;
        int nValue = 0;
        char chOper;
        bool bOk = true;
        bool bFirst = true;
        while (1)
        {
            if (bFirst)
            {
                chOper = '+';
                bFirst = false;
            }
            else
            {
                bOk = GetNextChar(ss, ch);
                if (!bOk) break;
                chOper = ch;
            }

            bOk = GetNextChar(ss, ch);
            if (!bOk) break;

            if (ch == '-')//前置--
            {
                bOk = GetNextChar(ss, ch);
                if (!bOk) break;//-
                bOk = GetNextChar(ss, ch);
                if (!bOk) break;//读取字母

                infos[nNum].ch = ch;
                infos[nNum].nValue = ch - 'a';

                if (chOper == '+')
                {
                    nValue += infos[nNum].nValue;
                }
                else
                {
                    nValue -= infos[nNum].nValue;
                }
                ++nNum;
            }
            else if (ch == '+')//前置++
            {
                bOk = GetNextChar(ss, ch);
                if (!bOk) break;//+
                bOk = GetNextChar(ss, ch);
                if (!bOk) break;//读取字母

                infos[nNum].ch = ch;
                infos[nNum].nValue = ch - 'a' + 2;

                if (chOper == '+')
                {
                    nValue += infos[nNum].nValue;
                }
                else
                {
                    nValue -= infos[nNum].nValue;
                }
                ++nNum;
            }
            else
            {
                infos[nNum].ch = ch;
                infos[nNum].nValue = ch - 'a' + 1;

                if (chOper == '+')
                {
                    nValue += infos[nNum].nValue;
                }
                else
                {
                    nValue -= infos[nNum].nValue;
                }
                //读取后置操作符
                char chOne;
                char chTwo;
                bOk = GetNextChar(ss, chOne);
                if (!bOk)
                {
                    ++nNum;
                    break;
                }
                bOk = GetNextChar(ss, chTwo);
                if (!bOk)
                {
                    ++nNum;
                    break;
                }

                if (chOne == chTwo)
                {
                    if (chOne == '+')
                    {
                        infos[nNum].chAdd = '+';
                    }
                    else
                    {
                        infos[nNum].chAdd = '-';
                    }
                }
                else
                {
                    ss.putback(chTwo);
                    ss.putback(chOne);
                }
                ++nNum;
            }
        }

        printf("    value = %d\n", nValue);
        sort(infos, infos + nNum);
        for (int i = 0; i < nNum; ++i)
        {
            if (infos[i].chAdd == '+')
            {
                infos[i].nValue++;
            }
            else if (infos[i].chAdd == '-')
            {
                infos[i].nValue--;
            }
            printf("    %c = %d\n", infos[i].ch, infos[i].nValue);
        }
    }

    return 0;
}
```