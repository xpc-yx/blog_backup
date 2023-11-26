---
title: C++类对象的内存布局
tags:
- C++
- 内存布局
category: 
- 编程语言
- C++
date: 2018-8-12 19:15:51
renderNumberedHeading: false
grammar_cjkRuby: true
---

# 一、内存对齐
C\+\+的对象都会进行内存对齐，所谓内存对齐，指的是对象的地址和大小都会对齐到n的倍数上。比如按照4对齐，那么对象的地址会是4的倍数，对象的大小也是4的倍数。究其原因是，机器在内存对齐的地址上访问数据更快，可以一起取出数据；如果数据存在在不对齐的地址上，需要换成2次对齐地址上的取数据，再组合出原始数据；而且，部分机器根本没有取非对齐的数据。

## 1.1 默认对齐

``` cpp?linenums
class OrdinaryClassWithMemoryPack
{
public:
    int intA;

    short shortB;

    float floatC;    
};

std::cout << "sizeof(int):" << sizeof(int) << std::endl;
std::cout << "sizeof(short):" << sizeof(short) << std::endl;
std::cout << "sizeof(float):" << sizeof(float) << std::endl;
 std::cout << "sizeof(OrdinaryClassWithMemoryPack):" << sizeof(OrdinaryClassWithMemoryPack) << std::endl;
 std::cout << "address of omp:" << &omp << std::endl << std::endl;
```
### vs2019 x86的结果
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/C++对象默认内存对齐x86.png)
### vs2019 x64的结果
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/C++对象默认内存对齐x64.png)

可以看到，默认都是按照4字节对齐，int和float都是4个字节，short是2个字节，不过强制按照4字节对齐了。对象的地址都是4的倍数，不过64位程序的地址是64位了。

## 1.2 Pack(n)
假如我们用pack指令强制按照2字节对齐，那么输出结果如何了？
``` cpp?linenums
#pragma pack(push)
#pragma pack(2)
class OrdinaryClassWithMemoryPack
{
public:
    int intA;

    float floatB;

    short shortC;
};
#pragma pack(pop)
```
### vs2019 x86的结果
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/C++对象默认内存对齐x86Pack2.png)
### vs2019 x64的结果
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/C++对象默认内存对齐x64Pack2.png)
从输出结果可以看出，对象还是位于4对齐的地址上，只是对象本身的大小变成10了。short只占2个字节，那么接下来的float并没有强制在4字节的地址对齐，而是根据pack指令对齐在2字节的地址上了。

## 1.3 实验环境
未避免文章过于啰嗦，接下来的例子只说明vs2019 x86的输出结果。

# 二、普通类的对象
## 2.1 基类的对象
接下来的讨论为避免内存对齐的干扰，忽略内存对齐。因此，类的成员变量只有一个int。定义基类如下，

``` cpp?linenums
class OrdinaryClassA
{
public:
    int intA;
};
```

## 2.2 单继承子类的对象
定义子类如下，
``` cpp?linenums
class OrdinaryClassAFirstSon : public OrdinaryClassA
{
public:
    int intAFirstSon;
};
```

## 2.3 多继承子类的对象
定义多继承的子类如下,

``` cpp?linenums
class OrdinaryClassASecondSon : public OrdinaryClassA
{
public:
    int intASecondSon;
};

class OrdinaryMultipleInheritClassE : public OrdinaryClassAFirstSon, public OrdinaryClassASecondSon
{
public:
    int intE;
};
std::cout << "sizeof(OrdinaryClassA):" << sizeof(OrdinaryClassA) << std::endl;
std::cout << "sizeof(OrdinaryClassAFirstSon):" << sizeof(OrdinaryClassAFirstSon) << std::endl;
std::cout << "sizeof(OrdinaryMultipleInheritClassE):" << sizeof(OrdinaryMultipleInheritClassE) << std::endl;
```

输出结果：
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/C++普通对象多继承x86.png)
根据输出结果，可以看出：基类是4个字节；子类拥有基类的对象，加上自己的成员，一起是8个字节；多重继承的子类，拥有2个基类对象，加上自己的成员，总共是8+8+4=20个字节。
OrdinaryMultipleInheritClassE的两个基类都继承同一个类OrdinaryClassA，因此E的对象中会有2份A的实例。一般的编程范式中，都要求避免多继承，改用多接口继承。C\+\+在针对这种情况，也有一种虚拟继承的方式来避免数据冗余。


# 三、带虚函数的类对象
## 3.1 带虚函数的基类的对象
``` cpp?linenums
class VirtualFunClassA
{
public:
    int intA;

public:
    virtual int VirtualFunA()
    {
        return 0;
    }
};

```

## 3.1 带虚函数的单继承子类的对象

