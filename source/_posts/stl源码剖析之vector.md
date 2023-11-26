---
title: stl源码剖析之vector
tags:
  - stl源码剖析
id: 1606
categories:
  - 编程语言 
  - C++
  - STL
date: 2015-06-10 11:44:42
---

vector是一直在用的东西，太常用了，数组的替代品。大多数时候，都想不出理由不用vector，改用list，deque之类的。从功能来看，vector就是一个动态的数组而已。使用vector时候，唯一需要注意的是，当重新申请更大空间时候，是去了一块新内存，而不是直接在原地址增加，所有迭代器是都会失效的。当然还有其它操作造成某些迭代器失效。

下面来看看vector的部分定义。全部定义过于冗长了。

``` stylus
template <class T, class Alloc = alloc>  // 預設使用 alloc 為配置器
class vector {
public:
  // 以下標示 (1),(2),(3),(4),(5)，代表 iterator_traits<I> 所服務的5個型別。
  typedef T value_type;             // (1)
  typedef value_type* pointer;          // (2)
  typedef const value_type* const_pointer;
  typedef const value_type* const_iterator;
  typedef value_type reference;         // (3)
  typedef const value_type const_reference;
  typedef size_t size_type;
  typedef ptrdiff_t difference_type;    // (4)
  // 以下，由於vector 所維護的是一個連續線性空間，所以不論其元素型別為何，
  // 原生指標都可以做為其迭代器而滿足所有需求。
  typedef value_type* iterator;

protected:
  // 專屬之空間配置器，每次配置一個元素大小
  typedef simple_alloc<value_type, Alloc> data_allocator;

  // vector採用簡單的線性連續空間。以兩個迭代器start和end分別指向頭尾，
  // 並以迭代器end_of_storage指向容量尾端。容量可能比(尾-頭)還大，
  // 多餘即備用空間。
  iterator start;
  iterator finish;
  iterator end_of_storage;

  void insert_aux(iterator position, const T x);
  void deallocate() {
    if (start)
         data_allocator::deallocate(start, end_of_storage - start);
  }

  void fill_initialize(size_type n, const T value) {
    start = allocate_and_fill(n, value);  // 配置空間並設初值
    finish = start + n;             // 調整水位
    end_of_storage = finish;            // 調整水位
  }

public:
  iterator begin() { return start; }
  const_iterator begin() const { return start; }
  iterator end() { return finish; }
  const_iterator end() const { return finish; }
  reverse_iterator rbegin() { return reverse_iterator(end()); }
  const_reverse_iterator rbegin() const {
    return const_reverse_iterator(end());
  }
  reverse_iterator rend() { return reverse_iterator(begin()); }
  const_reverse_iterator rend() const {
    return const_reverse_iterator(begin());
  }
  size_type size() const { return size_type(end() - begin()); }
  size_type max_size() const { return size_type(-1) / sizeof(T); }
  size_type capacity() const { return size_type(end_of_storage - begin()); }
  bool empty() const { return begin() == end(); }
  reference operator[](size_type n) { return *(begin() + n); }
  const_reference operator[](size_type n) const { return *(begin() + n); }

  vector() : start(0), finish(0), end_of_storage(0) {}
  // 以下建構式，允許指定大小 n 和初值 value
  vector(size_type n, const T value) { fill_initialize(n, value); }
  vector(int n, const T value) { fill_initialize(n, value); }
  vector(long n, const T value) { fill_initialize(n, value); }
  explicit vector(size_type n) { fill_initialize(n, T()); }

  vector(const vector<T, Alloc> x) {
    start = allocate_and_copy(x.end() - x.begin(), x.begin(), x.end());
    finish = start + (x.end() - x.begin());
    end_of_storage = finish;
  }

  vector(const_iterator first, const_iterator last) {
    size_type n = 0;
    distance(first, last, n);
    start = allocate_and_copy(n, first, last);
    finish = start + n;
    end_of_storage = finish;
  }

  ~vector() {
    destroy(start, finish);  // 全域函式，建構/解構基本工具。
    deallocate();   // 先前定義好的成員函式
  }
  vector<T, Alloc> operator=(const vector<T, Alloc> x);
  void reserve(size_type n) {
    if (capacity() < n) {
      const size_type old_size = size();
      iterator tmp = allocate_and_copy(n, start, finish);
      destroy(start, finish);
      deallocate();
      start = tmp;
      finish = tmp + old_size;
      end_of_storage = start + n;
    }
  }

  // 取出第一個元素內容
  reference front() { return *begin(); }
  const_reference front() const { return *begin(); }
  // 取出最後一個元素內容
  reference back() { return *(end() - 1); }
  const_reference back() const { return *(end() - 1); }
  // 增加一個元素，做為最後元素
  void push_back(const T x) {
    if (finish != end_of_storage) {  // 還有備用空間
      construct(finish, x);         // 直接在備用空間中建構元素。
      ++finish;                             // 調整水位高度
    }
    else                                  // 已無備用空間
      insert_aux(end(), x);
  }

  void pop_back() {
    --finish;
    destroy(finish);    // 全域函式，建構/解構基本工具。
  }
  // 將迭代器 position 所指之元素移除
  iterator erase(iterator position) {
    if (position + 1 != end()) // 如果 p 不是指向最後一個元素
      // 將 p 之後的元素一一向前遞移
      copy(position + 1, finish, position); 

    --finish;  // 調整水位
    destroy(finish);    // 全域函式，建構/解構基本工具。
    return position;
  }
  iterator erase(iterator first, iterator last) {
    iterator i = copy(last, finish, first);
    destroy(i, finish); // 全域函式，建構/解構基本工具。
    finish = finish - (last - first);
    return first;
  }
  void resize(size_type new_size, const T x) {
    if (new_size < size())
      erase(begin() + new_size, end());
    else
      insert(end(), new_size - size(), x);
  }
  void resize(size_type new_size) { resize(new_size, T()); }
  // 清除全部元素。注意，並未釋放空間，以備可能未來還會新加入元素。
  void clear() { erase(begin(), end()); }

protected:
  iterator allocate_and_fill(size_type n, const T x) {
    iterator result = data_allocator::allocate(n); // 配置n個元素空間
      // 全域函式，記憶體低階工具，將result所指之未初始化空間設定初值為 x，n個
      // 定義於 <stl_uninitialized.h>。
      uninitialized_fill_n(result, n, x);
      return result;
  }
}
```

