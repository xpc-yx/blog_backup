---
title: 快排的N种写法
tags:
  - 尾递归
  - 快排
  - 随机算法
  - 非递归
id: 1332
categories:
  - 算法
date: 2014-10-09 14:51:00
---

首先声明下，只扯面试时候容易手写出来的代码。不写类似于stl里面实现sort的优化部分，包括递归层次太深了改用堆排序，还有当序列长度小于一定值，改用插排，等等。
这里只讲快排主函数的三种写法和partion的两种写法，加上轴元素的选择。
为了兼容stl，假设传入的参数是指针(直接可以换成迭代器了)。
所以主函数应该是这样的接口:void QSort(int*beg, int* end);
主函数写法1---分治递归，也就是常用的写法。
``` stylus
void QSort(int* beg, int* end)
{
    if (beg >= end)
    {
        return;
    }

    int* middle = Partion(beg, end);
    QSort(beg, middle);
    QSort(middle + 1, end);

}
```
这个是最直观，最简单的写法，至于快排的思路就不介绍了。下面是将其改成循环形式的递归，也有人说这是尾递归，但是当前栈不能完全消除额。所以，到底是不是尾递归了？
``` stylus
void QSort(int* beg, int* end)
{
    if (beg >= end)
    {
        return;
    }

    while (beg < end)
    {
        int* middle = Partion(beg, end);
        QSort(beg, middle);
        beg = middle + 1;
    }
}
```
说下我对这种写法的理解。其实，推广一下，分治造成的多次递归调用都可以改成这种循环形式。这样的话，双支就变成单支了，至少能减少爆栈的可能性。其余的好处，应该不大吧。问题是，如何将其改成这种循环形式了。额，其实可以这样想。分治的话，是划分为多个子问题，那么循环尾递归的话，是一次处理原问题的一部分，不断减少原问题，那么代码思路就顺理成章的出来了。上面的代码[beg,end)就代表的是问题空间，每次循环一直在减小这个空间。
下面说一个更少见的写法，就是将递归改成非递归。其实了，这种写法，会的人觉得很简单，不会的人就会觉得少见。递归改循环，大家都知道是加个栈，问题是如何用栈模拟递归了。
``` stylus
void QSort(int* beg, int* end)
{
    if (beg >= end)
    {
        return;
    }

    struct Infor
    {
        int* beg;
        int* end;
        Infor(int* b = 0, int* e = 0) : beg(b), end(e) {}
    };

    stack<Infor> si;
    si.push(Infor(beg, end));

    while (si.size())
    {
        Infor in = si.top();
        si.pop();

        int* middle = Partion(in.beg, in.end);

        if (middle > in.beg)
        {
            si.push(Infor(in.beg, middle));
        }

        if (middle  + 1 < in.end)
        {
            si.push(Infor(middle + 1, in.end));
        }
    }
}
```
从上面的代码中，能够体会到，其实在栈里面存储下递归的参数就行了。栈反正是先入后出的，递归不也是这样么？那么，我们可以采用模拟先序，中序，或者后序遍历树的方法，任何递归都能够模拟出来吧，只是代码复杂程度的问题了。只是真正理解这个，需要一点点时间而已。上面的代码，其实就是用栈模拟了先序遍历二叉树吧。
那么剩下的就是partion函数了。
先来一个教科书版本的代码。
``` stylus
int* Partion(int* beg, int* end)
{
    --end;
    int tmp = *end;
    while (beg < end)
    {
        while (beg < end  *beg <= tmp) ++beg;
        *end = *beg;

        while (beg < end  *end >= tmp) --end;
        *beg = *end;
    }
    *end = tmp;

    return end;
}
```
这个代码应该非常常见，大部分写法就是这种。首先，看到轴元素是在end处。所以了，将end处的元素暂存，所以end就空出来了。因此，先从头开始遍历到第一个大于*end的元素，然后将其放入end。剩下的一个循环就是从后面往前面遍历了。最后大循环结束时候，beg必定等于end，而且必定放的是一个重复的元素，所以了，放入轴元素就行了。
下面介绍种更简便的写法。
``` stylus
int* Partion(int* beg, int* end)
{
    --end;
    int* small = beg;
    while (beg < end)
    {
        if (*beg < *end)
        {
            if (beg != small)
            {
                swap(*beg, *small);
            }

            ++small;
        }

        ++beg;
    }
    swap(*end, *small);

    return small;
}
```
这个代码只要一个循环，思路是[0,small)中放小于轴元素的数字，保持这个集合就行了。那么，最终轴元素就应该放在small处。理解下吧，这个代码更方面手写出来。
现在还剩个更严重的问题，如何消除快排的最坏情况出现的可能。最坏情况出现在输入数据本身有序的时候。
如果听说过随机算法，那么这个问题就知道怎么轻松解决了。在算法中，加入随机性操作吧。在partion，可以随机选择轴元素，也可以采用三点取中法选择轴元素。至于证明，参加算法导论。
``` stylus
int* Partion(int* beg, int* end)
{
    int len = end - beg;

    swap(beg[rand() % len], *(end - 1));//随机选取轴元素

    --end;
    int* small = beg;
    while (beg < end)
    {
        if (*beg < *end)
        {
            if (beg != small)
            {
                swap(*beg, *small);
            }

            ++small;
        }

        ++beg;
    }
    swap(*end, *small);

    return small;
}
```
三点取中法。
``` stylus
int* Partion(int* beg, int* end)
{
    int len = end - beg;
    int* middle = beg + len / 2;
    --end;
    if (*middle < *beg)
    {
        swap(*middle, *beg);
    }
    if (*end < *beg)//最小
    {
        swap(*beg, *end);
    }
    else if (*end > *middle)//最大
    {
        swap(*middle, *end);
    }

    int* small = beg;
    while (beg < end)
    {
        if (*beg < *end)
        {
            if (beg != small)
            {
                swap(*beg, *small);
            }

            ++small;
        }

        ++beg;
    }
    swap(*end, *small);

    return small;
}
```
组合这些不同的写法，确实可以出现很多个版本的快排算法了。。。