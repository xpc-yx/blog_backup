---
title: uva 657 - The die is cast
tags:
  - 搜索
id: 187
categories:
  - ACM-ICPC
date: 2012-06-16 14:00:00
---

这个题不错，居然需要在dfs里面写bfs。题意类似于图像识别里面，搜索一张图像里面的某个指定区域里面有几个斑点，题意里面的斑点是指色子。
<div>
30 15 
.............................. 
..............................
 ...............*.............. 
...*****......****............ 
...*X***.....**X***...........
 ...*****....***X**............
 ...***X*.....****.............
 ...*****.......*..............
 ..............................
 ........***........******.....
 .......**X****.....*X**X*.....
 ......*******......******..... 
.....****X**.......*X**X*..... 
........***........******..... 
..............................
比如上面这个30 * 15的图片里面，一共有四个区域，*作为区域的底色，然后是求区域里面有多少个X的块。这个题单纯dfs的话，很没办法，因为无法一次性把连接在一起的X都搜索了。比如，
5 5
<div>XXX*X
XXX*X
.....
X***X
XX***
的时候，dfs很明显就会出现问题，因为会先离开X块，再次回到X块，计数就会出现问题了。因此只能遇到X的时候，进行一次bfs，将与其相连接的X全部搜索掉。。。并且找到与当前X块相连接的一个*的位置，如果有这样的位置，就继续进行dfs。</div>
</div>
``` stylus
#include <stdio.h>
#include <string.h>
#include <algorithm>
#include <queue>
using namespace std;

int nW, nH;
char szData[100][100];
bool bVisit[100][100];
int nNum;
int nDice[100];
int nAdd[4][2] = {{0, -1}, {-1, 0}, {0, 1}, {1, 0}};

bool IsPosOk(int i, int j)
{
    return i >= 0  i < nH  j >= 0  j < nW;
}

struct POS
{
    int nI;
    int nJ;
};

bool Bfs(int nI, int nJ)
{
    bool bRet = false;
    queue<POS> qp;
    POS pos = {nI, nJ};
    int i = nI, j = nJ;

    qp.push(pos);
    while (qp.empty() == false)
    {
        POS head = qp.front();
        qp.pop();

        for (int m = 0; m < 4; ++m)
        {
            int nNextI = head.nI + nAdd[m][0];
            int nNextJ = head.nJ + nAdd[m][1];

            if (IsPosOk(nNextI, nNextJ)  bVisit[nNextI][nNextJ] == false)
            {
                if (szData[nNextI][nNextJ] == 'X')
                {
                    bVisit[nNextI][nNextJ] = true;
                    POS pos = {nNextI, nNextJ};
                    qp.push(pos);
                }
                else if (szData[nNextI][nNextJ] == '*')
                {
                    bRet = true;
                    nI = nNextI;//   这里是返回新的dfs位置
                    nJ = nNextJ;
                }
            }
        }
    }

    return bRet;
}

void dfs(int i, int j, int nNum)
{
    bVisit[i][j] = true;
    if (szData[i][j] == 'X')
    {
        nDice[nNum]++;
        bool bDfs = Bfs(i, j);//扩散掉当前连通的所有'X'
        if (bDfs == false)
        {
            return;
        }
        else
        {
            dfs(i, j, nNum);
        }
    }

    for (int m = 0; m < 4; ++m)
    {
        int nNextI = i + nAdd[m][0];
        int nNextJ = j + nAdd[m][1];

        if (IsPosOk(nNextI, nNextJ)  bVisit[nNextI][nNextJ] == false
                 szData[nNextI][nNextJ] != '.')
        {
            dfs(nNextI, nNextJ, nNum);
        }
    }
}

int main()
{
    int nCases = 1;

    while (scanf("%d%d", &nW, &nH), nW + nH)
    {
        for (int i = 0; i < nH; ++i)
        {
            scanf("%s", szData[i]);
        }
        memset(bVisit, false, sizeof(bVisit));
        memset(nDice, 0, sizeof(nDice));
        nNum = 0;

        for (int i = 0; i < nH; ++i)
        {
            for (int j = 0; j < nW; ++j)
            {
                if (szData[i][j] == 'X'  bVisit[i][j] == false)
                {
                    dfs(i, j, nNum);
                    nNum++;
                }
            }
        }
        sort(nDice, nDice + nNum);

        printf("Throw %d\n", nCases++);
        for (int i = 0; i < nNum; ++i)
        {
            printf("%d%s", nDice[i], i == nNum - 1 ? "\n" : " ");
        }
        printf("\n");
    }

    return 0;
}

```