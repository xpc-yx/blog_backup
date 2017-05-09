---
title: extern "C"的理解
tags:
  - extern "C"
id: 1301
categories:
  - C/C++
date: 2014-08-15 20:55:40
---

我们经常会看到头文件里面会有下列的结构。
``` stylus
#ifdef __cplusplus
extern "C" {
#endif
    /*...*/
#ifdef __cplusplus
}
#endif
```
而且我们也大都知道这是为了和C语言兼容。但是更具体的事情了？
实际上，这段代码是为了保证用C语言调用C++函数或者用C++调用C语言实现的函数，都能够顺利进行。不仅仅是单向的左右。如果没有加#ifdef __cplusplus判断就是单向的吧。
大家都知道C++支持函数重载，而C语言是不支持的。所以，类似函数int add(int,int)很可能在链接的时候，符号是_add_int_int。而在C语言里面，还是_add。既然符号不一样，那就会找不到吧。这就发生在用C语言去调用C++实现的函数的时候。如果在C++头文件里面加上extern "C"声明，那么就会按照C语言的方式生成函数，自然能和C语言兼容了。
如下列代码，就能顺利运行。
``` stylus
//add.h
#ifndef ADD_H
#define ADD_H

//int add(int x, int y);

#ifdef __cplusplus
extern "C" {
#endif
    int add(int x, int y);
#ifdef __cplusplus
}
#endif

#endif

//add.cpp
#include "add.h"

int add(int x, int y)
{
    return x + y;
}

//main.c
#include <stdio.h>
#include "add.h"

int main()
{
    add(1, 2);

    return 0;
}
```
如果把头文件定义改成，
``` stylus
//add.h
#ifndef ADD_H
#define ADD_H

int add(int x, int y);

/*#ifdef __cplusplus
extern "C" {
#endif
    int add(int x, int y);
#ifdef __cplusplus
}
#endif*/

#endif
```
main.c就无法链接到函数_add上面。提示：main.obj : error LNK2019: 无法解析的外部符号 _add，该符号在函数 _main 中被引用。
现在再反过来，用c语言实现add，c++实现main。代码如下，
``` stylus
//add.h
#ifndef ADD_H
#define ADD_H

int add(int x, int y);

/*#ifdef __cplusplus
extern "C" {
#endif
    int add(int x, int y);
#ifdef __cplusplus
}
#endif*/

#endif

//add.c
#include "add.h"

int add(int x, int y)
{
    return x + y;
}

//main.cpp
#include <stdio.h>
#include "add.h"

int main()
{
    add(1, 2);

    return 0;
}
```
结果还是无法链接，提示： error LNK2019: 无法解析的外部符号 "int __cdecl add(int,int)" (?add@@YAHHH@Z)，该符号在函数 _main 中被引用。这是因为main.cpp用C++的方式去查找函数符号，_add_int_int，而add.c里面生成的符号是_add。因此无法链接上去。那么，能不能直接加上extern "C"就行了？
由于C语言里面不支持extern "C"，那么作为C语言的头文件就不能这么加，应该加上#ifdef __cplusplus的判断，再将所有的函数定义前加上extern "C"，就能保证该头文件同时兼容C语言和C++了。