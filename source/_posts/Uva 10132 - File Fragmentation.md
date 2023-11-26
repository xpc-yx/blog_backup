---
title: Uva 10132 - File Fragmentation
tags:
  - 搜索
id: 140
categories:
  - 算法 
  - 算法题
date: 2012-03-30 10:00:00
---

这个题，粗看之下还没怎么看懂，这个应该跟我英语水平有关系。然后再看输入输出，渐渐的才明白什么意思。原来是要把2 * N张破纸组合成N张一样的纸。我历来思维比较随便，不是很严谨的那种。然后，想了一下发现一定会有大于等于N张破纸片是符合前半部分模式的。
那么，可以建一个字典树，把所有的是前半张纸的找出来。然后根据这前半张纸，找出剩下的后半张纸（因为知道一整张纸的长度，所以知道剩下的半张纸的长度）。但是写出来就发现这样不严谨，是不对的。因为单纯根据已经找出来的前半张纸，无法确定后半张纸（事实上，只能确定其长度而已）。
那么只能找其它方法了，再检查了下数据范围，发现比较小，那么意味着可以暴力求解了。好吧，那就深搜吧。我把所有的破纸片按照它们的长度分成一些集合，对于长度为len的纸片集合，只要与长度为nAnsLen - len的纸片集合进行搜索匹配，找出一个可行的解即可了。我又想当然的认为只要匹配一对集合即可了，那么很显然又是错的了。好吧，我只能对所有集合进行匹配了。对每一对集合进行深搜回溯来匹配待选的Ans，而这个Ans是从第一对集合中搜索出来的答案。
代码写得很冗长，很复杂，差不多200多行了。真的是水平有限，这种题很明显应该有更方便的解法的，而且我的代码应该不至于写得这么乱的。后面还是错了很多次，发现了很多bug，比如我如果搜索长度为nAnsLen/2的集合时就必须进行特殊处理。还有最后一个样例后面不能输出’\n'，而且uvaoj不能对这个换行判PE，一直是WA，实在是让人崩溃。

``` stylus
#include <stdio.h>
#include <string.h>
#define MAX (256 + 10)
#define MAX_NUM (150)

char szLines[MAX_NUM][MAX];
char szAns[MAX];

struct SET
{
    int nNum;
    char szLines[MAX_NUM][MAX];
    bool bUsed[MAX];
};

SET sets[MAX];
char szTmpOne[MAX];
char szTmpTwo[MAX];
int nAnsLen;
bool bFind;

void dfs(int nI, int nNum)
{
    if (nNum == 0)
    {
        bFind = true;
    }
    else
    {
        for (int i = 0; i < sets[nI].nNum && !bFind; ++i)
        {
            for (int j = 0; j < sets[nAnsLen - nI].nNum && !bFind; ++j)
            {
                if (nI == nAnsLen - nI && i == j)
                {
                    continue;
                }

                if (!sets[nI].bUsed[i] && !sets[nAnsLen - nI].bUsed[j])
                {
                    strcpy(szTmpOne, sets[nI].szLines[i]);
                    strcat(szTmpOne, sets[nAnsLen - nI].szLines[j]);
                    strcpy(szTmpTwo, sets[nAnsLen - nI].szLines[j]);
                    strcat(szTmpTwo, sets[nI].szLines[i]);

                    //printf("%s\n", szAns);
                    if (strcmp(szTmpOne, szAns) == 0 || strcmp(szTmpTwo, szAns) == 0)
                    {
                        sets[nI].bUsed[i] = sets[nAnsLen - nI].bUsed[j] = true;
                        if (!bFind)
                        {
                            if (nI == nAnsLen - nI)
                            {
                                dfs(nI, nNum - 2);
                            }
                            else
                            {
                                dfs(nI, nNum - 1);
                            }
                        }
                        sets[nI].bUsed[i] = sets[nAnsLen - nI].bUsed[j] = false;
                    }
                }
            }
        }
    }
}

bool Find(int nI)
{
    bFind = false;
    for (int i = 0; i < sets[nI].nNum && !bFind; ++i)
    {
        for (int j = 0; j < sets[nAnsLen - nI].nNum && !bFind; ++j)
        {
            if (nI == nAnsLen - nI && i == j)
            {
                continue;
            }

            sets[nI].bUsed[i] = true;
            sets[nAnsLen - nI].bUsed[j] = true;

            strcpy(szAns, sets[nI].szLines[i]);
            strcat(szAns, sets[nAnsLen - nI].szLines[j]);
            if (nI == nAnsLen - nI)
            {
                dfs(nI, sets[nI].nNum - 2);
            }
            else
            {
                dfs(nI, sets[nI].nNum - 1);
            }
            if (bFind)
            {
                for (int k = nI + 1; k <= nAnsLen / 2; ++k)
                {
                    bFind = false;
                    dfs(k, sets[k].nNum);
                    if (!bFind)
                    {
                        break;
                    }
                }
                if (bFind)
                {
                    return true;
                }
            }

            strcpy(szAns, sets[nAnsLen - nI].szLines[j]);
            strcat(szAns, sets[nI].szLines[i]);
            if (nI == nAnsLen - nI)
            {
                dfs(nI, sets[nI].nNum - 2);
            }
            else
            {
                dfs(nI, sets[nI].nNum - 1);
            }
            if (bFind)
            {
                for (int k = nI + 1; k <= nAnsLen / 2; ++k)
                {
                    bFind = false;
                    dfs(k, sets[k].nNum);
                    if (!bFind)
                    {
                        break;
                    }
                }
                if (bFind)
                {
                    return true;
                }
            }

            sets[nI].bUsed[i] = false;
            sets[nAnsLen - nI].bUsed[j] = false;
        }
    }

    return false;
}

void Search()
{
    for (int i = 0; i <= nAnsLen; ++i)
    {
        if (sets[i].nNum)
        {
            Find(i);
            break;
        }
    }
}

int main()
{
    int nCases;

#ifdef CSU_YX
    freopen("in.txt", "r", stdin);
    //freopen("out.txt", "w", stdout);
#endif
    scanf("%d\n", &nCases);

    int nNum = 0;
    int nTotalLen = 0;
    while (gets(szLines[nNum]), nCases)
    {
        if (szLines[nNum][0] == '\0' && nNum != 0)
        {
            nAnsLen = nTotalLen * 2 / nNum;
            memset(szAns, 0, sizeof(szAns));
            Search();
            printf("%s\n\n", szAns);

            memset(sets, 0, sizeof(sets));
            memset(szLines, 0, sizeof(szLines));
            nNum = 0;
            nTotalLen = 0;
            --nCases;
        }
        else if (szLines[nNum][0] != '\0')
        {
            int nLen = strlen(szLines[nNum]);
            nTotalLen += nLen;
            strcpy(sets[nLen].szLines[sets[nLen].nNum], szLines[nNum]);
            ++sets[nLen].nNum;
            ++nNum;
        }
    }

    return 0;
}
```