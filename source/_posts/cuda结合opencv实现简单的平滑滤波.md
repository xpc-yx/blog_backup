---
title: cuda结合opencv实现简单的平滑滤波
tags:
  - 平滑滤波
id: 1379
categories:
  - 图像处理
  - CUDA
date: 2014-11-05 10:36:30
---

这次也是使用opencv的mat加载处理图像。唯一与上次有区别的是核函数的编写。
根据cuda的线程分配模型，每一个像素是分配单独的线程处理的。那么有这样的一个疑问？
像平滑滤波这些应用，如何在每一个线程中获取周围的像素了？
其实，这个问题很好解决。因为，在核函数中，我们能够根据线程id，块id，块尺寸等计算
出当前像素的位置。那么，自然能够得到其邻域的位置。从而实现了平滑滤波。
代码如下：

``` stylus
#include <stdlib.h>
#include <stdio.h>
#include <opencv/cv.h>
#include <opencv/highgui.h>
#include <opencv2/opencv.hpp>

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#ifdef _DEBUG
#pragma comment(lib, "opencv_core247d.lib")
#pragma comment(lib, "opencv_imgproc247d.lib")
#pragma comment(lib, "opencv_highgui247d.lib")
#else
#pragma comment(lib, "opencv_core247.lib")
#pragma comment(lib, "opencv_imgproc247.lib")
#pragma comment(lib, "opencv_highgui247.lib")
#endif // DEBUG

__global__ void smooth_kernel(const uchar3* src, uchar3* dst, int width, int height)
{
    int x = threadIdx.x + blockIdx.x * blockDim.x;
    int y = threadIdx.y + blockIdx.y * blockDim.y;

    if(x < width  y < height)
    {
        int offset = x + y * width;
        int left = offset - 1;
        if (x - 1 < 0)
        {
            left += 1;
        }
        int right = offset + 1;
        if (x + 1 >= width)
        {
            right -= 1;
        }
        int top = offset - width;
        if (y - 1 < 0)
        {
            top += width;
        }
        int bottom = offset + width;
        if (y + 1 >= height)
        {
            bottom -= width;
        }

        dst[offset].x = 0.125 * (4 * src[offset].x + src[left].x + src[right].x + src[top].x + src[bottom].x);
        dst[offset].y = 0.125 * (4 * src[offset].y + src[left].y + src[right].y + src[top].y + src[bottom].y);
        dst[offset].z = 0.125 * (4 * src[offset].z + src[left].z + src[right].z + src[top].z + src[bottom].z);
    }
}

void smooth_caller(const uchar3* src, uchar3* dst, int width, int height)
{
    dim3 threads(16, 16);
    dim3 grids((width + threads.x - 1) / threads.x, (height + threads.y - 1) / threads.y);

    smooth_kernel<< <grids, threads >> >(src, dst, width, height);
    cudaThreadSynchronize();
}

int main()
{
    cv::Mat image = cv::imread("lena.png");
    cv::imshow("src", image);

    size_t memSize = image.step * image.rows;
    uchar3* d_src = NULL;
    uchar3* d_dst = NULL;
    cudaMalloc((void**)d_src, memSize);
    cudaMalloc((void**)d_dst, memSize);
    cudaMemcpy(d_src, image.data, memSize, cudaMemcpyHostToDevice);

    smooth_caller(d_src, d_dst, image.cols, image.rows);

    cudaMemcpy(image.data, d_dst, memSize, cudaMemcpyDeviceToHost);
    cv::imshow("gpu", image);
    cv::waitKey(0);

    cudaFree(d_src);
    cudaFree(d_dst);

    return 0;
}
```

效果如图：
![](https://c2.staticflickr.com/8/7602/26844527913_20fbe94fea_o.png)