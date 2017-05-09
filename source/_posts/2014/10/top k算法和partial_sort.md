---
title: top k算法和partial_sort
tags:
  - partial_sort
  - top k
id: 1329
categories:
  - STL
  - 算法
date: 2014-10-08 11:04:40
---

最近因为准备找工作的东西，看了不少书，感悟也挺多的。stl源码剖析，effective c++，面试宝典，剑指offer，大话设计模式，编程精粹，还有很多想看的还没看完了。。。这段时间，看完这些书后，真的发现，看书是一件很棒的事情，不仅仅是知识的学习，查漏补缺，思维的体验也是一件让人觉得满心愉悦的事情。有点明白古人雪夜读书的感觉，那时候没有电脑可以玩，没有那么多娱乐的游戏，读书确实是一件让人愉悦的事情。
很久没有更新博客了，随便扯扯吧。
所谓的top k算法，意思就是求n个数字的最大k个或者最小k个，大概也是个比较常见的面试题了。一般有两种思路，第一种是利用快排里面的partion函数，不断用轴元素分割数组，直到分割出前k个或者后k个，迭代或者递归都是很方便的；stl里面有个nth_element泛函做的就是这件事情。第二种思路，则是假定有一个容量为k的容器，存储了当前的top k元素，当处理下一个元素的时候，判断当前处理元素是否可能是top k元素，比如如果求最大的k个元素，则判断当前处理元素是否比容器里面最小元素大，如果大的话，则需要加入当前元素，并且删除容器里面最小的元素，反之亦然。现在的问题是，如何选取一个很好的容器了。能够使得这些操作尽可能快。其实大家知道的容器也就那几种类型，基本上是stl里面已经实现了的。线性？搜索树？hash？
hash的话，没法快速查找极值，线性结构的话，插入新元素，保持有序结构的话，也需要O(n)。那么，搜索树结构了，查找和删除都是log(n)，stl里面有现成的红黑树实现set容器。另外，还有个更奇葩的用数组表示的完全二叉树结构，最大堆和最小堆。可以满足O(1)查找极值元素和log(n)插入删除操作，最终还可以排序元素。综上所说，堆结构是在时间和空间上最佳的满足要求的容器了。
刚好stl里面有个partial_sort函数也是用这个思路实现的，而且最后还排了一个序，所以，实际开发的时候多了解下标准库是值得投入的一件事情。
下面是用stl的heap操作实现的top k算法。
``` stylus
#include <cstdlib>
#include <iostream>
#include <vector>
using namespace std;

int main()
{
    vector<int> vi;
    const int NUM = 100;

    for (int i = 0; i < NUM; ++i)
    {
        vi.push_back(rand() % NUM);
        printf("%d ", vi[i]);
    }
    printf("\n");

    //求最小k个数字
    const int K = 10;

    make_heap(vi.begin(), vi.begin() + K);
    for (int i = K; i < NUM; ++i)
    {
        if (vi[i] < vi[0])
        {
            pop_heap(vi.begin(), vi.begin() + K);
            vi[K - 1] = vi[i];
            push_heap(vi.begin(), vi.begin() + K);
        }
    }

    sort_heap(vi.begin(), vi.begin() + K);
    for (int i = 0; i < K; ++i)
    {
        printf("%d ", vi[i]);
    }
    printf("\n");

    return 0;
}
```