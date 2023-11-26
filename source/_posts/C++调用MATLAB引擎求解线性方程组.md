---
title: C++调用MATLAB引擎求解线性方程组
tags:
  - 线性方程组
  - MATLAB
id: 1552
categories:
  - 编程语言 
  - C++
date: 2015-04-12 13:13:45
---

以前写过一篇[C++调用MATLAB引擎计算特征向量](http://www.xpc-yx.com/2015/01/20/%E4%BD%BF%E7%94%A8c%E8%B0%83%E7%94%A8matlab%E5%BC%95%E6%93%8E%E8%AE%A1%E7%AE%97%E7%A8%80%E7%96%8F%E7%9F%A9%E9%98%B5%E7%9A%84%E7%89%B9%E5%BE%81%E5%90%91%E9%87%8F/ "C++调用MATLAB引擎计算特征向量")，里面讲了如何配置环境等等。现在又有一个新的需求，求解线性系统。又想起了MATLAB这个工具，于是又写了个小类。这里要求解的是AX=B。其中，A是m*n的矩阵，X是n维行向量，B是m维列向量。MATLAB里面求解很简单X=A\B。

该类的头文件如下：

``` stylus
//求解线性系统AX = B.
    //A是Row*Column的矩阵,B是Row*1的列向量
    class CLinearSystem
    {
    public:
        CLinearSystem() {}
        CLinearSystem(double* pMatrixA, int nRow, int nColumn, double* pColumnB);
        ~CLinearSystem() {}

    public:
        void GetResult(double* pX);//pX保证能输出m_nColumn个元素

    private:
        double* m_pMatrixA;
        double* m_pColumnB;
        int m_nRow;
        int m_nColumn;
    };
```

源文件如下：

``` stylus
#include "stdafx.h"
#include "LinearSystem.h"
#include <cassert>
#include "engine.h"
#pragma comment(lib, "libeng.lib")
#pragma comment(lib, "libmx.lib")
#pragma comment(lib, "libmat.lib")

    CLinearSystem::CLinearSystem(double* pMatrixA, int nRow, int nColumn, double* pColumnB)
        : m_pMatrixA(pMatrixA), m_nRow(nRow), m_nColumn(nColumn), m_pColumnB(pColumnB)
    {

    }

    void CLinearSystem::GetResult(double* pX)
    {
        assert(pX != NULL);

        Engine *ep = NULL;
        if (!(ep = engOpen(NULL)))//打开matlab引擎
        {
            fprintf(stderr, "\nCan't start MATLAB engine\n");
            return;
        }

        mxArray* matrixA = mxCreateDoubleMatrix(m_nRow, m_nColumn, mxREAL);
        //matlab里面的矩阵是列主顺序，这里需要变换位置
        double* pA = mxGetPr(matrixA);
        for (int j = 0; j < m_nColumn; ++j)
        {
            for (int i = 0; i < m_nRow; ++i)
            {
                *pA++ = *(m_pMatrixA + i * m_nColumn + j);
            }
        }

        mxArray* columnB = mxCreateDoubleMatrix(m_nRow, 1, mxREAL);
        memcpy(mxGetPr(columnB), m_pColumnB, sizeof(double) * m_nRow * 1);

        engPutVariable(ep, "A", matrixA);
        engPutVariable(ep, "B", columnB);
        engEvalString(ep, "X = A\\B;");

        mxArray* rowX = engGetVariable(ep, "X"); //返回计算结果
        memcpy(pX, mxGetPr(rowX), sizeof(double) * m_nColumn);

        mxDestroyArray(matrixA);
        mxDestroyArray(columnB);
        mxDestroyArray(rowX);
        engClose(ep);
    }
```

该类里面就一个计算结果的函数。实现的过程也很简单，打开MATLAB引擎，创建了对应的矩阵和向量，计算表达式。注意，"X = A\\B;"中必须加转义\。另外，MATLAB中的矩阵是列主序的，也就是按照列存储的。所以，从C++的矩阵变换到MATLAB矩阵需要重新设置值，而不是简单的拷贝内存。
<span style="font-family: Georgia, 'Times New Roman', 'Bitstream Charter', Times, serif; line-height: 1.5;">  如果，A是巨大的稀疏矩阵，那么就应该创建稀疏矩阵来计算了。测试代码如下：</span>

``` stylus
//测试线性系统
int nRow = 3, nColumn = 2;
double pA[3][2] = { {4, 5}, {1, 2}, {3, 1} };
double pB[3] = {3, 15, 12};
CLinearSystem ls((double*)pA, nRow, nColumn, pB);
double pX[2];
ls.GetResult(pX);
printf("%f %f\n", pX[0], pX[1]);
```

输出为：3.000000 -0.600000

前面说了，系数矩阵的事情，现在代码进行了更新，加入了稀疏矩阵，A可以是稀疏矩阵传入，B的话没有当做稀疏矩阵传入了。不过，在调用MATLAB代码时候还是得作为稀疏矩阵。具体代码如下，就不细说了。

``` stylus
#pragma once

#ifndef LIBYX_LINEAR_SYSTEM_H
#define LIBYX_LINEAR_SYSTEM_H

#include "MatlabSparseMatrix.h"

namespace LibYX
{
    //求解线性系统AX = B.
    //A是Row*Column的矩阵,B是Row*1的列向量
    class CLinearSystem
    {
    public:
        CLinearSystem() {}
        CLinearSystem(double* pMatrixA, int nRow, int nColumn, double* pColumnB);
        CLinearSystem(MatlabSparseInfor* pSI, int nNum, int nRow, int nColumn, double* pColumnB);
        ~CLinearSystem() {}

    public:
        void GetResult(double* pX);//pX保证能输出m_nColumn个元素
        void GetResultSparse(double* pX);//中间过程使用稀疏矩阵计算结果

    private:
        double* m_pMatrixA;
        double* m_pColumnB;
        int m_nRow;
        int m_nColumn;

    private://稀疏矩阵形式输入A
        MatlabSparseInfor* m_pSI;
        int m_nNum;
    };
};

#endif

#include "stdafx.h"
#include "LinearSystem.h"
#include <cassert>
#include "engine.h"
#pragma comment(lib, "libeng.lib") 
#pragma comment(lib, "libmx.lib")
#pragma comment(lib, "libmat.lib")

namespace LibYX
{
    CLinearSystem::CLinearSystem(double* pMatrixA, int nRow, int nColumn, double* pColumnB)
        : m_pMatrixA(pMatrixA), m_nRow(nRow), m_nColumn(nColumn), m_pColumnB(pColumnB)
    {

    }

    CLinearSystem::CLinearSystem(MatlabSparseInfor* pSI, int nNum, int nRow, int nColumn, double* pColumnB)
        : m_pSI(pSI), m_nNum(nNum), m_nRow(nRow), m_nColumn(nColumn), m_pColumnB(pColumnB)
    {

    }

    void CLinearSystem::GetResult(double* pX)
    {
        assert(pX != NULL);

        Engine *ep = NULL;
        if (!(ep = engOpen(NULL)))//打开matlab引擎
        {
            fprintf(stderr, "\nCan't start MATLAB engine\n");
            return;
        }

        mxArray* matrixA = mxCreateDoubleMatrix(m_nRow, m_nColumn, mxREAL);
        //matlab里面的矩阵是列主顺序，这里需要变换位置
        double* pA = mxGetPr(matrixA);
        for (int j = 0; j < m_nColumn; ++j)
        {
            for (int i = 0; i < m_nRow; ++i)
            {
                *pA++ = *(m_pMatrixA + i * m_nColumn + j);
            }
        }

        mxArray* columnB = mxCreateDoubleMatrix(m_nRow, 1, mxREAL);
        memcpy(mxGetPr(columnB), m_pColumnB, sizeof(double) * m_nRow * 1);

        engPutVariable(ep, "A", matrixA);
        engPutVariable(ep, "B", columnB);
        engEvalString(ep, "X = A\\B;");

        mxArray* rowX = engGetVariable(ep, "X"); //返回计算结果
        memcpy(pX, mxGetPr(rowX), sizeof(double) * m_nColumn);

        mxDestroyArray(matrixA);
        mxDestroyArray(columnB);
        mxDestroyArray(rowX);
        engClose(ep);
    }

    void CLinearSystem::GetResultSparse(double* pX)
    {
        Engine *ep = NULL;
        if (!(ep = engOpen(NULL)))//打开matlab引擎
        {
            fprintf(stderr, "\nCan't start MATLAB engine\n");
            return;
        }

        //以下代码构造稀疏系数矩阵
        mxArray* sm = mxCreateSparse(m_nRow, m_nColumn, m_nNum, mxREAL);
        double* pr = mxGetPr(sm);
        mwIndex* ir = mxGetIr(sm); 
        mwIndex* jc = mxGetJc(sm); 

        int k = 0;
        int nLastC = -1;
        for (int i = 0; i < m_nNum; ++i)
        {
            pr[i] = m_pSI[i].v;
            ir[i] = m_pSI[i].r;

            if (m_pSI[i].c != nLastC)
            {
                jc[k] = i;
                nLastC = m_pSI[i].c;
                ++k;
            }
        }
        jc[k] = m_nNum;

        //以下代码构造稀疏列
        mxArray* columnB = mxCreateSparse(m_nRow, 1, m_nRow, mxREAL);
        pr = mxGetPr(columnB);
        ir = mxGetIr(columnB); 
        jc = mxGetJc(columnB); 

        jc[0] = 0;
        for (int i = 0; i < m_nRow; ++i)
        {
            pr[i] = m_pColumnB[i];
            ir[i] = i;
        }
        jc[1] = m_nRow;

        //将构造的稀疏矩阵传入MATLAB命令中
        engPutVariable(ep, "sm", sm);
        engPutVariable(ep, "columnB", columnB);
        engEvalString(ep, "X = sm\\columnB;");

        mxArray* rowX = engGetVariable(ep, "X"); //返回计算结果
        memcpy(pX, mxGetPr(rowX), sizeof(double) * m_nColumn);

        mxDestroyArray(rowX);
        mxDestroyArray(columnB);
        mxDestroyArray(sm);
        engClose(ep);
    }
};
```