---
title: allocator的一些理解
tags:
  - allocator
id: 1263
categories:
  - 编程语言
  - C/C++
  - STL
date: 2014-07-31 10:52:54
---

相信大家都用过vector，而且用多了之后会发现怎么还有一个我们基本上不会使用的模版参数Allocator。查阅msdn能够看到，vector的类型是template <class Type, class Allocator = allocator<Type> >class vector。那么这个Allocator到底是用来做什么的了。实际上，Allocator是stl里面用到的内存管理工具，因为这个时候new和delete已经不能满足要求了。
比如说，vector需要预分配内存，需要添加元素。如果使用new分配内存的话，那么在预分配内存的时候就会调用一次构造函数，添加元素的时候会调用一次赋值操作符。其实，这些操作都是冗余的，会降低效率。这也是stl和手写容器的最大区别。如果使用allocator，那么可以把**分配内存和构造操作分开**，在预分配内存的时候单纯分配空间，不构造，而在添加新元素的时候，调用复制构造函数。
要达到这样的要求，需要allocator提供对应的接口。实际上，std::allocator有allocate和deallocate负责内存申请释放，construct和destroy负责对象构造和析构。下面来解析相关模拟的代码。
``` stylus
#include <memory>
#include <algorithm>

template <typename T>
class Vector
{
public:
    Vector() : elements(0), first_free(0), end(0) {}
    ~Vector()
    {
        for (T* p = first_free; p != elements;)
        {
            allocator.destroy(--p);
        }

        if (elements)
        {
            allocator.deallocate(elements, end - elements);
        }
    }

    void push_back(const T t)
    {
        if (first_free == end)
        {
            reallocate();
        }

        allocator.construct(first_free, t);//复制构造新对象
        ++first_free;
    }

    void pop_back()
    {
        if (first_free != elements)
        {
            allocator.destroy(--first_free);
        }
    }

private:
    static std::allocator<T> allocator;
    void reallocate()
    {
        std::ptrdiff_t size = first_free - elements;
        std::ptrdiff_t newcapacity = 2 * std::max(size, 1);

        T* newelements = allocator.allocate(newcapacity);//申请新内存
        //newelements处直接复制构造
        std::uninitialized_copy(elements, first_free, newelements);

        for (T* p = first_free; p != elements;)
        {
            allocator.destroy(--p);//析构原对象
        }

        if (elements)
        {
            allocator.deallocate(elements, end - elements);//释放内存
        }

        elements = newelements;
        first_free = elements + size;
        end = elements + newcapacity;
    }

    T* elements;
    T* first_free;
    T* end;
};

template <typename T> std::allocator<T> Vector<T>::allocator;
```
在push_back里面，使用allocator.construct(first_free, t)初始化内容，相当于调用复制构造函数。如果空间已满，调用reallocate。在这里面用allocator.allocate(newcapacity)申请原来2倍大小的空间，这个操作不会调用构造函数。有意思的是接下来调用uninitialized_copy，这个函数直接在新地址上面使用原来的值构造对象，而不是赋值。然后，循环析构原来对象，释放原来内存。如果清楚了解复制构造函数和赋值操作的区别，那么理解allocator的意义是很容易的。关于这个，可以阅读我[另外一篇文章](http://www.xpc-yx.com/2013/12/19/%E6%8B%B7%E8%B4%9D%E6%9E%84%E9%80%A0%E5%87%BD%E6%95%B0%E7%9A%84%E7%90%86%E8%A7%A3%E9%94%99%E8%AF%AF/ "拷贝构造函数的理解错误")。
另外一个关于模版类静态成员的初始化，大家可以看到我直接写在**头文件**的最后一句了。如果写在源文件里面，那么特例化模版才能定义静态成员。而这样直接包含头文件就可以使用了，不信大家可以试试。我的环境是vs2013。