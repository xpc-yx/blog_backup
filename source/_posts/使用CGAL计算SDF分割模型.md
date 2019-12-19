---
title: 使用CGAL计算SDF分割模型
tags:
  - CGAL
id: 1497
categories:
  - 图形学
  - CGAL
date: 2015-01-22 20:28:12
---

最新版的cgal4.5，提供了个[Triangulated Surface Mesh Segmentation](http://doc.cgal.org/latest/Surface_mesh_segmentation/index.html "Triangulated Surface Mesh Segmentation")包，利用该部分代码可以计算三维模型每个面或者顶点的sdf（_Shape Diameter Function）_属性。sdf的具体定义可以参考论文：L. Shapira, A. Shamir, and D. Cohen-Or. Consistent mesh partitioning and skeletonisation using the shape diameter function. _The Visual Computer_, 24(4):249–259, 2008.

那么sdf可以做什么了？sdf最终能表示三维模型上面的一个标量场，该标量场代表的是模型厚度的分布。因此，利用该标量场可以对模型进行分割，不管是自动化的还是交互的都可以。如何计算sdf了？可以利用定义自己去实现算法，或者利用库，比如cgal。

关于如何使用sdf标量场进行模型分割？cgal的文档说的很清楚，先用k个gmm进行软聚类（每个cluster是k-means初始化的），再利用软聚类的结果进行硬聚类，这一步实际上利用graph-cut求能量最小化。更清楚的解释，参考CGAL的相关文档。刘利刚老师用sdf进行交互式分割的文章，也是利用gmm和graph-cut作为工具实现的，原理和cgal的实现思路基本一致。

下面将一下，我使用该代码碰到的问题。计算sdf的函数是CGAL::sdf_values，这是一个复杂的模板函数，该函数的第一个参数是一个模板类Polyhedron的引用。由于cgal使用了非常复杂的模板语法，所以经常会碰到一些恶心的语法问题，编译无法通过。这一次也是。由于默认情况下，使用cgal都会继承CGAL::Polyhedron_3<kernel, items>以实现自定义的多面体类。所以，使用这个函数的时候就会出现模板参数不匹配的情况。怎么解决了。首先，没必要去修改自己的多面体类，也不可能去修改cgal库，再重新构造个cgal默认的Polyhedron_3对象也很浪费。

其实，这里可以考虑到转型。类型转换有两种考虑，转值和转指针。如果将自定义多面体类转换为默认的多面体类，肯定会生成个具大的临时对象，多浪费啊。所以了，可以先取地址转换为基类指针再解引用就获得了cgal默认的Polyhedron_3对象了。我的代码如下：std::pair<double, double> min_max_sdf = CGAL::sdf_values(*(Polyhedron*)m_pModel, m_sdf_property_map);

至于其它部分的使用，参考cgal手册即可，非常简单方便。下面再贴几张图，展示下sdf标量场的分布，以及利用sdf的分割结果。

sdf标量场，白色的是等值线。

![](https://c2.staticflickr.com/8/7719/27451907645_8f5cee7a2e_o.png)

sdf分割模型结果：

![](https://c2.staticflickr.com/8/7604/27417732786_830e67189b_o.png)



至于分割边界不是很整齐，这只是跟模型密度有关系，模型越密，能够得到越平滑的边界，也有相关的算法优化边界。