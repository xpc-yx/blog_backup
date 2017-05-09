---
title: opencv的gpu部分实现dft
tags:
  - dft
  - GpuMat
  - idft
  - OpenCv
id: 1390
categories:
  - OpenCV
  - 图像处理
date: 2014-11-10 14:47:45
---

最近打算使用gpu优化L0Smooth的代码，但是不熟悉opencv的gpu部分的使用，
直接用cuda觉得太麻烦，还是继续试试opencv吧。
首先，从网站上下载下来的默认版本是不支持gpu的，必须下载代码下来，用cmake生成工程，注意
选择支持cuda等选项，具体参考教程。这样生成的版本才能支持gpu运算。
那么如何测试自己的opencv是否支持gpu计算了，以及自己的硬件是否符合要求？
使用这句代码打印cuda设备个数：
printf("Device Num:%d\n", cv::gpu::getCudaEnabledDeviceCount());
如果，个数大于0，那么说明你的显卡是支持cuda的，并且你的opencv版本支持gpu运算了。
下面是我测试成功的gpumat实现的dft和idft函数，输入和输出的都是cpu上的mat。
``` stylus
void Dft(cv::Mat in, cv::Mat out)
{
    cv::gpu::GpuMat gpuIn0(in.size(), CV_32FC1);
    gpuIn0.upload(in);

    std::vector<cv::gpu::GpuMat> planes;

    planes.push_back(gpuIn0);

    cv::Mat zero = cv::Mat::zeros(in.size(), CV_32FC1);
    cv::gpu::GpuMat gpuZero(in.size(), CV_32FC1);
    gpuZero.upload(zero);

    planes.push_back(gpuZero);

    cv::gpu::GpuMat gpuIn(in.size(), CV_32FC2);
    cv::gpu::merge(planes, gpuIn);

    cv::gpu::GpuMat gpuOut(gpuIn.size(), CV_32FC2);

    cv::gpu::dft(gpuIn, gpuOut, gpuIn.size(), 0);

    out.create(in.size(), CV_32FC2);
    gpuOut.download(out);
}

void IDft(cv::Mat in, cv::Mat out)
{
    cv::gpu::GpuMat gpuIn(in.size(), CV_32FC2);
    cv::gpu::GpuMat gpuOut(in.size(), CV_32FC2);

    gpuIn.upload(in);
    cv::gpu::dft(gpuIn, gpuOut, gpuIn.size(), cv::DFT_INVERSE);

    cv::gpu::GpuMat splitter[2];
    cv::gpu::split(gpuOut, splitter);

    out.create(in.size(), CV_32FC1);

    double minV, maxV;
    cv::gpu::minMax(splitter[0], minV, maxV);
    splitter[0].convertTo(splitter[0], CV_32F, 255.0 / maxV);
    splitter[0].download(out);
}
```
从代码上，可以看出，要尽可能把运算放到gpu上去，包括很多辅助运算，比如说merge,convert等可以加快速度。
这个版本的代码，dft的输入和输出都是双通道的，也就是一个通道实数，一个是复数的矩阵。通过merge生成和split分离。
这两个函数在分离通道单独处理时候非常有用，比如说可以分离彩色图像的三个通道，单独进行dft处理。最后再将结果合并。