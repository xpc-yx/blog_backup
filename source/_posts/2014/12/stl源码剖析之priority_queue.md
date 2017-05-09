---
title: stl源码剖析之priority_queue
tags:
  - priority_queue
  - stl源码剖析
id: 1445
categories:
  - C/C++
  - STL
date: 2014-12-29 10:59:24
---

暑假时候好好阅读过，stl源码剖析这本书，之后又看了c++标准程序库，effective c++，more
effecttive c++。虽然每次都如醍醐灌顶般，明白了很多知识概念，有种拨开迷雾的感觉，但是终究抵不过
遗忘，所以了还是随便写写吧。
首先从实现代码差不多最短的优先队列开始，虽然简单的代码后面依赖很庞大的东西，比如泛型
迭代器，还有泛型二叉堆算法。我是这样理解优先队列的。首先，数据是存在一个泛型序列容器(线性容器)，
这个可以指定，默认是vector，当然指定list和deque也是可以的。另外还需要给数据类型提供个小于比较仿
函数，有些类型有默认的less泛型仿函数。所以了，对模版比较熟悉的同学，很自然就猜到了，priority_queue
的外观->一个模版（类型，线性容器，less仿函数）。
优先队列支持哪些操作了？什么empty，size，top，直接转交给底层容器就行了，所谓的适配器模式。
只需要思考，如何实现push和pop操作。对算法熟悉的同学，都知道底层数据的组织是用二叉堆的，而且是最大
堆。问题是，我们还需不需要实现个堆操作了。不需要了，stl做了所有的事情。push_heap就是将输入范围的最
后一个元素作为在原堆后面加入的新元素，再重构堆。pop_heap则是将堆首元素交换到堆末，再重构缩小之后的堆。
至于二叉堆的原理，就不仔细介绍了。其实也比较简单，如果不去思考一些复杂度的证明。
到最后，priority_queue的代码可以很清爽的出来了。尤其注意下面的那些typedef，可以说是模版
trick的常见手法，习惯了就好。这种写法还有个用法是为了使内嵌模版声明可见，记得effect c++提到过。以下
源码基本来自stl源码剖析随书奉送代码，做了些修改。
``` stylus
#include <algorithm>

template <typename T, typename Sequence = vector<T>,
    typename Compare = less<typename Sequence::value_type >>
class  priority_queue
{
public:
    typedef typename Sequence::value_type value_type;
    typedef typename Sequence::size_type size_type;
    typedef typename Sequence::reference reference;
    typedef typename Sequence::const_reference const_reference; //为了使内嵌模版声明可见

protected:
    Sequence c; // 底层容器
    Compare comp;   // 元素大小比较仿函数

    priority_queue() : c() {}
    explicit priority_queue(const Compare x) : c(), comp(x) {}

    template <class InputIterator>
    priority_queue(InputIterator first, InputIterator last, const Compare x)
        : c(first, last), comp(x) {
        make_heap(c.begin(), c.end(), comp);
    }

    template <class InputIterator>
    priority_queue(InputIterator first, InputIterator last)
        : c(first, last) {
        make_heap(c.begin(), c.end(), comp);
    }

    bool empty() const { return c.empty(); }
    size_type size() const { return c.size(); }
    const_reference top() const { return c.front(); }

    void push(const value_type x)
    {
        try
        {
            c.push_back(x);
            push_heap(c.begin(), c.end(), comp);
        }
        catch (...)
        {
            c.clear();
            throw;
        }
    }

    void pop()
    {
        try
        {
            pop_heap(c.begin(), c.end(), comp);
            c.pop_back();
        }
        catch (...)
        {
            c.clear();
            throw;
        }
    }
};
```
再啰嗦几句，刚看源码剖析的时候，对某些模版写法很头疼，但是看完书之后，另外看了几本其它的书，
就对这些写法习以为常了，觉得不这么写才怪了。有点艺术的感觉。