---
title: 'CSU OJ - 1219: 建食堂 (所有结点间的最短路径)'
tags:
  - 搜索
id: 74
categories:
  - 算法
  - 算法题
date: 2011-12-04 10:00:00
---

链接:[http://acm.csu.edu.cn/OnlineJudge/problem.php?id=1219](http://acm.csu.edu.cn/OnlineJudge/problem.php?id=1219)

这个题就是求出所有结点的距离之后,再找出某个结点,该结点离其它结点的最大距离是所有结点中是最小的...
解法1:深搜出所有结点间的距离,但是会超时,即使深搜的过程使用中记忆化搜索(就是用2维数组保存已经搜出的答案,如果后面的搜索需要用到直接使用即可)...
解法2:Floyd算法,3重循环直接找出所有结点之间的最短距离
解法3:对每一个结点应用一次迪杰斯特拉算法,找出所有结点与其它结点间的最短距离...

解法2:

``` stylus
#include <stdio.h>
#include <string.h>
#define MAX  (100 + 10)
#define INF (1000000 + 10)
int nN, nM;
int nDis[MAX][MAX];
void SearchAll()
{
    for (int k = 0; k < nN; ++k)
    {
        for (int i = 0; i < nN; ++i)
        {   
            for (int j = 0; j < nN; ++j)
            {
                if (nDis[i][k] + nDis[k][j] < nDis[i][j])
                {
                    nDis[i][j] = nDis[j][i] = nDis[i][k] + nDis[k][j];
                }
            }
        }
    }
}
int main()
{
    while (scanf("%d%d", &nN, &nM) == 2)
    {
        for (int i = 0; i < nN; ++i)
        {
            for (int j = 0; j < nN; ++j)
            {
                if (i == j)
                {
                    nDis[i][j] = 0;
                }
                else
                {
                    nDis[i][j] = INF;
                }
            }
        }
        while (nM--)
        {
            int nX, nY, nK;
            scanf("%d%d%d", &nX, &nY, &nK);
            nDis[nX][nY] = nDis[nY][nX] = nK;
        }
        SearchAll();
        bool bOk = false;
        int nMin = 1 << 30;

        for (int i = 0; i < nN; ++i)
        {
            int nTemp = 0;
            int j = 0;
            for ( ; j < nN; ++j) 
            { 
                if (i == j) continue; 
                if (nDis[i][j] == INF) 
                { 
                    break; 
                } 
                else 
                { 
                    if (nDis[i][j] > nTemp)
                    {
                        nTemp = nDis[i][j];
                    }
                }
            }
            if (j == nN)
            {
                bOk = true;
                if (nTemp < nMin)
                {
                    nMin = nTemp;
                }
            }
        }

        if (bOk)
        {
            printf("%d\n", nMin);
        }
        else
        {
            printf("Can not\n");
        }
    }
    return 0;
}
```

关于Floyd算法,可以这样理解...比如刚开始只取2个结点i,j,它们的距离一定是dis(i,j),但是还有其它结点,需要把其它结点也慢慢加进来,所以最外层关于k的循环意思就是从0至nN-1,把所有其它结点加进来,比如加入0号结点后,距离dis(i,0)+dis(0,j)可能会比dis(i,j)小,如果是这样就更新dis(i,j),然后后面加入1号结点的时候,实际上是在已经加入0号结点的基础上进行的处理了,效果变成dis(i,0,1,j),可能是最小的,而且中间的0,1也可能是不存在的,当然是在dis(i,j)原本就是最小的情况下...
这个算法可以用下面这个图片描述...
![](https://c5.staticflickr.com/8/7303/26782450284_e07c633d3f_o.jpg)

解法3:

``` stylus
#include <stdio.h>
#include <string.h>
#define MAX  (100 + 10)
#define INF (1000000 + 10)
int nN, nM;
int nDis[MAX][MAX];
void Search(int nSource)
{
    bool bVisit[MAX];
    memset(bVisit, false, sizeof(bVisit));
    bVisit[nSource] = true;
    for (int i = 0; i < nN - 1; ++i)
    {
        int nMin = INF;
        int nMinPos = 0;
        for (int j = 0; j < nN; ++j)
        {
            if (!bVisit[j] && nDis[nSource][j] < nMin)
            {
                nMin = nDis[nSource][j];
                nMinPos = j;
            }
        }
        if (bVisit[nMinPos] == false)
        {
            bVisit[nMinPos] = true;
            for (int j = 0; j < nN; ++j)
            {
                if (nDis[nSource][nMinPos] + nDis[nMinPos][j] < nDis[nSource][j])
                {
                    nDis[nSource][j] = nDis[nSource][nMinPos] + nDis[nMinPos][j];
                }
            }
        }
    }
}
void SearchAll()
{
    for (int k = 0; k < nN; ++k)
    {
        Search(k);
    }
}
int main()
{
    while (scanf("%d%d", &nN, &nM) == 2)
    {
        for (int i = 0; i < nN; ++i)
        {
            for (int j = 0; j < nN; ++j)
            {
                if (i == j)
                {
                    nDis[i][j] = 0;
                }
                else
                {
                    nDis[i][j] = INF;
                }
            }
        }
        while (nM--)
        {
            int nX, nY, nK;
            scanf("%d%d%d", &nX, &nY, &nK);
            nDis[nX][nY] = nDis[nY][nX] = nK;
        }
        SearchAll();
        bool bOk = false;
        int nMin = 1 << 30;
        for (int i = 0; i < nN; ++i)
        {
            int nTemp = 0;
            int j = 0;
            for ( ; j < nN; ++j) 
            { 
                if (i == j) continue; 
                if (nDis[i][j] == INF) 
                { 
                    break;
                } 
                else
                { 
                    if (nDis[i][j] > nTemp)
                    {
                        nTemp = nDis[i][j];
                    }
                }
            }
            if (j == nN)
            {
                bOk = true;
                if (nTemp < nMin)
                {
                    nMin = nTemp;
                }
            }
        }
        if (bOk)
        {
            printf("%d\n", nMin);
        }
        else
        {
            printf("Can not\n");
        }
    }
    return 0;
}
```

迪杰斯特拉算法的核心思想是维护一个源点顶点集合,任何最短路径一定是从这个顶点集合发出的...
初始化时,这个集合就是源点...
我们从该其它结点中选出一个结点,该结点到源点的距离最小...
显然,这个距离就是源点到该结点的最短距离了,我们已经找到了答案的一部分了...然后,我们就把该结点加入前面所说的顶点集合...
现在顶点集合更新了,我们必须得更新距离了...由于新加入的结点可能发出边使得原来源点到某些结点的距离更小,也就是我们的源点变大了,边也变多了,所以我们的最短距离集合的值也必须变化了...
该算法一直循环nN-1次,直至所有的点都加入源点顶点集合...