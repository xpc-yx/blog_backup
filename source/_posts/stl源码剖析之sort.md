---
title: stl源码剖析之sort
tags:
  - stl源码剖析
id: 1562
categories:
  - C/C++
  - STL
date: 2015-04-22 15:58:48
---

排序的重要性就不用说了。stl里面的很多容器都是自序的，比如set和map，从begin到end就是一个顺序，毕竟最基本的概念就是一颗搜索树。另外，stack、queue、priority_queue的顺序也是内部实现决定的，不用多说了。list则不支持随机迭代器，内部也提供sort函数。所以，stl里面的sort泛型算法针对的是vector，deque，原生数组之类的数据。正常情况下，用的最多的也就是vector了。

插入排序和快速排序大家都知道是什么。但是，stl里面的sort并不仅仅是一个快速排序，而是一个复杂的组合体，有人把它叫做intro_sort。下面说一下introsort的几点要点。

1> 递归层次的限制，超过一定层次直接堆排序剩余数据。

2> 数据长度小于一定值，直接返回，不继续排序。

3>递归结束后，得到多段相互之间有序的数据（段内部无序），再进行一次优化的插入排序。

4>轴元素选取采用三点取中法，以避免分割不均。

sort的代码如下：

``` stylus
template <class RandomAccessIterator>
inline void sort(RandomAccessIterator first, RandomAccessIterator last) {
  if (first != last) {
    __introsort_loop(first, last, value_type(first), __lg(last - first) * 2);
    __final_insertion_sort(first, last);
  }
}
```

从代码中可以看到，sort内部调用的是__introsort_loop排序得到多段互相之间有序的小段，再进行插入排序。其中，__lg是计算递归层次，定义如下：

``` stylus
// 找出 2^k <= n 的最大值k。例，n=7，得k=2，n=20，得k=4，n=8，得k=3。
template <class Size>
inline Size __lg(Size n) {
  Size k;
  for (k = 0; n > 1; n >>= 1) ++k;
  return k;
}
```

因此，可以看出长度为64的数据，其递归层次不能超过16。如果超过，则进行堆排序。__introsort_loop的代码如下，是整个算法的关键。

``` stylus
template <class RandomAccessIterator, class T, class Size>
void __introsort_loop(RandomAccessIterator first,
                      RandomAccessIterator last, T*,
                      Size depth_limit) {
  // 以下，__stl_threshold 是個全域常數，稍早定義為 const int 16。
  while (last - first > __stl_threshold) {
    if (depth_limit == 0) {             // 至此，切割惡化
      partial_sort(first, last, last);  // 改用 heapsort
      return;
    }
    --depth_limit;
    // 以下是 median-of-three partition，選擇一個夠好的樞軸並決定切割點。
    // 切割點將落在迭代器 cut 身上。
    RandomAccessIterator cut = __unguarded_partition
      (first, last, T(__median(*first, *(first + (last - first)/2),
                               *(last - 1))));
    // 對右半段遞迴進行 sort.
    __introsort_loop(cut, last, value_type(first), depth_limit);
    last = cut;
    // 現在回到while 迴圈，準備對左半段遞迴進行 sort.
    // 這種寫法可讀性較差，效率並沒有比較好。
    // RW STL 採用一般教科書寫法（直觀地對左半段和右半段遞迴），較易閱讀。
  }
}
```

从代码里面可以看出，stl里面定义了个常数__stl_threshold决定要不要继续循环，如果数据的长度比该值小，那么就不继续递归排序了，除非是调用了堆排，长度小于__stl_threshold的段是没有经过排序的。当层次耗尽，depth_limit为0，直接调用partial_sort堆排序返回。另外的部分，就是采用三点取中法决定轴元素。还有这个代码写成了类似尾递归的形式，与教科书上不一致，较难阅读和理解。
__median的代码如下，容易理解。

``` stylus
template <class T>
inline const T __median(const T a, const T b, const T c) {
  if (a < b)
    if (b < c)      // a < b < c
      return b;
    else if (a < c) // a < b, b >= c, a < c
      return c;
    else
      return a;
  else if (a < c)   // c > a >= b
    return a;
  else if (b < c)       // a >= b, a >= c, b < c
    return c;
  else
    return b;
}
```

