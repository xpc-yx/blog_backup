---
title: uva 297 - Quadtrees
tags:
  - 递归
id: 179
categories:
  - 算法 
  - 算法题
date: 2012-06-08 18:30:00
---

题意是用字符串描述的一棵四叉树，读取字符串获得最终叶子节点的颜色。输入是2个字符串，根据这2个字符串建立2个四叉树。然后对于，指定位置的叶子节点，如果2颗树的叶子颜色其中一个为黑色，那么ans++，输出的就是ans。
类似树形结构的东西，直接一个函数递归求解即可。函数参数，一般是字符串地址，当前位置，然后还有其它在递归时候需要用到的东西。

代码如下：
``` stylus
#include <stdio.h>
#define BLACK (1)
#define WHITE (2)
#define MAX (32)
int nStateA[MAX][MAX];
int nStateB[MAX][MAX];

char szOne[10000];
char szTwo[10000];

void GetState(int nState[MAX][MAX], char* pszLine, int nPos,
              int nSize, int nX, int nY)
{
    if (pszLine[nPos] == 'p')
    {
        ++nPos;
        GetState(nState, pszLine, nPos, nSize / 2, nX + nSize / 2, nY);
        GetState(nState, pszLine, nPos, nSize / 2, nX, nY);
        GetState(nState, pszLine, nPos, nSize / 2, nX, nY + nSize / 2);
        GetState(nState, pszLine, nPos, nSize / 2, nX + nSize / 2, nY + nSize / 2);
    }
    else
    {
        for (int i = nX; i < nX + nSize; ++i)
        {
            for (int j = nY; j < nY + nSize; ++j)
            {
                if (pszLine[nPos] == 'e')
                {

                    nState[i][j] = WHITE;
                }
                else
                {
                    nState[i][j] = BLACK;
                }
            }
        }         ++nPos;
    }
}

int main()
{
    int nCases;

    scanf("%d\n", &nCases);
    while (nCases--)
    {
        gets(szOne);
        gets(szTwo);
        int nPos = 0;
        GetState(nStateA, szOne, nPos, MAX, 0, 0);
        nPos = 0;
        GetState(nStateB, szTwo, nPos, MAX, 0, 0);
        int nAns = 0;
        for (int i = 0; i < MAX; ++i)
        {
            for (int j = 0; j < MAX; ++j)
            {
                if (nStateA[i][j] == BLACK || nStateB[i][j] == BLACK)
                {
                    nAns++;
                }
            }
        }
        printf("There are %d black pixels.\n", nAns);
    }

    return 0;
}
```