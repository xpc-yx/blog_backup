---
title: C++的设计优化
tags:
id: 567
categories:
  - 编程语言 
  - C++
date: 2012-12-17 11:12:34
---

设计优化是一种全局的优化，是比代码优化更难判断的东西。本文只以提高c++性能的编程技术一书的说法再自己的理解为例子。性能和灵活性本来就是相互冲突的东西。将两者结合得很好的例子一般能想到STL，但是STL在特定的场合肯定比不上专用代码的性能。比如，用stl里面的accmulate累加int能够与自己的实现效果一样，但是累加string的话就会比手动实现效果差很多。所以作者提出了个这样的观点，软件库是通用的，但是软件不是，所以没必要让软件太通用，视野应该窄一点。

**例子一，还是利用缓存机制。**
比如，一个web服务器经常要计算时间戳，而且是在1s内要计算不少次。由于时间戳没必要以ms进行区分，那么可以只计算一次时间戳，然后将时间戳保存起来，或者作为参数传递给后面的调用。

**例子二，扩展数据类型。**
比如，使用字符串的时候假如经常要计算字符串长度，那么可以定义一个结构体，内部有个成员用于保存长度。这样在很多需要长度的场合就可以避免重复计算长度了。

**例子三，避免公共代码陷阱。**
比如，在一个公共函数中，需要处理ipv4和ipv6两种情况，那么你就必须在函数中进行判断当前处理的是ipv4还是ipv6。但是，这种判断并不是必须的，如果你不使用公共函数的话。最重要的问题是，如果有很多这样的公共函数，那么就会出现成千上万这样其实没必要的判断，无疑对于性能是一个重大的损失。

**例子四，使用高效的数据结构和算法。**
当然这点需要扎实的算法知识。

**例子五，使用缓式计算。**
同上一篇文章中描述的一样，将计算延缓到真正需要的时候。比如，调用getpeername获得对方ip地址和调用getsockname获得本地服务器ip地址都是些昂贵的调用，那么我们还是把这些调用延迟到真正需要的时候吧。而且对方ip地址可以在accept函数调用的时候就得到了，这个时候保存起来就可以了。
缓式计算类似于下面的类定义，
``` stylus
class X
{
    X() {veryExpensive = NULL;}
    ~X() { if (veryExpensive) delete veryExpensive; }
    Z* get_veryExpensive()
    {
        if (NULL == veryExpensive)
        {
            set_veryExpensive();
        }
        return veryExpensive;
    }

    void set_veryExpensive
    {
        veryExpensive = new Z;//do some expensive thing
        //...
    }
private:
    Z* veryExpensive;
};
```

**例子六，避免无用计算。**
比如，很多时候memset并不是必须的，那么就应该避免，尤其memset大块内存的时候。类中对成员的默认构造函数调用有的时候也是浪费，应该使用成员初始化列表。这种情况，应该还有很多其它的例子。

**例子七，删除已经失效的代码。**
已经失效的代码是只不会再使用的代码，你应该将其删除掉，否则那些代码还是会造成性能损失。

总之，设计上面的优化是个太难的题目了，我觉得这本书上面很多例子都有点和代码上的优化重复了。不过，性能和灵活性确实是相反的方向，有的时候牺牲灵活性是非常必须的。</pre>