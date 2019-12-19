---
title: uva 10562 - Undraw the Trees
tags:
  - 递归
id: 183
categories:
  - ACM-ICPC
date: 2012-06-12 14:30:00
---

这是一个貌似很麻烦的题，题目要求是将一颗用ascii码绘画出来的树，转换为其一种字符串表示，这种字符串表示好像是叫做什么广义表什么的。
比如，
**    A**
<div>

**    |**

**--------**

**B  C   D**

**   |   |**

** ----- -**

** E   F G 对应的字符串表示 ****(A(B()C(E()F())D(G())))**

</div>
比较纠结的是如何读取数据，如何递归，如果建立树的话，也麻烦，因为还是颗不定叉的树。最主要的是如何方便地递归。最后知道了一个比较巧妙的方法，先一次性把一组数据读入字符串数组里面，再在这个字符串数组上进行递归处理。这样的话，就能很方便的找到树里面节点
的关系了。
而一次读一个字符就想进行递归是没办法确定节点的关系的，不递归估计更很难写，完全没头绪。。。

代码如下：

``` stylus
#include <stdio.h>
#include <stdlib.h>

char szLines[210][210];
int nNumOfLine;

void GetAns(int i, int j)
{
    //printf("i:%d, j:%d, %c\n", i, j, szLines[i][j]);

    if (szLines[i][j] != '\0')
    {
        putchar(szLines[i][j]);
        //printf("%c", szLines[i + 1][j]);
        if (szLines[i + 1][j] == '|')
        {
            int nBeg, nEnd;
            nBeg = nEnd = j;
            while (nBeg >= 0  szLines[i + 2][nBeg] == '-')
            {
                --nBeg;
            }
            while (szLines[i + 2][nEnd] == '-')
            {
                ++nEnd;
            }
            //printf("nBeg:%d, nEnd:%d\n", nBeg, nEnd);
            putchar('(');
            for (int k = nBeg; k             {
                if (szLines[i + 3][k] != ' '  szLines[i + 3][k] != '\0')
                {
                    GetAns(i + 3, k);
                }
            }
            putchar(')');
        }
        else
        {
            printf("()");
        }
    }

}

int main()
{
    int nN;
    char ch;

    scanf("%d", &nN);
    getchar();
    while (nN--)
    {
        nNumOfLine = 0;
        memset(szLines, 0, sizeof(szLines));
        while (gets(szLines[nNumOfLine]), szLines[nNumOfLine][0] != '#')
        {
            //printf("%s\n", szLines[nNumOfLine]);
            nNumOfLine++;
        }
        if (nNumOfLine == 0)
        {
            printf("()\n");
            continue;
        }
        int i, j;
        i = 0;
        for (j = 0; szLines[0][j] == ' '; ++j);
        //printf("i:%d, j:%d\n", i, j);
        putchar('(');
        GetAns(i, j);
        putchar(')');
        putchar('\n');
    }

    return 0;
}

```