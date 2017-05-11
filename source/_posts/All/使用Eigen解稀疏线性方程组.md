---
title: 使用Eigen解稀疏线性方程组
tags:
  - eigen
  - QR分解
  - 稀疏矩阵
  - 线性方程组
id: 1560
categories:
  - 编程语言 
  - - C/C++
date: 2015-04-22 14:41:39
---

这里只讲解稀疏矩阵表示的线性系统。最新版本的eigen已经支持稀疏矩阵，以及相关操作了。eigen相对其它库的最大优势，默认情况下，只需要eigen的头文件即可，不需要其它依赖库，除非用对应的加速解法（需要更快的库支持）。所以，eigen就是个牛逼的模板矩阵库。虽然在使用的时候需要套用不少模板参数，有点麻烦。

eigen里面定义稀疏矩阵，然后加入数据的一种方式如下：

``` stylus
Eigen::SparseMatrix<float> smA(m_nRow, m_nColumn);

std::sort(m_pSI, m_pSI + m_nNum);//排序，列主序
for (int i = 0; i < m_nNum; ++i)// 初始化非零元素
{
    smA.insert(m_pSI[i].r, m_pSI[i].c) = m_pSI[i].v;
}
smA.makeCompressed();
```

代码非常简单，makeCompressed是可选的，具体原因不怎么清楚，参考官方文档。
知道定义了稀疏矩阵之后，就可以解稀疏线性系统Ax=b了。A作为稀疏系数矩阵输入。eigen里面有多种解线性系统的方法，官方文档有说明。其中，QR分解适合于任何大小的稀疏矩阵A，并且被推荐用来解最小二乘法问题，适用范围很广。下面的是QR分解求线性系统的代码。

``` stylus
// 一个QR分解的实例
Eigen::SparseQR<Eigen::SparseMatrix<float>, Eigen::COLAMDOrdering<int>> linearSolver;
// 计算分解
linearSolver.compute(smA);

Eigen::VectorXf vecB(m_nRow);
for (int i = 0; i < m_nRow; ++i)
{
    vecB[i] = pColumnB[i];
}
Eigen::VectorXf vecX = linearSolver.solve(vecB);// 求一个A*x = b

for (int i = 0; i < m_nColumn; ++i)
{
    pX[i] = vecX[i];
}
```

代码的思路是先定义一个QR分解的线性solver，然后调用compute分解。再传入b，再调用solve函数求解，再传出数据。逻辑很简单。值得注意的是，这里用了float来计算，是因为qr分解比较耗内存，如果矩阵过大或者非0值过多就会计算不过来。因此，用float来减少一半内存，不过精度比double下降了，具体看实际需要选择float还是double。至于QR分解的原理，请参考维基百科等。
如果使用迭代的办法解线性方程组，该怎么用eigen实现了。eigen里面也提供了迭代的solver，不过要求稀疏矩阵A是方阵。那么，把A转换为方阵即可。Ax=b的两边同时乘以A的转置，得到A'Ax=A'b(A'是A的转置)，再用迭代solver求解。如果得到的答案误差较大，可以在两边乘以个（-1）。如下代码所示。

``` stylus
//把A*X = b，转换为A'*A*X = A'*b，其中A'是A的转置，貌似计算结果不是很对，故没有使用该函数
    int CSparseMatrix::SolveLinearSystemByEigenIterative(double* pColumnB, double* pX)
    {
        Eigen::SparseMatrix<float> smA(m_nRow, m_nColumn);

        std::sort(m_pSI, m_pSI + m_nNum);//排序，列主序
        for (int i = 0; i < m_nNum; ++i)//初始化非零元素
        {
            smA.insert(m_pSI[i].r, m_pSI[i].c) = m_pSI[i].v;
        }

        Eigen::SparseMatrix<float> smATranspose = smA.transpose();

        Eigen::VectorXf vecB(m_nRow);
        for (int i = 0; i < m_nRow; ++i)
        {
            vecB[i] = pColumnB[i];
        }
        vecB = smATranspose * vecB;//b = A'*b
        vecB = (-1) * vecB;

        smA = smATranspose * smA;//A = A'*A
        smA = (-1) * smA;
        smA.makeCompressed();
        //std::cout << smA << std::endl;

        Eigen::BiCGSTAB<Eigen::SparseMatrix<float>> linearSolver;
        linearSolver.compute(smA);
        Eigen::VectorXf vecX = linearSolver.solve(vecB);// 求一个A*x = b

        std::cout << "#iterations:     " << linearSolver.iterations() << std::endl;
        std::cout << "estimated error: " << linearSolver.error()      << std::endl;

        for (int i = 0; i < m_nColumn; ++i)
        {
            pX[i] = vecX[i];
        }

        return 1;
    }
```

迭代解法对应的头文件是#include "Eigen/IterativeLinearSolvers"。QR分解求线性系统的完整代码如下，相关定义很容易看懂。

``` stylus
//适合于解决最小二乘法问题
    int CSparseMatrix::SolveLinearSystemByEigenQR(double* pColumnB, double* pX)
    {
        Eigen::SparseMatrix<float> smA(m_nRow, m_nColumn);

        std::sort(m_pSI, m_pSI + m_nNum);//排序，列主序
        for (int i = 0; i < m_nNum; ++i)// 初始化非零元素
        {
            smA.insert(m_pSI[i].r, m_pSI[i].c) = m_pSI[i].v;
        }
        smA.makeCompressed();

        //std::cout << smA << std::endl;

        // 一个QR分解的实例
        Eigen::SparseQR<Eigen::SparseMatrix<float>, Eigen::COLAMDOrdering<int>> linearSolver;
        // 计算分解
        linearSolver.compute(smA);

        Eigen::VectorXf vecB(m_nRow);
        for (int i = 0; i < m_nRow; ++i)
        {
            vecB[i] = pColumnB[i];
        }
        Eigen::VectorXf vecX = linearSolver.solve(vecB);// 求一个A*x = b

        for (int i = 0; i < m_nColumn; ++i)
        {
            pX[i] = vecX[i];
        }

        return 1;
    }
```

  QR分解对应的头文件是#include "Eigen/SparseQR"。</pre>