``` cpp?linenums
class VirtualFunClassAFirstSon : public VirtualFunClassA
{
public:
    int intAFirstSon;

public:
    virtual int VirtualFunA() override
    {
        return 0;
    }

    virtual int VirtualFunAFirstSon()
    {
        return 0;
    }
};

VirtualFunClassA va;
VirtualFunClassAFirstSon vason;

std::cout << "sizeof(VirtualFunClassA):" << sizeof(VirtualFunClassA) << std::endl;
std::cout << "sizeof(VirtualFunClassAFirstSon):" << sizeof(VirtualFunClassAFirstSon) << std::endl << std::endl;
```

用vs2019调试，自动窗口中显示的va和vason的内存布局如下：
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/C++虚函数类对象内存布局x86.png)

输出结果：
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/C++虚函数类对象大小x86.png)

可以看到，类对象内多了一个vfptr（虚函数指针），其中子类的虚函数指针是放在父对象内的。


## 3.2 带虚函数的多继承子类的对象
现在来考虑多继承的情况，假如多个基类都有虚函数，那么内存布局如何了？

``` cpp?linenums
class VirtualFunClassB
{
public:
    int intB;

public:
    virtual int VirtualFunB()
    {
        return 0;
    }
};

class VirtualFunMultipleInheritClassC : public VirtualFunClassA, public VirtualFunClassB
{
public:
    int intC;

public:
    virtual int VirtualFunA() override
    {
        return 0;
    }

    virtual int VirtualFunB() override
    {
        return 0;
    }

    virtual int VirtualFunC()
    {
        return 0;
    }
};

VirtualFunMultipleInheritClassC vmc;

std::cout << "sizeof(VirtualFunClassA):" << sizeof(VirtualFunClassA) << std::endl;
std::cout << "sizeof(VirtualFunClassB):" << sizeof(VirtualFunClassB) << std::endl;
std::cout << "sizeof(VirtualFunMultipleInheritClassC):" << sizeof(VirtualFunMultipleInheritClassC) << std::endl << std::endl;
```
用vs2019调试，自动窗口中显示的vmc的内存布局如下：
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/C++虚函数多继承类对象内存布局x86.png)

输出结果：
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/C++虚函数多继承类对象内存大小x86.png)

可以得出结论：vmc中有2个基类的对象，大小分别是8，自身有一个大小为4的int，因此总共是20的大小；多继承的对象内会有多个虚函数指针，一个指针对应一个带虚函数的基类；子类如果也带非继承而来的虚函数，那么这个虚函数也会放在某个基类的虚函数表内。
因此，多重继承的子类对象，会有多个虚函数指针，对应多个虚函数表，自身虚函数会被合并到某个基类的虚函数表中，不会再多一个虚函数指针和虚函数表。对于多重继承子类的多个虚函数表，可能是分开存储，也可能是连续存储为一个表，只是虚函数指针有一定的偏移。

# 四、虚拟继承的类对象
下面来讨厌最变态的部分，虚拟继承的对象。
## 4.1 虚多继承子类的对象

``` cpp?linenums
class OrdinaryClassAVirtualFirstSon : virtual public OrdinaryClassA
{
public:
    int intAFirstSon;
};

class OrdinaryClassAVirtualSecondSon : virtual public OrdinaryClassA
{
public:
    int intASecondSon;
};

class OrdinayVirtualMultipleInheritClassF : public OrdinaryClassAVirtualFirstSon, public OrdinaryClassAVirtualSecondSon
{
public:
    int intF;
};

OrdinaryClassAVirtualFirstSon oavson;
OrdinayVirtualMultipleInheritClassF ovmf;

std::cout << "sizeof(OrdinaryClassAVirtualFirstSon):" << sizeof(OrdinaryClassAVirtualFirstSon) << std::endl;
std::cout << "sizeof(OrdinaryClassAVirtualSecondSon):" << sizeof(OrdinaryClassAVirtualSecondSon) << std::endl;
std::cout << "sizeof(OrdinayVirtualMultipleInheritClassF):" << sizeof(OrdinayVirtualMultipleInheritClassF) << std::endl << std::endl;

```

用vs2019调试，自动窗口中显示的ovmf的内存布局如下：
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/C++虚多继承类对象内存布局x86.png)
输出结果：
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/C++虚多继承类对象内存大小x86.png)
可以看到2个基类的大小都是12，子类的大小是24。如果是普通继承的话，基类的大小是8，子类的大小是20，这个可以参考2.3。那么，虚继承的对象内肯定多了什么？具体是什么了。

### 启用类内存布局分析
由于自动窗口无法显示虚拟继承的内存布局了，那么我们只能用其它方式来查看。
如下图，我们通过Project的属性窗口，找到C++ ->命令行，添加新的选项 /d1 reportAllClassLayout。
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/reportAllClassLayout.png)

### 虚继承的基类内存布局
然后清理工程重新生成，在输出窗口会输出所有类的局部情况，然后搜索OrdinaryClassAVirtualFirstSon，如下图所示，
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/虚继承的基类内存布局.png)
可以看到，对象内有三个成员，按照顺序分别是vbptr（虚表指针）、数据成员intAFirstSon、基类的数据成员intA。相比普通的继承，多了虚表指针。大小总和是4+4+4=12。

