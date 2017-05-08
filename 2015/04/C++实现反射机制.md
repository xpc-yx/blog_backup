---
title: C++实现反射机制
tags:
  - C++
  - 动态创建
  - 反射机制
id: 1547
categories:
  - C/C++
  - 编程语言
date: 2015-04-11 11:22:21
---

这是一个很老的话题了。所谓的反射机制，其实就是MFC里面的对象动态创建。比如说，给一个字符串代表类名，比如"CMesh"，根据这个字符串创建出一个CMesh对象。有不同的实现方法，在MFC里面是用一张巨大的链表网络把所有的类的信息链接起来，里面存储了类名和构造函数，动态创建的时候按照一定的顺序去里面搜索创建函数（构造函数）。

与其用一张链表网，不如用一个字典保存起来，键是类名字符串，值是对应的构造函数。看起来很简单的样子，确实也很简单额。只是实现起来有些trick，比如字典一般是类的静态成员等。。。假设只有无参数的构造函数，首先定义上面所述的内容，类的字典。

``` stylus
//头文件
    typedef void* (*CreateFuntion)(void);

    class CClassFactory
    {
    public:
        CClassFactory() {}
        ~CClassFactory() {}

    public:
        static void* GetClassByName(std::string name)
        {
            std::map<std::string, CreateFuntion>::const_iterator find;
            find = m_clsMap.find(name);  

            if(find==m_clsMap.end())
            {  

                return NULL;
            }
            else
            {
                return find->second();
            }  

        }  

        static void RegistClass(std::string name, CreateFuntion method)
        {
            m_clsMap.insert(std::make_pair(name,method));
        }  

    private:
        static std::map<std::string,CreateFuntion> m_clsMap;
    };
//源文件
std::map<std::string, CreateFuntion> CClassFactory::m_clsMap;
```

到目前为止，使用CClassFactory即可完成工作了。代码实在过于简单，不用解释了。下面看看一些带trick的东西。

``` stylus
    class RegistyClass
    {  

    public:
        RegistyClass(std::string name, CreateFuntion method)
        {
            CClassFactory::RegistClass(name, method);
        }
    };  

    template<class T, const char* name>
    class Register
    {
    public:
        Register()
        {
            const RegistyClass tmp = rc;//这一句不能删除，如果不使用rc，那么rc这个模板成员编译器不会生成代码
        }  

        static void* CreateInstance()
        {
            return new T;
        }  

    public:
        static const RegistyClass rc;
    };  

    template<class T, const char* name>
    const RegistyClass Register<T, name>::rc(name, Register<T, name>::CreateInstance);

#define REGISTRY_CLASS(class_name) \
extern char const array_##class_name[] = #class_name;\
Register<class_name, array_##class_name> register_class_name
```

RegistyClass不用说了，模板类Register是关键。模板T代表要注册的类类型，常量字符串模板name代表类名。其中的static成员rc用于注册当前类。注意CreateInstance的实现，说明只能调用无参数构造函数。至于Register构造函数里面的那句话也是不能省略的。

最麻烦的是下面的那个REGISTRY_CLASS宏，其余代码都来自网络，这个宏确是我修改实现的。class_name代表类，比如CMesh，注意不是类名。这里有几个关键点，一个是extern。在vs2010中，不加extern修饰无法编译通过，具体原因估计是编译器支持不够吧。另一个是`#class_name`，是把CMesh转换为"CMesh"。最最关键的是`array_##class_name`，是生成array_CMesh的变量名。为什么要这么做了，这样注册不同的类就是不同的变量名，避免了变量重定义，否则会链接失败。使用方法是在要注册的类源文件中，包含ClassFactory.h头文件，再添加宏REGISTRY_CLASS(CMesh);即可。

网上提供的代码，还定义了声明类的宏，表示继承Register模板类自动支持反射机制。相关代码经过修改如下所示，这个就没有去具体使用了，因为修改类定义比较麻烦，添加一句宏到现在代码中却是很方便的事情。这个反射机制已经用到我现在的项目中了，实现了一个从配置文件读取信息，选择创建不同的界面的功能。

``` stylus
#define DEFINE_CLASS(class_name)\
extern char char array_##class_name[]=#class_name;\
class class_name:public Register<class_name, NameArray>  

#define DEFINE_CLASS_EX(class_name, father_class) \
extern char char array_##class_name[] = #class_name;\
class class_name: public Register<class_name, NameArray>, public father_class
```