---
title: stl源码剖析之queue
tags:
  - stl源码剖析
id: 1455
categories:
  - 编程语言 
  - C++
  - STL
date: 2014-12-31 11:03:28
---

接着上面一篇，这次要讲的是另一个适配器容器queue。queue的操作很简单，先进先出。现在能够使用底层容器来实现，所以也非常简单。总之，这就是个简单的适配器吧。queue需要两个模版参数，类型和底层容器，默认的底层容器是deque。摘录出的代码如下：

``` stylus
#ifndef _STL_QUEUE_H
#define _STL_QUEUE_H
#include <deque>

namespace std
{
    template <class T, class Sequence = deque<T> >
    class queue {
        friend bool operator== (const queue x, const queue y);
        friend bool operator< (const queue x, const queue y);

    public:
        typedef typename Sequence::value_type value_type;
        typedef typename Sequence::size_type size_type;
        typedef typename Sequence::reference reference;
        typedef typename Sequence::const_reference const_reference;

    protected:
        Sequence c; // 底层容器

    public:
        // 以下完全利用 Sequence c 的操作，完成 queue 的操作。
        bool empty() const { return c.empty(); }
        size_type size() const { return c.size(); }
        reference front() { return c.front(); }
        const_reference front() const { return c.front(); }
        reference back() { return c.back(); }
        const_reference back() const { return c.back(); }

        // deque 是两头可进出，queue 是末端进，前端出（所以先进者先出）。
        void push(const value_type x) { c.push_back(x); }
        void pop() { c.pop_front(); }
    };

    template <class T, class Sequence>
    bool operator==(const queue<T, Sequence> x, const queue<T, Sequence> y) {
        return x.c == y.c;
    }

    template <class T, class Sequence>
    bool operator<(const queue<T, Sequence> x, const queue<T, Sequence> y) {
        return x.c < y.c;
    }

};

#endif

```

总之，代码非常简洁。分析下代码，<span style="font-family: Consolas, Monaco, 'Bitstream Vera Sans Mono', 'Courier New', Courier, monospace; font-size: 13px; line-height: 1.5;">typedef typename Sequence::value_type value_type;</span>这其实，就是声明嵌套模版类型。还有必须注意的是，声明嵌套模版类型，必须加typename关键字，否则会将其视作定义。