---
title: poj 2823 Sliding Window 单调队列
tags:
  - 单调队列
id: 248
categories:
  - ACM-ICPC
date: 2012-09-02 10:00:00
---

这道题的意思是给定一个长N的整数序列，用一个大小为K的窗口从头开始覆盖，问第1-第N-K次窗口里面最大的数字和最小的数字。刚开始还以为优先级队列可以做，发现无法删除最前面的元素。估计用线段树这个题也是可以解得。用这个题学了下单调队列。
单调队列正如其名，是一个从小到大排序的队列，而且能够保证所有的元素入队列一次出队列一次，所以平摊到每个元素的复杂度就是O(1)。
对于这个题单调队列的使用。以序列1 3 -1 -3 5 3 6 7举例。
1）元素类型：一个结构体，包含数字大小和位置，比如(1，1），（3，2）。
2）插入操作：从队尾开始查找，把队尾小于待插入元素的元素全部删除，再加入待插入的元素。这个操作最坏的情况下是O(n)，但是我们采用聚集分析的方法，知道每个元素最多删除一次，那么N个元素删除N次，平摊到每一次操作的复杂度就是O(1)了。
3）删除队首元素：比如本文给的那个题，窗口一直往后移动，每一次移动都会删除一个元素，所以很可能队首会是要删除的元素，那么每次移动窗口的元素要进行一次检查，如果队首元素失效的话，就删掉队首元素。
代码的实现，我是包装deque实现了一个模版类。速度很不好，居然跑了11s多才过，幸亏给了12s的时间，看status又500多ms就过了的。估计数组实现会快很多。

代码如下：
``` stylus
#include <stdio.h>
#include <deque>
#include <algorithm>
using namespace std;
#define MAX_N (1000000 + 100)
int nNum[MAX_N];
int nN, nK;

struct Small
{
    int nValue;
    int nIndex;
    Small(int nV, int index):nValue(nV), nIndex(index) {}
    bool operator < (const Small a) const
    {
        return nValue < a.nValue;
    }
};

struct Big
{
    int nValue;
    int nIndex;
    Big(int nV, int index):nValue(nV), nIndex(index) {}
    bool operator < (const Big a) const
    {
        return nValue > a.nValue;
    }
};

//单调队列
template <typename T> class Monoque
{
    deque<T> dn;

public:
    void Insert(T node)
    {
        int nPos = dn.size() - 1;
        while (nPos >=0  node < dn[nPos])
        {
            --nPos;
            dn.pop_back();
        }
        dn.push_back(node);
    }

    int Top()
    {
        return dn.front().nValue;
    }

    void Del(int nBeg, int nEnd)
    {
        if (dn.size() > 0)
        {
            if (dn.front().nIndex < nBeg || dn.front().nIndex > nEnd)
            {
                dn.pop_front();
            }
        }
    }
};

int main()
{
    while (scanf("%d%d", &nN, &nK) == 2)
    {
        int i;
        for (i = 0; i < nN; ++i)
        {
            scanf("%d", &nNum[i]);
        }
        Monoque<Small> minQ;
        Monoque<Big> maxQ;

        for (i = 0; i < nK; ++i)
        {
            minQ.Insert(Small(nNum[i], i));
        }

        for (i = 0; i < nN - nK; ++i)
        {
            printf("%d ", minQ.Top());
            minQ.Insert(Small(nNum[i + nK], i + nK));
            minQ.Del(i + 1, i + nK);
        }
        printf("%d\n", minQ.Top());

        for (i = 0; i < nK; ++i)
        {
            maxQ.Insert(Big(nNum[i], i));
        }

        for (i = 0; i < nN - nK; ++i)
        {
            printf("%d ", maxQ.Top());
            maxQ.Insert(Big(nNum[i + nK], i + nK));
            maxQ.Del(i + 1, i + nK);
        }
        printf("%d\n", maxQ.Top());
    }

    return 0;
}
```