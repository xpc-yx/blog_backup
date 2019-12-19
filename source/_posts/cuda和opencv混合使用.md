---
title: cuda和opencv混合使用
tags:
  - CUDA
id: 1374
categories:
  - 图像处理
  - CUDA
date: 2014-11-03 17:29:29
---

这里我既不介绍opencv的基本使用，也更加不会介绍cuda的使用。推荐下cuda的一本书：GPU高性能编程CUDA实战。
opencv这么强大的工具不用肯定是浪费了，opencv也有gpu的部分，据说也是用cuda实现的，但是灵活性肯定不如直接用cuda吧。
所以，我觉得只需要使用opencv负责cpu的部分，比如加载图片，gui之类的，而cuda负责并行的处理。还有，本着方便的原则，
opencv使用cpp的版本，不想再去管内存分配释放了。虽然，Mat相对来说更难使用。
下面是一个简短的交换rb通道的cuda和opencv混合的程序。

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

__global__ void swap_rb_kernel(const uchar3* src, uchar3* dst, int width, int height)
{
    int x = threadIdx.x + blockIdx.x * blockDim.x;
    int y = threadIdx.y + blockIdx.y * blockDim.y;

    if(x < width  y < height)
    {
        int offset = x + y * width;
        uchar3 v = src[offset];
        dst[offset].x = v.z;
        dst[offset].y = v.y;
        dst[offset].z = v.x;
    }
}

void swap_rb_caller(const uchar3* src, uchar3* dst, int width, int height)
{
    dim3 threads(16, 16);
    dim3 grids((width + threads.x - 1) / threads.x, (height + threads.y - 1) / threads.y);

    swap_rb_kernel<<<grids, threads>>>(src, dst, width, height);
    cudaThreadSynchronize();
}

int main()
{
    cv::Mat image = cv::imread("lena_1.jpg");
    cv::imshow("src", image);

    size_t memSize = image.step * image.rows;
    uchar3* d_src = NULL;
    uchar3* d_dst = NULL;
    cudaMalloc((void**)d_src, memSize);
    cudaMalloc((void**)d_dst, memSize);
    cudaMemcpy(d_src, image.data, memSize, cudaMemcpyHostToDevice);

    swap_rb_caller(d_src, d_dst, image.cols, image.rows);

    cudaMemcpy(image.data, d_dst, memSize, cudaMemcpyDeviceToHost);
    cv::imshow("gpu", image);
    cv::waitKey(0);

    cudaFree(d_src);
    cudaFree(d_dst);

    return 0;
}
```

运行效果：

[![](https://c2.staticflickr.com/8/7795/26842443314_eb03e5fc25_o.png)](https://c2.staticflickr.com/8/7795/26842443314_eb03e5fc25_o.png)
opencv部分不用做过多解释了，cuda的那些内存操作函数也不用解释。唯一需要解释的是核函数里面的这两句：int x = threadIdx.x + blockIdx.x \* blockDim.x;
int y = threadIdx.y + blockIdx.y \* blockDim.y;千万别搞错x和y，否则效果就完全不对了。根据cuda的模型，线程是一块一块的。一个线程块里面有很多线程，那么如何索引这些线程了？
把线程块看作是是三维的（一般用到一维或者二维）数组，然后根据数组索引得到具体线程。至于blockDim指的是一共有多少线程块了，这个也是三维的，意思一个gpu格子里面，
会出现三维的线程块组合。gpu格子的大小，在cuda里面用gridDim指代。所以，从上到下就是三层模型吧，三维的grid->三维的block->三维的thread。具体的理解，参照书籍或者教程吧。