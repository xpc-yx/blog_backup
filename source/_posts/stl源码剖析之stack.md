---
title: stl源码剖析之stack
tags:
  - stack
  - stl源码剖析
id: 1461
categories:
  - 编程语言
  - C/C++
  - STL
date: 2014-12-31 11:22:15
---

类似于queue，stack也是个简单的适配器。在实现上，stack与queue非常类似。底层可以使用同样的容器，比如默认都采用deque。因此，stack的源码和queue的非常类似。代码过于简单，都可以自解释了。下面是摘录出来的代码，可以顺便编译通过。

``` stylus
#ifndef _STL_STACK_H
#define _STL_STACK_H

namespace std
{
    template <class T, class Sequence = deque<T> >
    class stack {
        friend bool operator==(const stack, const stack);
        friend bool operator<(const stack, const stack);

    public:
        typedef typename Sequence::value_type value_type;
        typedef typename Sequence::size_type size_type;
        typedef typename Sequence::reference reference;
        typedef typename Sequence::const_reference const_reference;
    protected:
        Sequence c; // 底层容器

    public:
        // 以下完全利用 Sequence c 的操作，完成 stack 的操作。
        bool empty() const { return c.empty(); }
        size_type size() const { return c.size(); }
        reference top() { return c.back(); }
        const_reference top() const { return c.back(); }

        // deque 是两头可进出，stack 是末端进，末端出（所以后进者先出）。
        void push(const value_type x) { c.push_back(x); }
        void pop() { c.pop_back(); }
    };

    template <class T, class Sequence>
    bool operator==(const stack<T, Sequence> x, const stack<T, Sequence> y) {
        return x.c == y.c;
    }

    template <class T, class Sequence>
    bool operator<(const stack<T, Sequence> x, const stack<T, Sequence> y) {
        return x.c < y.c;
    }

};

#endif
```

代码非常类似于queue，除了pop弹出的是末尾元素，top也是返回末尾元素之外。