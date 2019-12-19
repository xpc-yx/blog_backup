---
title: Hough变换检测直线
tags:
  - Hough变换
id: 628
categories:
  - 图像处理
date: 2013-01-02 13:23:32
---

hough变换是图像处理里面一种检测直线等规则曲线的方法。这里介绍下检测直线的原理和实现方法，最后给出相关的代码。

先给出数学上面的里面，斜截式直线y=kx+b有两个参数k,b，注意直线方程是在笛卡儿坐标系xoy中的。任意一条直线对应于kob平面中一个点(k,b)。那么，对于xoy平面中的任意一个点肯定有无数条通过它的直线，那么直线都有对应的kob平面中的点，这些点能组成一条直线。**综合起来就是，xoy平面中一条直线对应于kob平面中的一个点，xoy平面中的一个点对应于kob平面中的一条直线。**
现在有个问题是**斜截式无法表示xoy平面中所有直线**，那么我们希望能找到能够表示xoy平面中所有直线的参数式子。这个式子是r=x*cos(θ)+y*sin(θ)。推导过程如下：
![](https://c7.staticflickr.com/8/7224/27351286542_6ddb76e445_o.jpg)
r为原点到直线的距离，(x0,y0)为垂足，θ为垂线和x轴正向的夹角，那么对于直线上面的任意的一个点都有
(x0, y0) * (x-x0,y-y0)=0,得到x * x0 - x0 * x0 + y * y0 - y0 * y0 = 0，即x * x0 + y * y0 = x0 * x0 + y0 * y0 = r * r。等式两边再除以r得到r = x * cos(θ) + y * sin(θ)。那么这个关于(θ,r)的参数式子可以表示xoy平面上所有的直线了。

现在再来讨论下如何根据这个参数式子检测直线的。
我们手上的只有xoy平面上的图像。而且根据我们的推理，我们的图像的原点必须在左下角，因为我们是用笛卡尔坐标系推出该参数式子的。那么，我们可以枚举图像上面每一个可能是直线上面的点(比如，我们可以对图像阈值化后，像素值为255的点就可能是直线上面的点），由于图像上的每个点对应于θor平面上面的一条曲线(这里管它是直线还是曲线了，对于检测原理没影响)，那么我们就能得到很多θor平面上的曲线。我们对每个(θ,r)点计数通过其上的曲线个数，最后选取曲线个数最大的那个点（θmax,Rmax）其对应的肯定是我们要检测的直线。至于其它的预处理，**一般是梯度滤波增强边缘或者拉普拉斯增强边缘，然后弄个全局二值化，就可以用hough变换检测直线了(我这次的实验就没有平滑滤波噪声，那样会使直线变粗，使检测效果变坏）**。
最后我给出我的检测直线的代码，并指出代码需要主要的实现点。

``` stylus
//针对hough变换的定义得到的直线相对的是坐标系原点的坐标系
//针对hough变换的定义得到的直线相对的是坐标系原点的坐标系
void CxBitmap::HoughLine(int* pnR, double* pfTheta)
{
    const double PI = 4.0 * atan(1.0);
    double fRate = PI / 180;
    int nWidth = GetWidth(), nHeight = GetHeight();
    int iRMax = (int)sqrt(nWidth * nWidth + nHeight * nHeight) + 1;
    int iThMax = 360;
    int iTh;
    int iR;
    int iMax = -1;
    int iThMaxIndex = -1;
    int iRMaxIndex = -1;
    int *pnArray = NULL;
    int nPos = 0;

    if (m_bBinary == FALSE)
    {
        GrayToBinary();
    }
    pnArray = new int[iRMax * iThMax];//iRMax行,每一行长度是iThMax
    memset(pnArray, 0, sizeof(int) * iRMax * iThMax);

    for (int y = 0; y < nHeight; y++)
    {
        nPos = m_nBytesPerLine * y;
        for (int x = 0; x < nWidth; x++)
        {
            if(pbyBuffer[nPos] == 255)
            {
                for(iTh = 0; iTh < iThMax; iTh++) { iR = (int)(x * cos(iTh * fRate) + y * sin(iTh * fRate)); if(iR > 0)
                    {
                        pnArray[iR * iThMax + iTh]++;
                    }
                }
            }
            nPos++;
        } // x
    } // y

    for(iR = 0; iR < iRMax; iR++)
    {
        for(iTh = 0; iTh < iThMax; iTh++) { int iCount = pnArray[iR * iThMax + iTh]; if(iCount > iMax)
            {
                iMax = iCount;
                iRMaxIndex = iR;
                iThMaxIndex = iTh;
            }
        }
    }

    *pnR = iRMaxIndex;
    *pfTheta = fRate * iThMaxIndex;

    delete [] pnArray;
}
```

注意nPos **必须按m_nBytesPerLine对齐**，因为即使是灰度图像每行的长度也不一定是图像的宽度，如果这个错了，检测结果就完全错了。另外一个是计算出来的iR值必须大于0才有效。
相关博文可以参考这篇关于hough变换的文章，[我也说说hough变换](http://www.narutoacm.com/archives/hough-transform/ "我也说说hough变换")