### 虚继承的多重继承子类内存布局
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/虚多重继承内存布局.png)
可以看到，对象的成员按照顺序分别是基类1对象、基类2对象、数据成员intF、虚继承的基类数据成员intA。
大小总和是8+8+4+4=24。基类1和基类2里面都是带1个虚表指针和1个数据成员。
相比普通的继承，多了2个虚表指针，但是减少了重复基类数据，总的大小变化是20+8-4=24。如果，重复的基类OrdinaryClassA有更多的数据成员，那么虚拟继承这种机制就更划算了。

## 4.2 带虚函数的虚多继承子类的对象

``` cpp?linenums
class VirtualFunClassASecondSon : virtual public VirtualFunClassA
{
public:
    int intASecondSon;

public:
    virtual int VirtualFunA() override
    {
        return 0;
    }

    virtual int VirtualFunASecondSon()
    {
        return 0;
    }
};

class VirtualFunClassAThirdSon : virtual public VirtualFunClassA
{
public:
    int AThirdSon;

public:
    virtual int VirtualFunA() override
    {
        return 0;
    }

    virtual int VirtualFunAThirdSon()
    {
        return 0;
    }
};

class VirtualFunVirtualInheritClassG : public VirtualFunClassASecondSon, public VirtualFunClassAThirdSon
{
public:
    int intG;

public:
    virtual int VirtualFunA() override
    {
        return 0;
    }

    virtual int VirtualFunASecondSon() override
    {
        return 0;
    }

    virtual int VirtualFunAThirdSon() override
    {
        return 0;
    }

    virtual int VirtualFunE()
    {
        return 0;
    }
};

std::cout << "sizeof(VirtualFunClassASecondSon):" << sizeof(VirtualFunClassASecondSon) << std::endl;
std::cout << "sizeof(VirtualFunClassAThirdSon):" << sizeof(VirtualFunClassAThirdSon) << std::endl;
std::cout << "sizeof(VirtualFunVirtualInheritClassG):" << sizeof(VirtualFunVirtualInheritClassG) << std::endl << std::endl;
	
```
输出结果：
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/带虚函数的虚多继承对象大小.png)
发现基类的大小变成了20，多了8个字节。子类的从24变成了36，多了12个字节。猜测是多了虚函数指针。

### 带虚函数的虚继承的基类内存布局
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/带虚函数的虚继承的基类内存布局.png)
可以看到，内存布局是虚函数指针、虚表指针、数据成员、基类对象（基类的虚函数指针、基类数据成员）。相比不带虚函数的虚拟继承，是多了2个虚函数指针。相比，普通的继承，是多了1个虚表指针和1个虚函数指针。所以，最奇怪的地方是没有像普通继承那样将2个虚函数指针合并成一个。

如果注释掉当前类的虚函数VirtualFunASecondSon，得到的内存布局如下：
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/带虚函数的虚继承的基类内存布局1.png)
区别是少了当前类的虚函数指针，基类对象内的虚函数指针保留。

### 带虚函数的虚继承的多重继承子类内存布局
![](https://raw.githubusercontent.com/xpc-yx/markdown_img/master/小书匠/带虚函数的虚继承的多重继承子类内存布局.png)

这应该是已知的最复杂的类对象布局情况了。按照顺序是基类1、基类2、数据成员、虚拟基类。基类1和基类2内部都是虚函数指针、虚表指针、数据成员，大小都是12，那么总共是24。数据成员大小是4。虚拟基类的内部是虚函数指针、数据成员，大小是8。因此，总共的大小是12+12+4+8=36。
相比不带虚函数的虚拟继承，多了3个虚函数指针，总计12个字节。相比普通的继承，多了2个虚表指针和1个虚函数指针，但是减少了虚拟基类数据的重复，那么总大小是28+12-4=36。

### 虚拟继承的最终结论
1、虚拟继承的对象内会多一个虚表指针。
2、带虚函数的虚继承，子类和基类的虚函数表不会合并，因此会多一个虚函数指针。
3、多重继承的基类，如果虚继承了共同的基类，那么其共同基类对象只会存在一份，包括数据成员和虚函数指针。

### 疑问：带虚函数的虚继承为何不合并子类和基类的虚函数指针？
猜测可能跟vs2019对应的vc\+\+编译器实现有关。

## 4.3 虚表指针的用途
我们知道，虚函数指针指向的是虚函数表，虚函数表内存储的是虚函数的地址。对于采用指针或者引用来动态调用虚函数的情况，会在运行时才能确定真正的虚函数地址，这个就叫做延迟绑定。为了灵活性，失去了部分性能。
那么，虚表指针是用来做什么的？可以肯定的是用于找到共同的基类对象的。猜测虚表指针指向一张table，该table内部存储共同的基类数据在类对象内的偏移。

## 4.4 虚拟继承实现的编译器差异
根据深入探索C\+\+对象模型的说明，虚拟继承在不同的编译器下有不同的实现，而且C\+\+标准并未规定如何实现。因此，g\+\+的内存布局跟vc\+\+的内存布局可能会有显著差别。