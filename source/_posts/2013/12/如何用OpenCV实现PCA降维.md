---
title: 如何用OpenCV实现PCA降维
tags:
  - OpenCv
  - PCA
  - PCA降维
id: 1021
categories:
  - 图形图像
  - 图像处理
  - OpenCV
date: 2013-12-19 10:23:10
---

这里讲的不是pca的原理，我还没仔细去研究过。我刚刚使用过opencv进行pca降维，效果成功过。所以只是记录下方式和注意的地方。当然也参考了网上很多的代码。网上的代码大多大同小异，我的代码当然也和别人的差不多。

首先，我用的是C版本的OpenCV。我不是嫌弃C++版本的，而是C版本的OpenCV本来已经够复杂了，我不想再跟踪C++版本的这些对象的内存了。我们需要使用到OpenCV的CvMat结构存储数据。

我们需要使用以下的CvMat。
CvMat* m_pData;//原始样本集
CvMat* m_pMean;//平均值向量、
CvMat* m_pEigVals;//协方差矩阵的特征值
CvMat* m_pEigVecs;//协方差矩阵的特征向量
CvMat* m_pResult;//PCA降维的结果
CvMat* m_pQueryIn;//输入的一个数据
CvMat* m_pQueryOut;//用样本集的PCA信息降维后的一个数据

首先，我们创建数据m_pData = cvCreateMat(m_nRows, m_nDim, CV_64FC1);然后初始化数据。再创建m_pMean，m_pEigVals，m_pEigVecs。然后调用cvCalcPCA计算平均值向量和协方差矩阵的特征值和特征向量。最后一步是cvProjectPCA，在这个函数里面可以指定维度。我们就可以得到降维之后的数据。

现在再讲查询。首先创建一个数据。m_pQueryIn = cvCreateMat(1, m_nDim, CV_64FC1);m_pQueryOut = cvCreateMat(1, m_nUseDim, CV_64FC1);然后，我们初始化m_pQueryIn。再调用cvProjectPCA(m_pQueryIn, m_pMean, m_pEigVecs, m_pQueryOut);就可以得到降维之后的数据。

下面看下综合起来的代码。

``` stylus
if (m_pData)
{
	cvReleaseMat(m_pData);
}
m_pData = cvCreateMat(m_nRows, m_nDim, CV_64FC1);
//在这里初始化样本集合
if (m_pMean)
{
	cvReleaseMat(m_pMean);
}
m_pMean = cvCreateMat(1, m_nDim, CV_64FC1);
if (m_pEigVals)
{
	cvReleaseMat(m_pEigVals);
}
m_pEigVals = cvCreateMat(1, std::min(m_nRows, m_nDim), CV_64FC1);

if (m_pEigVecs)
{
	cvReleaseMat(m_pEigVecs);
}
m_pEigVecs = cvCreateMat(std::min(m_nRows, m_nDim), m_nDim, CV_64FC1);

cvCalcPCA(m_pData, m_pMean, m_pEigVals, m_pEigVecs, CV_PCA_DATA_AS_ROW);

if (m_pResult)
{
	cvReleaseMat(m_pResult);
}
m_pResult = cvCreateMat(m_nRows, m_nUseDim, CV_64FC1);
cvProjectPCA(m_pData, m_pMean, m_pEigVecs, m_pResult);//现在m_pResult保存的就是降低维度之后的信息

//初始化查询需要使用的数据
if (m_pQueryIn)
{
	cvReleaseMat(m_pQueryIn);
}
if (m_pQueryOut)
{
	cvReleaseMat(m_pQueryOut);
}
m_pQueryIn = cvCreateMat(1, m_nDim, CV_64FC1);
m_pQueryOut = cvCreateMat(1, m_nUseDim, CV_64FC1);

//从m_nDim降到m_nUseDim维
double* CNeighborSet::Pca(double* pfIn)
{
	m_pQueryIn->data.db = pfIn;
	cvProjectPCA(m_pQueryIn, m_pMean, m_pEigVecs, m_pQueryOut);//现在pResult保存的是降低维度之后的信息
	return m_pQueryOut->data.db;
}
```

现在还有一个问题，是确定我们到底能够降低到多少维度了。**如果维度降低太多，就保持不了足够的信息，就会失真，达不到应用的效果。**当然如果效果不对，可以慢慢增大维度，直到够用为止。
当然还有其它办法了。**比如说，在代码中计算我们应该保留多少维度就能够保持90%的信息了。**下面要给出的就是这个办法。

``` stylus
	double fSum = 0.0;
	double fSum0 = 0.0;
	for (int i = 0; i < m_pEigVals->cols; ++i)
	{
		fSum += *(m_pEigVals->data.db + i);
	}

	double fTmp = fSum * m_fPcaRatio;
	for (int i = 0; i < m_pEigVals->cols; ++i)
	{
		fSum0 += *(m_pEigVals->data.db + i);
		if (fSum0 >= fTmp)
		{
			m_nUseDim = i + 1;
			break;
		}
	}
```