__unguarded_partition与教科书上的partion实现不同，实现简单而且高效。其代码如下：

``` stylus
template <class RandomAccessIterator, class T>
RandomAccessIterator __unguarded_partition(RandomAccessIterator first,
                                           RandomAccessIterator last,
                                           T pivot) {
  while (true) {

    while (*first < pivot) ++first; // first 找到 >= pivot 的元素，就停下來
    --last;                     // 調整
    while (pivot < *last) --last;   // last 找到 <= pivot 的元素，就停下來
    // 注意，以下first < last 判斷動作，只適用於random iterator
    if (!(first < last)) return first;  // 交錯，結束迴圈。
    iter_swap(first, last);             // 大小值交換
    ++first;                            // 調整
  }
}
```

现在回到sort函数中，最后的插入排序__final_insertion_sort。该函数再进行一次插入排序，由于小段之间都是有序的，因此该函数很快就能执行完。其代码如下：

``` stylus
template <class RandomAccessIterator>
void __final_insertion_sort(RandomAccessIterator first,
                            RandomAccessIterator last) {
  if (last - first > __stl_threshold) {
    __insertion_sort(first, first + __stl_threshold);
    __unguarded_insertion_sort(first + __stl_threshold, last);
  }
  else
    __insertion_sort(first, last);
}
```

该函数判断当前排序范围是不是小于等于于__stl_threshold（16），如果是，直接进行优化的插入排序__insertion_sort。否则，排序前面的16个元素，再调用__unguarded_insertion_sort排序剩下的元素。__unguarded_insertion_sort的相关定义代码如下：

``` stylus
template <class RandomAccessIterator>
inline void __unguarded_insertion_sort(RandomAccessIterator first,
                                RandomAccessIterator last) {
  __unguarded_insertion_sort_aux(first, last, value_type(first));
}

template <class RandomAccessIterator, class T>
void __unguarded_insertion_sort_aux(RandomAccessIterator first,
                                    RandomAccessIterator last, T*) {
  for (RandomAccessIterator i = first; i != last; ++i)
    __unguarded_linear_insert(i, T(*i));
}
```

__insertion_sort的相关代码如下：

``` stylus
template <class RandomAccessIterator>
void __insertion_sort(RandomAccessIterator first, RandomAccessIterator last) {
  if (first == last) return;
  for (RandomAccessIterator i = first + 1; i != last; ++i)  // 外迴圈
    __linear_insert(first, i, value_type(first));   // first,i形成一個子範圍
}

template <class RandomAccessIterator, class T>
inline void __linear_insert(RandomAccessIterator first,
                                  RandomAccessIterator last, T*) {
  T value = *last;      // 記錄尾元素
  if (value < *first) { // 尾比頭還小（那就別一個個比較了，一次做完…）
    copy_backward(first, last, last + 1); // 將整個範圍向右遞移一個位置
    *first = value;     // 令頭元素等於原先的尾元素值
  }
  else
    __unguarded_linear_insert(last, value);
}

template <class RandomAccessIterator, class T>
void __unguarded_linear_insert(RandomAccessIterator last, T value) {
  RandomAccessIterator next = last;
  --next;
  // insertion sort 的內迴圈
  // 注意，一旦不出現逆轉對（inversion），迴圈就可以結束了。
  while (value < *next) {   // 逆轉對（inversion）存在
    *last = *next;      // 轉正
    last = next;            // 調整迭代器
    --next;             // 前進一個位置
  }
  *last = value;
}
```

从上面的代码可以看出，关于插入排序的代码比sort其它部分的代码都要多，可见stl对插入排序进行了特别的优化，以使得其在处理接近有序数据的时候，速度非常快。从代码中可以看到，这些函数最终都调用了__unguarded_linear_insert函数，该函数优化了插入排序的实现。该函数的思路是从后往前找是否存在比value小的元素，如果还存在，就往后移动数据一个位置。最终，得到的是value需要插入的位置。根据stl源码剖析作者的说法，该函数不需要判断越界，因此提高了速度。在大数据量的排序中，优势很大。毕竟，该函数会被sort频繁调用。

关于插入排序代码实现的具体思路，参考stl源码剖析一书。本文的代码也取自该书提供的源码。