下面分几部分来讲述vector的定义。首先，模板参数一个是类型T作为vector的内含物类型，class Alloc = alloc则是使用默认的内存申请器。这一句typedef simple_alloc<value_type, Alloc> data_allocator;则是重定义相应的内存申请器类型。
然后，vector的迭代器类型其实就是原始的指针类型重定义了一下。以下这几句重定义，

``` stylus
  typedef T value_type;             // (1)
  typedef value_type* pointer;          // (2)
  typedef const value_type* const_pointer;
  typedef const value_type* const_iterator;
  typedef value_type reference;         // (3)
  typedef const value_type const_reference;
  typedef size_t size_type;
  typedef ptrdiff_t difference_type;    // (4)
```

在list，deque，map，set等支持迭代器操作的容器定义中都会出现。其中，vector中的定义是最简单的。每个容器都有值类型，指针类型，迭代器类型，引用类型，以及大小类型，difference_type。知道这些后，写代码时候，可以避免一些错误，或者说代码更规范，就能自然而然的使用容易内置类型，比如vector<int>::size_type而不是int来进行一些操作。原始指针支持随机存储，因此vector的迭代器就是功能最强的随机迭代器。
vector采用的数据结构很简单，就是一段线性内存。不过，有三个指针分别指向内存的头，已使用的尾部，尾。为了避免过多的重新分配内存，vector的容量永远比大小大，而且每次重新配置内存，大小翻倍。所以，vector的很多操作，比如，begin，end，front，back，size等的实现就很直观了，具体参看源码。下图很清楚的说明了这一情况。

![](https://c2.staticflickr.com/8/7355/26844795653_d590b6b031_o.png)

接着要讲的是vector如何管理空间的。先看下面三个函数，

``` stylus
vector(size_type n, const T value) { fill_initialize(n, value); }
void fill_initialize(size_type n, const T value) {
    start = allocate_and_fill(n, value);  // 配置空間並設初值
    finish = start + n;             // 調整水位
    end_of_storage = finish;            // 調整水位
  }
iterator allocate_and_fill(size_type n, const T x) {
    iterator result = data_allocator::allocate(n); // 配置n個元素空間
      // 全域函式，記憶體低階工具，將result所指之未初始化空間設定初值為 x，n個
      // 定義於 <stl_uninitialized.h>。
      uninitialized_fill_n(result, n, x);  
      return result;
  }
```

从源码中可以看出，最终都调用了函数uninitialized_fill_n初始化数据。这个stl的全局函数保证申请内存时候不会调用构造函数做额外的事情，也就是申请内存后，再用数据初始化。下面再看看其余几个操作。

``` stylus
 void push_back(const T x) {
    if (finish != end_of_storage) {  // 還有備用空間
      construct(finish, x);         // 直接在備用空間中建構元素。
      ++finish;                             // 調整水位高度
    }
    else                                  // 已無備用空間
      insert_aux(end(), x);         
  }

  void pop_back() {
    --finish;
    destroy(finish);    // 全域函式，建構/解構基本工具。
  }
  // 將迭代器 position 所指之元素移除
  iterator erase(iterator position) {
    if (position + 1 != end()) // 如果 p 不是指向最後一個元素
      // 將 p 之後的元素一一向前遞移
      copy(position + 1, finish, position); 

    --finish;  // 調整水位
    destroy(finish);    // 全域函式，建構/解構基本工具。
    return position;
  }
  iterator erase(iterator first, iterator last) {
    iterator i = copy(last, finish, first);
    destroy(i, finish); // 全域函式，建構/解構基本工具。
    finish = finish - (last - first);
    return first;
  }
```

push_back在还有空间的情况下，也只需要调用construct函数构造数据，否则就需要调用insert_aux申请新的内存，再添加数据了。pop_back相对就简单很多。erase函数也涉及到一些移动内存块的操作，思路基本是先移动内存，然后把末尾多出来的数据析构掉（调用destroy函数）。