---
title: operator new 和placement new表达式
tags:
id: 1274
categories:
  - 编程语言 
  - C++
date: 2014-07-31 20:24:26
---

上一篇文章里面讲到用allocator预分配空间已经在需要的时候才构造对象，其实还有其它的办法实现这一功能。operator new表达式也可以只分配内存而不初始化，但是返回的是void指针，因此没有allocator类型化的优点。同样placement new表达式只负责调用指定的构造函数初始化内存，不申请内存，与allocator的construct相比，这个表达式更加方便，可以使用任意类型的构造函数参数列表。但是，construct只能使用复制构造函数。
同样的，可以使用operator delete代替allocator的deallocate释放内存。使用析构函数代替allocator的destroy清理对象。下面我把原来使用allocator的代码改写成使用这些表达式的。
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
            //allocator.destroy(--p);
            --p;
            p->~T();
        }

        if (elements)
        {
            //allocator.deallocate(elements, end - elements);
            operator delete[](elements);
        }
    }

    void push_back(const T t)
    {
        if (first_free == end)
        {
            reallocate();
        }

        //allocator.construct(first_free, t);//复制构造新对象
        new (first_free) T(t);
        ++first_free;
    }

    void pop_back()
    {
        if (first_free != elements)
        {
            //allocator.destroy(--first_free);
            --first_free;
            first_free->~T();
        }
    }

private:
    //std::allocator<T> allocator;
    void reallocate()
    {
        std::ptrdiff_t size = first_free - elements;
        std::ptrdiff_t newcapacity = 2 * std::max(size, 1);

        //T* newelements = allocator.allocate(newcapacity);//申请新内存
        T* newelements = static_cast<T*>(operator new[](newcapacity * sizeof(T)));

        //newelements处直接复制构造
        std::uninitialized_copy(elements, first_free, newelements);

        for (T* p = first_free; p != elements;)
        {
            //allocator.destroy(--p);//析构原对象
            --p;
            p->~T();
        }

        if (elements)
        {
            //allocator.deallocate(elements, end - elements);//释放内存
            operator delete[](elements);
        }

        elements = newelements;
        first_free = elements + size;
        end = elements + newcapacity;
    }

    T* elements;
    T* first_free;
    T* end;
};

//template <typename T> std::allocator<T> Vector<T>::allocator;
```
placement new表达式的一般形式是new (地址) 类型名(初始化列表)，由于使用初始化列表直接构造对象，因此不用拷贝。而且比只能用复制构造函数构造的allocator的construct函数更方便。
比如，allocator<T> alloc;string* sp = alloc.allocate(2);如果用定位new表达式，new (sp) string(b, e);(b,e是用2个迭代器构造string类型)。但是，用construct的话，则是alloc.construct(sp+1,string(b,e));可以清楚的看到，需要用迭代器构造个临时的string对象，再用这个临时对象调用复制构造函数。因此，会有细微的性能损失。最终要的是，有些类根本没有可以调用的复制构造函数，比如该函数是私有的，那么就必须使用placement new表达式了。
operator new和operator delete的使用方式类似于new和delete，具体的可以参看代码。