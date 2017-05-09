---
title: 为什么需要将继承层次中类的析构函数定义成virtual的？
tags:
  - 析构函数
  - 虚函数
id: 375
categories:
  - C/C++
date: 2012-11-10 15:44:59
---

如标题所示，如果该类没有父类也没有任何子类，把析构函数还定义成虚的，确实没多大必要吧。对象的构建和析构完全是一个入栈和出栈的过程，也就是说肯定会从父类构造到子类，也肯定会从子类析构到父类，这些都是毋容置疑的。

那么把析构函数定义成virtual有个什么意义了。确实没有多大意义，至少对于一个非delete造成的析构。无论是析构一个堆栈对象还是全局对象，编译器肯定能在编译时就做出决策了。但是，假如有人一时兴起，new了一个子类对象并且将地址存储在基类指针中。那么，你该怎么删除这个对象了，只能delete父类指针了。

问题就出在这里了。**你既然delete父类指针，假如是在编译层次决策的话，编译器只能帮你调用父类的析构函数了。**但是，事实上你是一个子类对象，那么子类的析构函数没有调用，假如你在子类的析构函数做了些什么释放，结果就是那个释放永远不会执行，这样就造成内存泄漏或者资源重复申请之类的。

其实，上面的这种写法就是利用多态的性质，既然要利用多态，肯定得把析构函数定义成virtual的，那么调用哪个析构函数的决策就能到运行时候再决定。如果基类的析构函数定义成virtual的话，其所有子类的析构函数当然也是virtual的，那么我们删除基类指针的时候，就能通过多态机制决定该调用子类的析构函数，也就是从子类的析构函数开始往基类的析构函数调用释放整个对象。这样就不会造成任何资源泄漏了。

以下的代码展示了这样的一种情况，注意Class CA作为基类，就需要把析构函数定义成virtual的。

``` stylus
#include <stdio.h>

class CA
{
    public:
        CA(int nS = 100): nSize(nS)
        {
            nA = new int[nSize];
            printf("构造CA\n");
        }
        virtual ~CA()
        {
            delete [] nA;
            printf("析构CA\n");
        }

    private:
        int* nA;
        int nSize;
};

class CB : public CA
{
    public:
        CB(int nS = 100): nSize(nS)
        {
            nB = new int[nSize];
            printf("构造CB\n");
        }
        ~CB()
        {
            delete [] nB;
            printf("析构CB\n");
        }

    private:
        int* nB;
        int nSize;
};

int main()
{
    CA* pCA = new CB();
    delete pCA;
}
```

效果如图:

![](https://c2.staticflickr.com/8/7152/27396027096_47abe363cc_o.png)，

如果删掉CA析构函数前面的virtual，效果如图，

![](https://c2.staticflickr.com/8/7672/27396028106_085b740b99_o.png)

你也可以实验在主函数里面定义些栈变量的CA和CB的对象，无论构造函数是否是virtual的，都能够正确的析构。