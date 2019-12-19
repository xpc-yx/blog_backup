---
title: hdu 3627 Giant For
tags:
id: 215
categories:
  - ACM-ICPC
date: 2012-07-11 11:00:00
---

这个题是对可排序数据的实时增加删除查找，那天做比赛的时候一点都不会，想来想去觉得平衡树可以做，但是写平衡树是件很难的事情。
后面知道线段数可以做，虽然数据的范围很大，但是可以在全部读入数据后排序再离散化，然后进行线段树的操作，具体的代码没有写。
今天队友在网上发现一种用map和set可以水掉这题的方法。原来，这个方法最主要的使用了map和set里面的upper_bound操作，以前居然忘记了这个东西了。既然这样，map和set也可以查前驱和后继了，但是注意low_bound查到的是小于等于的键。这个代码，注意是用了一个map< int, set > 集合把坐标都存起来了，进行添加删除和查找后继的操作。由于查找需要查找的元素是既比x大又比y大的元素，就比较麻烦，需要循环x往后查找，但是这样就无情的超时了。然后，有一个优化，记录y的数目，那么当出现很大的y的时候，就不需要查找了，然后才过了这个题。但是，数据变成很大的y对应的x很小的话，那么绝对过不了这个题了，只能用线段树做了。
现在觉得用map和set查找前驱和后继确实能水掉一些题啊。

代码如下：
``` stylus
#include <map>
#include <set>
#include <stdio.h>
using namespace std;

map< int, set<int> > ms;//存储x,y
map< int, set<int> >::iterator it;
map<int, int> my;//存储y的数目
set<int>::iterator msit;
int main()
{
    int nN;
    int nCase = 1;
    char szCmd[10];
    int nX, nY;
    int nTemp;

    while(scanf("%d", &nN), nN)
    {
        if (nCase > 1)
        {
            printf("\n");
        }

        printf("Case %d:\n", nCase++);
        ms.clear();
        my.clear();
        while (nN--)
        {
            scanf("%s", szCmd);
            scanf("%d%d", &nX, &nY);
            if (szCmd[0] == 'a')
            {
                if (my.find(nY) == my.end())
                {
                    my[nY] = 1;
                }
                else
                {
                    my[nY]++;
                }

                if (ms.find(nX) == ms.end())
                {
                    ms[nX].insert(nY);
                }
                else
                {
                    msit = ms[nX].find(nY);
                    if (msit == ms[nX].end())//会出现重复的数据
                    {
                        ms[nX].insert(nY);
                    }
                }
            }
            else if (szCmd[0] == 'r')
            {
                ms[nX].erase(nY);
                if(ms[nX].size() == 0)
                {
                    ms.erase(nX);
                }
                my[nY]--;
                if (my[nY] == 0)
                {
                    my.erase(nY);
                }
            }
            else if (szCmd[0] == 'f')
            {
                if (my.upper_bound(nY) == my.end())
                {
                    printf("-1\n");
                    continue;
                }
                while (true)
                {
                    it = ms.upper_bound(nX);
                    if (it == ms.end())//比nX大的不存在
                    {
                        printf("-1\n");
                        break;
                    }
                    nTemp = it->first;
                    msit = ms[nTemp].upper_bound(nY);
                    if (msit == ms[nTemp].end())//比nY大的不存在
                    {
                        nX = nTemp;
                        continue;//那么增加x,继续往后查
                    }
                    else
                    {
                        printf("%d %d\n", nTemp, *msit);
                        break;
                    }
                }
            }
        }
    }

    return 0;
}
```