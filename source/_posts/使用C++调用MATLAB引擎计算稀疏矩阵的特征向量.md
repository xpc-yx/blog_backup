---
title: 使用C++调用MATLAB引擎计算稀疏矩阵的特征向量
tags:
  - 特征向量
  - MATLAB
id: 1492
categories:
  - 编程语言 
  - C++
date: 2015-01-20 21:43:19
---

上一篇文章讲了如何用MATLAB计算稀疏矩阵的特征向量，但是我们最终的目的是使用C\+\+达到这个需求。大致搜索了下，发现使用C++调用MATLAB计算引擎的方式最方便，就采用了，目前的计算速度和方便性都能满足要求。下面讲一下如何操作。

1.首先是安装MATLAB，并且保证版本正确，比如32位程序只能调用32位的MATLAB，如我的机器是64位win8.1，所以必须强制安装32位的MATLAB，才能配合我用vs2010编写的32位程序。如果，我用vs2010开放64位程序，那么当然是可以使用64MATLAB的，但是配置64位开源库是个大工程，有些库并没有针对64位版本测试过。

2.假设我的MATLAB安装在C:\Program Files (x86)\MATLAB下面，那么include目录是C:\Program Files (x86)\MATLAB\R2013a\extern\include，lib目录是C:\Program Files (x86)\MATLAB\R2013a\extern\lib\win32\microsoft，bin目录是C:\Program Files (x86)\MATLAB\R2013a\bin\win32。include和lib在vs里面设置好就行了，至于bin目录需要加入到path环境变量中，最后重启电脑生效，当然你一个个去找需要的dll也是可以的。

3.配置好之后，就可以使用MATLAB引擎了。大致需要1>打开引擎，2>用C\+\+创建变量，3>把变量对应到MATLAB命令中，4>执行MATLAB命令，5>将MATLAB变量传回C\+\+这样的一些操作。比如，engOpen打开引擎，mxCreateSparse用于创建稀疏矩阵，engPutVariable将变量传入MATLAB，engEvalString执行命令，engGetVariable返回结果。具体怎么操作还是得参考相应教程。另外，可以用C\+\+创建不同类型的变量，稀疏矩阵是比较特殊的一种。

4.至于如何用MATLAB计算稀疏矩阵的特征向量，参阅上一篇文章。

5.关键的一步，如何设置mxCreateSparse返回的稀疏矩阵的值。先看下面的代码吧。

``` stylus
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
```

pr对应的是值，ir对应的是行，关键的是jc，jc并不是列，而是到当前列为止出现的值数目，具体可以查阅MATLAB文档，或者理解下以上代码，正确初始化稀疏矩阵是成功的关键。
下面随附我的计算拉普拉斯矩阵FiedlerVector的函数。

``` stylus
void CSparseMatrix::GetFiedlerVector(double* pVector, int nChoose)
    {
        assert(nChoose >= 0  nChoose <= 5);

        Engine *ep = NULL;
        if (!(ep = engOpen(NULL)))//打开matlab引擎
        {
            fprintf(stderr, "\nCan't start MATLAB engine\n");
            return;
        }

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

        engPutVariable(ep, "sm", sm);
        engEvalString(ep, "max_d = eigs(sm, 1);");//获得最大绝对值的特征值

        double fMaxE;
        mxArray* max_d = engGetVariable(ep, "max_d");
        memcpy(fMaxE, (void *)mxGetPr(max_d), sizeof(double));//获得最大的特征值(假设特征值是从最大排列到0)

        //更新对角线元素，相当于sm = sm - fMaxE，这样会使计算出来的特征值都减去fMaxE
        pr = mxGetPr(sm);
        for (int i = 0; i < m_nNum; ++i)
        {
            pr[i] = m_pSI[i].v;
            if (m_pSI[i].r == m_pSI[i].c)//对角线元素
            {
                pr[i] -= fMaxE;
            }
        }

        engPutVariable(ep, "sm", sm);
        engEvalString(ep, "[V,D] = eigs(sm);");
        engEvalString(ep, "[newD,IX] = sort(diag(D));");
        engEvalString(ep, "newV=V(:,IX);");

        const int EVAl_STR_LEN = 100;
        char szEvalString[EVAl_STR_LEN];
        sprintf(szEvalString, "Fiedler = newV(:, %d);", nChoose);
        engEvalString(ep, szEvalString);

        mxArray* fiedler = engGetVariable(ep, "Fiedler"); //返回计算结果
        memcpy(pVector, (void *)mxGetPr(fiedler), sizeof(double) * m_nRow);

        mxDestroyArray(sm);
        mxDestroyArray(fiedler);
        engClose(ep);
    }
```

参照以上函数基本可以知道本文所讲的内容了，一切尽在代码中。