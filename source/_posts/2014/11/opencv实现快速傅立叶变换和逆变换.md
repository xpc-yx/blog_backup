---
title: opencv实现快速傅立叶变换和逆变换
tags:
  - dft
  - idft
  - Mat
  - OpenCv
id: 1382
categories:
  - 图形图像
  - 图像处理
  - OpenCV
date: 2014-11-07 14:10:54
---

说实话觉得网上很多人转载的文章的挺坑的，全部是opencv文档程序的翻译，看来看去都是那一
篇，真的没啥意思。[文档的地址](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/core/discrete_fourier_transform/discrete_fourier_transform.html)。
本来opencv实现dft就是一个函数的事情，但是很少有关于逆变换使用的资料。我这几天在翻译
matlab版本的L0Smooth到opencv上面，就碰到这样一件很坑爹的事情。
首先，很少有人说清楚这个函数的使用方法。还有，根据教程，dft之前最好扩充原矩阵到合适的尺
寸(2,3,5的倍数)，再调用dft会加快速度。那么，idft的时候了？如何恢复原有的尺寸？
在我的L0Smooth代码里，就碰到这样的事情了。如果，图片尺寸是2，3，5的倍数，那么能够得到
正确结果。否则得到是全黑的图片。如果，我不扩张矩阵，那么就能正确处理。
所以，到这里，我不推荐调用dft之前先扩充矩阵了。因为，我找了很久也没找到解决办法。
我数学水平有限，也分析不出原因，也没有时间去系统的学习这些了。
这里提供两个例子，说明dft和idft的使用。
例子一：类似于opencv官方文档的例子
``` stylus
#include "opencv2/core/core.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/highgui/highgui.hpp"
#include <iostream>

#ifdef _DEBUG
#pragma comment(lib, "opencv_core247d.lib")
#pragma comment(lib, "opencv_imgproc247d.lib")
#pragma comment(lib, "opencv_highgui247d.lib")
#else
#pragma comment(lib, "opencv_core247.lib")
#pragma comment(lib, "opencv_imgproc247.lib")
#pragma comment(lib, "opencv_highgui247.lib")
#endif // DEBUG

int main()
{
    // Read image from file
    // Make sure that the image is in grayscale
    cv::Mat img = cv::imread("lena.JPG",0);

    cv::Mat planes[] = {cv::Mat_<float>(img), cv::Mat::zeros(img.size(), CV_32F)};
    cv::Mat complexI;    //Complex plane to contain the DFT coefficients {[0]-Real,[1]-Img}
    cv::merge(planes, 2, complexI);
    cv::dft(complexI, complexI);  // Applying DFT

    //这里可以对复数矩阵comlexI进行处理

    // Reconstructing original imae from the DFT coefficients
    cv::Mat invDFT, invDFTcvt;
    cv::idft(complexI, invDFT, cv::DFT_SCALE | cv::DFT_REAL_OUTPUT ); // Applying IDFT
    cv::invDFT.convertTo(invDFTcvt, CV_8U); 
    cv::imshow("Output", invDFTcvt);

    //show the image
    cv::imshow("Original Image", img);

    // Wait until user press some key
    cv::waitKey(0);

    return 0;
}
```
代码意思很简单，dft之后再idft，注意参数额，必须有DFT_SCALE。代码中，先merge了个
复数矩阵，在例子2中可以看到，其实这一步可以去掉。
例子2：
``` stylus
#include "opencv2/core/core.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/highgui/highgui.hpp"
#include <iostream>

#ifdef _DEBUG
#pragma comment(lib, "opencv_core247d.lib")
#pragma comment(lib, "opencv_imgproc247d.lib")
#pragma comment(lib, "opencv_highgui247d.lib")
#else
#pragma comment(lib, "opencv_core247.lib")
#pragma comment(lib, "opencv_imgproc247.lib")
#pragma comment(lib, "opencv_highgui247.lib")
#endif // DEBUG

int main()
{
    // Read image from file
    // Make sure that the image is in grayscale
    cv:;Mat img = cv::imread("lena.JPG",0);

    cv::Mat dftInput1, dftImage1, inverseDFT, inverseDFTconverted;
    cv::img.convertTo(dftInput1, CV_32F);
    cv::dft(dftInput1, dftImage1, cv::DFT_COMPLEX_OUTPUT);    // Applying DFT

    // Reconstructing original imae from the DFT coefficients
    cv::idft(dftImage1, inverseDFT, cv::DFT_SCALE | cv::DFT_REAL_OUTPUT ); // Applying IDFT
    cv::inverseDFT.convertTo(inverseDFTconverted, CV_8U);
    cv::imshow("Output", inverseDFTconverted);

    //show the image
    cv::imshow("Original Image", img);

    // Wait until user press some key
    waitKey(0);
    return 0;
}
```
从代码中可以看到，dft时候添加参数DFT_COMPLEX_OUTPUT，就可以自动得到复数矩阵了，代码更加简洁。
注意，必须先将图片对应的uchar矩阵转换为float矩阵，再进行dft，idft，最后再转换回来。