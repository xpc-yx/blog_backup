---
title: 位图数字图像处理类CxBitmap
tags:
  - CxBitmap
id: 651
categories:
  - 图形图像
  - 图像处理
date: 2013-01-03 14:31:25
---

这是我在做数字图像处理实验中实现的一个类。该类包含了很多丰富的功能。虽然写得不是太规范，不过我还是尽我的能力让它规范起来。尽可能的便于使用，也尽可能的效率高些，尽可能得增加应用场合。自认为用这个类处理位图基本上足够了。
该类虽说不能处理所有格式的位图，因为时间有限，没有去实现了。但是，基本上8位和24位位图能够完美处理，其它格式的会出错，因为压根没有考虑。那么，现在我来介绍下该类的功能吧。
首先，**从文件加载位图，获取位图所有信息和数据。彩色位图灰度化(24位和8位的都可以，24位位图灰度化后会变成8位），使用内部函数计算全局阈值再二值化或者用给定阈值二值化，均值滤波，中值滤波，拉普拉斯滤波，四个方向的梯度滤波，log变换图像，exp变换图像，hough变换检测最明显的一条直线，得到像素分布统计数组，将图片直方图绘制到指定dc和矩形框内部，绘制位图到DC指定位置，拉伸绘制位图到DC指定位置，保存当前状态的图片(也就是你可以将滤波或者任何变换后的图片再保存到文件)，输出图像数据到指定文件，创建位图头部，设置位图数据等**。功能还是非常丰富的，基本上可以满足很多要求，代码都经常我的认真调试，代码实现上也注意了性能和使用场合。
任意你对代码不满意的部分或者使用出现问题都可以email我，或者自己直接修改。我就不打算再增强它的功能或者优化其实现或者把它改得更规范点了。

类定义如下，

``` stylus
#ifndef GRAY_BITMAP_H
#define GRAY_BITMAP_H

#define BITMAP_ID 0x4D42 // universal id for a bitmap
#define MAX_COLORS_PALETTE 256

#include <windows.h>

#ifndef SAFE_DELETE
#define SAFE_DELETE(p) { if (p) { delete p; p = NULL; } }
#endif
#ifndef SAFE_DELETE_ARRAY
#define SAFE_DELETE_ARRAY(p) { if (p) { delete [] p; p = NULL; } }
#endif

#define NEIGHBOUR_SIZE (3)

// this builds a 24 bit color value in 8.8.8 format 
#define RGB24BIT(r,g,b) ((b) + ((g) << 8) + ((r) << 16) )

class CxBitmap
{
//以下是操作位图的一些函数
public:
    CxBitmap();
    ~CxBitmap();
    int CreateBitmap(int nWidth, int nHeight, UINT nBitcount, const void* pvBits);
    int LoadBitmap(const char* pszFileName = NULL);
    void Draw(HDC hdc, int nStartX, int nStartY);
    void StretchDraw(HDC hDc, int nStartX, int nStartY, int nWidth, int nHeight);
    void DrawHistogram(HDC hDc, const RECT rect);
    BOOL IsAvailable() { return m_bLoad; }
    void SaveFile(char* pszBitmapName);
    void WriteBuffer(char* pszFileName);
	int WriteMeshObj(const char* pcszObjFileName);

//以下是获取和设置位图的属性的一些函数
public:
    int GetWidth() const { return bitmapinfoheader.biWidth; }
    int GetHeight() const { return bitmapinfoheader.biHeight; }
    int GetBytesPerPixel() const { return bitmapinfoheader.biBitCount / 8; }
    int GetBytesPerLine() const { return m_nBytesPerLine; }
    BYTE* GetBuffer() const { return pbyBuffer; }
	BYTE* GetUnAlignBuffer() const { return pbyUnAlignBuffer; }
    int GetImageSize() const { return bitmapinfoheader.biSizeImage; }
    void SetBitmapName(char* pszBitmapName) { strcpy(m_szBitmapName, pszBitmapName); }
    void SetBuffer(const void* pvBuffer)
    { 
        m_bReadOnly = TRUE;
        m_bLoad = TRUE;
        pbyBuffer = (BYTE*)pvBuffer;
    }
    BOOL IsReadOnly() const { return m_bReadOnly; }
    BOOL SetReadOnly(BOOL bReadOnly) { return m_bReadOnly = bReadOnly; }

//以下是图像处理的一些函数
public:
    void ColorToGray();//把彩色图像转换为灰度图像
    int* GetHistogram();//得到直方图统计数组(不同灰度值的像素数目)
    int GrayToBinary(int nThreshold);
    int GrayToBinary();
    void MedianFilter();//中值滤波图像
    void AverageFilter();//均值滤波
    void LaplaceFilter();//拉普拉斯滤波
    void GradientFilterLeft();//梯度滤波
    void GradientFilterRight();
    void GradientFilterUp();
    void GradientFilterDown();
    void LogTransfer();//对图像进行对数变换
    void ExpTransfer();
    void GaussFilter(int nRadius = 1);
    //用Hough变换检测二值化后图像中的一条直线(R = x*cos(theta) + y*sin(theta),theta是弧度)
    void HoughLine(int* pnR, double* pfTheta);

//内部用到的一些私有函数
private:
    void FlipBuffer();
    void FreeBitmap();
    int GetMedian(int* pnArr, int nSize);
    void Filter(double* pfFactors, int nSize, BOOL bAve);
    int GetThreshold(int* pnHistogram);
    void InitPalette();

private:
    char m_szBitmapName[MAX_PATH];
    BITMAPFILEHEADER bitmapfileheader;  // this contains the bitmapfile header
    BITMAPINFOHEADER bitmapinfoheader;  // this is all the info including the palette
    RGBQUAD palette[256];               // we will store the palette here
    BOOL m_bReadOnly;
    BYTE* pbyBuffer;
	BYTE* pbyUnAlignBuffer;
    BYTE* pbyTmpBuffer;  //临时内存缓冲，用于滤波
    BOOL m_bHistogram;    //是否已经获得直方图数组了
    int* m_pnHistogram;
    BOOL m_bLoad;     //是否已经加载图片了
    BOOL m_bScale;    //是否已经灰度化了
    BOOL m_bBinary;
    int m_nBytesPerLine;
    int m_nBytesPerPixel;
};

#endif
```

类实现如下，

``` stylus
#include "CxBitmap.h"
#include <stdio.h>
#include <math.h>
#include <assert.h>
#include <algorithm>
using namespace std;

CxBitmap::CxBitmap() 
{ 
    m_bLoad = FALSE;
    pbyBuffer = NULL;
    pbyTmpBuffer = NULL;
    m_bHistogram = FALSE;
    m_pnHistogram = NULL; 
    m_bReadOnly = FALSE;
    m_bBinary = FALSE;
}

CxBitmap::~CxBitmap()
{
    FreeBitmap();
    SAFE_DELETE(m_pnHistogram);
}

void CxBitmap::FreeBitmap()
{
    //如果是调用SetBuffer得到的图片,则不需要释放内存,否则会造成内存错误
    if (m_bReadOnly == FALSE) SAFE_DELETE_ARRAY(pbyBuffer);
    SAFE_DELETE_ARRAY(pbyTmpBuffer);
    m_bLoad = FALSE;
    m_bHistogram = FALSE;
    m_bScale = FALSE;
    m_bBinary = FALSE;
}

void CxBitmap::InitPalette()
{
    for (int i = 0; i < MAX_COLORS_PALETTE; ++i)
    {
        palette[i].rgbBlue = palette[i].rgbGreen = palette[i].rgbRed = i;
    }
}

int CxBitmap::CreateBitmap(int nWidth, int nHeight, UINT nBitcount, const void* pvBits)
{
    FreeBitmap();
    m_nBytesPerPixel = nBitcount / 8;
    m_nBytesPerLine = (nWidth * nBitcount + 31) / 32 * 4;

    //设置bitmapfileheader
    bitmapfileheader.bfType = BITMAP_ID;
    bitmapfileheader.bfReserved1 = bitmapfileheader.bfReserved2 = 0;
    bitmapfileheader.bfOffBits = sizeof(bitmapfileheader) + sizeof(bitmapinfoheader);
    if (nBitcount == 8)
    {
        bitmapfileheader.bfOffBits += sizeof(palette);
        InitPalette();
    }
    bitmapfileheader.bfSize = bitmapfileheader.bfOffBits + m_nBytesPerLine * nHeight;
    //设置bitmapinfoheader
    bitmapinfoheader.biSize = sizeof(bitmapinfoheader);
    bitmapinfoheader.biWidth = nWidth;
    bitmapinfoheader.biHeight = nHeight;
    bitmapinfoheader.biPlanes = 1;
    bitmapinfoheader.biBitCount = nBitcount;
    bitmapinfoheader.biCompression = BI_RGB;
    bitmapinfoheader.biSizeImage = m_nBytesPerLine * nHeight;
    bitmapinfoheader.biXPelsPerMeter = bitmapinfoheader.biYPelsPerMeter = 0;
    bitmapinfoheader.biClrUsed = 0;
    if (nBitcount == 8)
    {
        bitmapinfoheader.biClrUsed = 256;
    }
    bitmapinfoheader.biClrImportant = 0;
    SetBuffer(pvBits);
    pbyTmpBuffer = new BYTE[bitmapinfoheader.biSizeImage];

    return TRUE;
}

void CxBitmap::FlipBuffer()
{
    int nLenOfLine = (bitmapinfoheader.biWidth * bitmapinfoheader.biBitCount) / 8;
    BYTE* pbyTemp = new BYTE[nLenOfLine];
    int nEnd = bitmapinfoheader.biHeight / 2 - 1;

    for (int i = 0; i <= nEnd; ++i)
    {
        memcpy(pbyTemp, pbyBuffer + i * nLenOfLine, nLenOfLine);
        memcpy(pbyBuffer + i * nLenOfLine, pbyBuffer + (bitmapinfoheader.biWidth - i - 1)
            * nLenOfLine, nLenOfLine);
        memcpy(pbyBuffer + (bitmapinfoheader.biWidth - i - 1) * nLenOfLine, pbyTemp, nLenOfLine);
    }
    delete [] pbyTemp;
}

int CxBitmap::LoadBitmap(const char* pszFileName)
{
	int i;
	int nUnAlignBytesPerLine;

    FreeBitmap();
	if (pszFileName != NULL)
	{
		strcpy(m_szBitmapName, pszFileName);
	}

    FILE* fpBitmap = fopen(m_szBitmapName, "rb");

    if (fpBitmap == NULL)
    {
        return FALSE;
    }

    int nSizeOfHeader = sizeof(bitmapfileheader);
    if (nSizeOfHeader != 14)//字节对齐可能会导致其变成16
    {
        nSizeOfHeader = 14;
    }
    fread(bitmapfileheader, nSizeOfHeader, 1, fpBitmap);
    if (bitmapfileheader.bfType != BITMAP_ID)//检测是否是位图
    {
        fclose(fpBitmap);
        return FALSE;
    }
    fread(bitmapinfoheader, sizeof(bitmapinfoheader), 1, fpBitmap);
    if (bitmapinfoheader.biBitCount == 8)//8位位图,那么需要读取调色板
    {
        fread(palette, sizeof(PALETTEENTRY) * MAX_COLORS_PALETTE, 1, fpBitmap);
    }
    if (bitmapinfoheader.biSizeImage == 0)
    {
        bitmapinfoheader.biSizeImage = bitmapinfoheader.biWidth * bitmapinfoheader.biHeight
            * bitmapinfoheader.biBitCount / 8;
    }
    pbyBuffer = new BYTE[bitmapinfoheader.biSizeImage];
    if (pbyBuffer == NULL)
    {
        return FALSE;
    }
    fread(pbyBuffer, bitmapinfoheader.biSizeImage, 1, fpBitmap);
    if (bitmapinfoheader.biHeight < 0)
    {
        bitmapinfoheader.biHeight = -bitmapinfoheader.biHeight;
        FlipBuffer();
    }
    fclose(fpBitmap);

    m_nBytesPerLine = (bitmapinfoheader.biWidth * bitmapinfoheader.biBitCount + 31) / 32 * 4;
    m_nBytesPerPixel = bitmapinfoheader.biBitCount / 8;
	pbyUnAlignBuffer = pbyBuffer;
	nUnAlignBytesPerLine = bitmapinfoheader.biWidth * m_nBytesPerPixel;
	if (m_nBytesPerLine != nUnAlignBytesPerLine)
	{
		pbyUnAlignBuffer = new BYTE[nUnAlignBytesPerLine * bitmapinfoheader.biHeight];
		for (i = 0; i < bitmapinfoheader.biHeight; ++i)
		{
			memcpy(pbyUnAlignBuffer + i * nUnAlignBytesPerLine, pbyBuffer
				+ i * m_nBytesPerLine, nUnAlignBytesPerLine);
		}
	}
    m_bLoad = TRUE;
    pbyTmpBuffer = new BYTE[bitmapinfoheader.biSizeImage];

    return TRUE;
}

//Y=0.3R+0.59G+0.11B
//该函数仅简单地处理24位和8位位图
void CxBitmap::ColorToGray()
{
    int nGray = 0;
    int nRead = 0, nWrite = 0;
    int i, j;
    int nBytesWriteLine = (bitmapinfoheader.biWidth * 8 + 31) / 32 * 4;//灰度后每个像素只有8bits

    if (m_bLoad  m_bScale == FALSE)//如果已经加载了图片并且没有进行灰度化处理
    {
        if (bitmapinfoheader.biBitCount == 24)
        {
            bitmapfileheader.bfOffBits += sizeof(palette);
            bitmapinfoheader.biBitCount = 8;
            bitmapinfoheader.biClrUsed = 256;
            bitmapinfoheader.biSizeImage = nBytesWriteLine *  bitmapinfoheader.biHeight;
            bitmapfileheader.bfSize = bitmapfileheader.bfOffBits + bitmapinfoheader.biSizeImage;
            InitPalette();

            for (i = 0; i < bitmapinfoheader.biHeight; ++i)
            {
                nRead = i * m_nBytesPerLine;
                nWrite = i * nBytesWriteLine;
                for (j = 0; j < bitmapinfoheader.biWidth; ++j)
                {
                    nGray = 11 * pbyBuffer[nRead++];
                    nGray += 59 * pbyBuffer[nRead++];
                    nGray += 30 * pbyBuffer[nRead++];
                    nGray /= 100;
                    pbyTmpBuffer[nWrite++] = nGray;
                }
            }
            m_nBytesPerLine = nBytesWriteLine;
            m_nBytesPerPixel = 1;
            memcpy(pbyBuffer, pbyTmpBuffer, bitmapinfoheader.biSizeImage);
        }
        else if (bitmapinfoheader.biBitCount == 8)//灰度化调色板
        {
            for (i = 0; i < MAX_COLORS_PALETTE; ++i)
            {
                nGray = 11 * palette[i].rgbBlue;
                nGray += 59 * palette[i].rgbGreen;
                nGray += 30 * palette[i].rgbRed;
                nGray /= 100;
                palette[i].rgbBlue = palette[i].rgbGreen = palette[i].rgbRed = nGray;
            }
        }

        m_bScale = TRUE;
        m_bHistogram = FALSE;//需要重新计算直方图数组
    }
}

int* CxBitmap::GetHistogram()
{
    if (m_bScale == FALSE)
    {
        ColorToGray();
    }

    if (m_bHistogram)
    {
        return m_pnHistogram;
    }

    if (m_pnHistogram == NULL)
    {
        m_pnHistogram = new int[MAX_COLORS_PALETTE];
        memset(m_pnHistogram, 0, sizeof(int) * MAX_COLORS_PALETTE);
        if (m_pnHistogram == NULL)
        {
            return NULL;
        }
    }

    int nRead = 0;
    int i, j;
    int nAdd = bitmapinfoheader.biBitCount / 8;

    for (i = 0; i < bitmapinfoheader.biHeight; ++i)
    {
        nRead = i * m_nBytesPerLine;
        for (j = 0; j < bitmapinfoheader.biWidth; ++j)
        {
            m_pnHistogram[pbyBuffer[nRead]]++;
            nRead += nAdd;
        }
    }

    m_bHistogram = TRUE;

    return m_pnHistogram;
}

void CxBitmap::DrawHistogram(HDC hDc, const RECT rect)
{
    double fPosX = rect.left;
    double fPosY = rect.top;
    int nWidth = rect.right - rect.left;
    int nHeight = rect.bottom - rect.top;
    int nBegX = nWidth * 0.05;
    int nEndY = nHeight * 0.95;
    double fWidth = 1.0 * (nWidth - nBegX) / MAX_COLORS_PALETTE;
    const int NUM = 100;
    const double ADD = 10 * (1.0 * nHeight) / NUM;
    char szGrade[MAX_PATH];
    int nTmp;
    int i;
    int nMaxCnt = 0;
    int nAddScore = 10;
    int nAddScale = 16;

    if (GetHistogram() == NULL)
    {
        return;
    }

    SetTextAlign(hDc, TA_LEFT);
    SetBkMode(hDc, TRANSPARENT);

    for (i = 0; i < NUM; i += nAddScore)
    {
        sprintf(szGrade, "%d", NUM - i);
        TextOut(hDc, (int)fPosX, (int)fPosY, szGrade, strlen(szGrade));
        fPosY += ADD;
    }

    fPosX = nBegX;
    for (i = 0; i < MAX_COLORS_PALETTE; i += nAddScale)
    {
        sprintf(szGrade, "%d", i);
        TextOut(hDc, (int)fPosX, nEndY, szGrade, strlen(szGrade));
        fPosX += fWidth * nAddScale;
    }
    sprintf(szGrade, "%d", MAX_COLORS_PALETTE - 1);
    TextOut(hDc, (int)fPosX, nHeight, szGrade, strlen(szGrade));

    HBRUSH hOldBrush = (HBRUSH)SelectObject(hDc, GetStockObject(BLACK_BRUSH));
    HPEN hOldPen = (HPEN)SelectObject(hDc, GetStockObject(BLACK_PEN));
    fPosX = rect.left + nBegX;
    fPosY = rect.top;

    for (i = 0; i < MAX_COLORS_PALETTE; ++i)
    {
        if (m_pnHistogram[i] > nMaxCnt)
        {
            nMaxCnt = m_pnHistogram[i];
        }
    }

    for (i = 0; i < MAX_COLORS_PALETTE; ++i)
    {
        nTmp = nHeight * m_pnHistogram[i] / nMaxCnt;
        Rectangle(hDc, (int)fPosX, (int)(fPosY + nEndY - nTmp),
            (int)(fPosX + fWidth), (int)(fPosY + nEndY));
        fPosX += fWidth;
    }
    SelectObject(hDc, hOldBrush);
    SelectObject(hDc, hOldPen);
}

int CxBitmap::GetThreshold(int* pnHistogram)
{
    double fU0, fU1;
    double fW0, fW1;
    int nCount;
    int nT, nMaxT;
    double fDevi, fMaxDevi = 0; //方差及最大方差
    int i;
    int nSum = 0;

    for (i = 0; i < MAX_COLORS_PALETTE; i++)
    {
        nSum += pnHistogram[i];
    }
    for (nT = 0; nT < MAX_COLORS_PALETTE; nT++)
    {
        fU0 = 0;
        nCount = 0;
        //阈值为t时，c0组的均值及产生的概率
        for (i = 0; i <= nT; i++)
        {
            fU0 += i * pnHistogram[i];
            nCount += pnHistogram[i];
        }
        fU0 /= nCount;
        fW0 = 1.0 * nCount / nSum;
        //阈值为t时，c1组的均值及产生的概率
        fU1 = 0;
        for (i = nT + 1; i < MAX_COLORS_PALETTE; i++)
        {
            fU1 += i * pnHistogram[i];
        }
        fU1 /= nSum - nCount;
        fW1 = 1 - fW0;

        //两类间方差
        fDevi = fW0 * fW1 * (fU1 - fU0) * (fU1 - fU0);
        //记录最大的方差及最佳位置
        if (fDevi > fMaxDevi)
        {
            fMaxDevi = fDevi;
            nMaxT = nT;
        }
    }

    return nMaxT;
}

int CxBitmap::GrayToBinary()
{
    if(GetHistogram())
    {
        return GrayToBinary(GetThreshold(m_pnHistogram));
    }

    return FALSE;
}

//二值化
int CxBitmap::GrayToBinary(int nThreshold)
{
    int nRead = 0;

    if (!m_bLoad || !m_bScale)
    {
        return FALSE;
    }

    if (bitmapinfoheader.biBitCount == 24)
    {
        ColorToGray();
    }

    for (int i = 0; i < bitmapinfoheader.biHeight; ++i)
    {
        nRead = i * m_nBytesPerLine;
        for (int j = 0; j < bitmapinfoheader.biWidth; ++j)
        {
            if (pbyBuffer[nRead] >= nThreshold)
            {
                pbyBuffer[nRead] = 255;
            }
            else
            {
                 pbyBuffer[nRead] = 0;
            }

            if (i == 0 || i == bitmapinfoheader.biHeight - 1
                || j == 0 || j == bitmapinfoheader.biWidth - 1)
            {
                pbyBuffer[nRead] = 0;
            }
            nRead++;
        }   
    }
    m_bBinary = TRUE;

    return TRUE;
}

void CxBitmap::Draw(HDC hDc, int nStartX, int nStartY)
{
    if (m_bLoad)
    {
        StretchDIBits(hDc, nStartX, nStartY, bitmapinfoheader.biWidth,
            bitmapinfoheader.biHeight, 0, 0, bitmapinfoheader.biWidth,
            bitmapinfoheader.biHeight, pbyBuffer, (BITMAPINFO*)bitmapinfoheader,
            DIB_RGB_COLORS, SRCCOPY);
    }
}

void CxBitmap::StretchDraw(HDC hDc, int nStartX, int nStartY, int nWidth, int nHeight)
{
    if (m_bLoad)
    {
        StretchDIBits(hDc, nStartX, nStartY, nWidth, nHeight, 0, 0, bitmapinfoheader.biWidth,
            bitmapinfoheader.biHeight, pbyBuffer, (BITMAPINFO*)bitmapinfoheader,
            DIB_RGB_COLORS, SRCCOPY);
    }
}

void CxBitmap::WriteBuffer(char* pszFileName)
{
    if (m_bLoad)
    {
        FILE* fpWrite = fopen(pszFileName, "w");
        int nRead = 0;
        for (int i = 0; i < bitmapinfoheader.biHeight; ++i)
        {
            nRead = i * m_nBytesPerLine;
            for (int j = 0; j < bitmapinfoheader.biWidth; ++j)
            {
                for (int k = 0; k < m_nBytesPerPixel; ++k)
                {
                    fprintf(fpWrite, "%d ", pbyBuffer[nRead]);
                    ++nRead;
                }
            }
            fprintf(fpWrite, "\n");
        }
    }
}

void CxBitmap::SaveFile(char* pszBitmapName)
{
    if (m_bLoad)
    {
        FILE* fpSave = fopen(pszBitmapName, "wb");
        fwrite(bitmapfileheader, sizeof(bitmapfileheader), 1, fpSave);
        fwrite(bitmapinfoheader, sizeof(bitmapinfoheader), 1, fpSave);
        if (bitmapinfoheader.biBitCount == 8)
        {
            fwrite(palette, sizeof(palette), 1, fpSave);
        }
        fwrite(pbyBuffer, bitmapinfoheader.biSizeImage, 1, fpSave);
        fclose(fpSave);
    }
}

int CxBitmap::GetMedian(int* pnArr, int nSize)
{
    int nTime = nSize / 2 + 1;
    int nTemp = 0;

    //下面进行nTime + 1次冒泡排序
    while (nTime)
    {
        nTime--;
        nSize--;
        for (int i = 0; i < nSize; ++i)
        {
            if (pnArr[i] > pnArr[i + 1])
            {
                nTemp = pnArr[i];
                pnArr[i] = pnArr[i + 1];
                pnArr[i + 1] = nTemp;
            }
        }
    }
    return pnArr[nSize + 1];
}

void CxBitmap::MedianFilter()
{
    int nRead = 0;
    int nMedian = 0;
    int nBytePerPixel = bitmapinfoheader.biBitCount / 8;
    int i, j, k, m, n, nCnt;;
    const int FILTEER_SIZE = 3;
    int nTmpArr[FILTEER_SIZE * FILTEER_SIZE];

    if (!m_bLoad)
    {
        return;
    }

    //拷贝边界到临时缓存区
    memcpy(pbyTmpBuffer, pbyBuffer, m_nBytesPerLine);
    memcpy(pbyTmpBuffer, pbyBuffer + (bitmapinfoheader.biHeight - 1) * m_nBytesPerLine,
            m_nBytesPerLine);
    for (i = 0; i < bitmapinfoheader.biHeight; ++i)
    {
        nRead = i * m_nBytesPerLine;
        pbyTmpBuffer[nRead] = pbyBuffer[nRead];
        pbyTmpBuffer[nRead + 1] = pbyBuffer[nRead + 1];
        pbyTmpBuffer[nRead + 2] = pbyBuffer[nRead + 2];

        nRead += nBytePerPixel * (bitmapinfoheader.biWidth - 1); 
        pbyTmpBuffer[nRead] = pbyBuffer[nRead];
        pbyTmpBuffer[nRead + 1] = pbyBuffer[nRead + 1];
        pbyTmpBuffer[nRead + 2] = pbyBuffer[nRead + 2];
    }

    for (i = 1; i < bitmapinfoheader.biHeight - 1; ++i)
    {
        nRead = i * m_nBytesPerLine + nBytePerPixel;
        for (j = 1; j < bitmapinfoheader.biWidth - 1; ++j)
        {
            for (k = 0; k < m_nBytesPerPixel; ++k)
            {
                nCnt = 0;
                nMedian = 0;
                for (m = 0; m < FILTEER_SIZE; ++m)
                {
                    for (n = 0; n < FILTEER_SIZE; ++n)
                    {
                        nTmpArr[nCnt++] =  pbyBuffer[nRead + (m - 1) * m_nBytesPerLine
                            + (n -1) * nBytePerPixel];
                    }
                }
                nMedian = GetMedian(nTmpArr, nCnt);
                pbyTmpBuffer[nRead++] = nMedian;
            }
        }
    }

    m_bBinary = FALSE;//滤波处理之后肯定不是二值图像了
    memcpy(pbyTmpBuffer, pbyTmpBuffer, bitmapinfoheader.biSizeImage);
}

//传入滤波窗口系数和尺寸(nSize*nSize)
void CxBitmap::Filter(double* pfFactors, int nSize, BOOL bAve)
{
    double fMedian = 0;
    int nRead = 0;
    int nRadius = nSize / 2;//滤波窗口的半径
    int nBytePerPixel = bitmapinfoheader.biBitCount / 8;
    int i, j, k, m, n;

    //拷贝边界到临时缓存区
    for (i = 0; i < nRadius; ++i)
    {
        memcpy(pbyTmpBuffer + i * m_nBytesPerLine, pbyBuffer + i * m_nBytesPerLine,
                m_nBytesPerLine);
        memcpy(pbyTmpBuffer + (bitmapinfoheader.biHeight - 1 - i) * m_nBytesPerLine,
                pbyBuffer + (bitmapinfoheader.biHeight - 1 - i) * m_nBytesPerLine,
                m_nBytesPerLine);
    }

    for (i = 0; i < bitmapinfoheader.biHeight; ++i)
    {
        nRead = i * m_nBytesPerLine;
        for (j = 0; j < nRadius; ++j)
        {
            pbyTmpBuffer[nRead] = pbyBuffer[nRead++];
            pbyTmpBuffer[nRead] = pbyBuffer[nRead++];
            pbyTmpBuffer[nRead] = pbyBuffer[nRead++];
        }

        nRead = i * m_nBytesPerLine + nBytePerPixel * (bitmapinfoheader.biWidth - nRadius);
        for (j = 0; j < nRadius; ++j)
        {
            pbyTmpBuffer[nRead] = pbyBuffer[nRead++];
            pbyTmpBuffer[nRead] = pbyBuffer[nRead++];
            pbyTmpBuffer[nRead] = pbyBuffer[nRead++];
        }
    }

    for (i = nRadius; i < bitmapinfoheader.biHeight - nRadius; ++i)
    {
        nRead = i * m_nBytesPerLine + nRadius * nBytePerPixel;
        for (j = nRadius; j < bitmapinfoheader.biWidth - nRadius; ++j)
        {
            for (k = 0; k < m_nBytesPerPixel; ++k)
            {
                fMedian = 0;
                for (m = 0; m < nSize; ++m)
                {
                    for (n = 0; n < nSize; ++n)
                    {
                        fMedian += *(pfFactors + nSize * m + n) * pbyBuffer[nRead 
                            + (m - nRadius) * m_nBytesPerLine + (n - nRadius) * nBytePerPixel];
                    }
                }
                if (bAve)
                {
                    fMedian /= nSize * nSize;
                }
                //assert(nMedian >= 0);
                //注意必须处理变换后不在0-255范围内的像素
                if (fMedian < 0)
                {
                    fMedian = 0;
                }
                if (fMedian > 255)
                {
                    fMedian = 255;
                }
                pbyTmpBuffer[nRead++] = fMedian;
            }
        }
    }

    m_bBinary = FALSE;//滤波处理之后肯定不是二值图像了
    memcpy(pbyBuffer, pbyTmpBuffer, bitmapinfoheader.biSizeImage);
}

//8邻域滤波均值滤波
void CxBitmap::AverageFilter()
{
    const int AVE_NEIGHBOUR_SIZE = 3;
    static double s_fAveFactors[AVE_NEIGHBOUR_SIZE][AVE_NEIGHBOUR_SIZE] =
    {
        {1, 1, 1},
        {1, 1, 1},
        {1, 1, 1},
    };
    assert(m_bLoad);
    if (m_bLoad)
    {
        Filter(s_fAveFactors[0], AVE_NEIGHBOUR_SIZE, TRUE);
    }
}

//拉普拉斯滤波
void CxBitmap::LaplaceFilter()
{
    static double s_flapFactors[NEIGHBOUR_SIZE][NEIGHBOUR_SIZE] =
    {
        {-1, -1, -1},
        {-1,  9, -1},
        {-1, -1, -1},
    };
    assert(m_bLoad);
    if (m_bLoad)
    {
        Filter(s_flapFactors[0], NEIGHBOUR_SIZE, FALSE);
    }
}

//梯度滤波
void CxBitmap::GradientFilterLeft()
{
    const int GRADIENT_NEIGHBOUR_SIZE = 3;
    static double s_fGdFactors[GRADIENT_NEIGHBOUR_SIZE][GRADIENT_NEIGHBOUR_SIZE] =
    {
        {-1, 0, 1},
        {-2, 0, 2},
        {-1, 0, 1}
    };

    assert(m_bLoad);
    if (m_bLoad)
    {
        Filter(s_fGdFactors[0], GRADIENT_NEIGHBOUR_SIZE, FALSE);
    }
}

//梯度滤波
void CxBitmap::GradientFilterRight()
{
    const int GRADIENT_NEIGHBOUR_SIZE = 3;
    static double s_fGdFactors[GRADIENT_NEIGHBOUR_SIZE][GRADIENT_NEIGHBOUR_SIZE] =
    {
        {1, 0, -1},
        {2, 0, -2},
        {1, 0, -1}
    };

    assert(m_bLoad);
    if (m_bLoad)
    {
        Filter(s_fGdFactors[0], GRADIENT_NEIGHBOUR_SIZE, FALSE);
    }
}

//梯度滤波
void CxBitmap::GradientFilterUp()
{
    const int GRADIENT_NEIGHBOUR_SIZE = 3;
    static double s_fGdFactors[GRADIENT_NEIGHBOUR_SIZE][GRADIENT_NEIGHBOUR_SIZE] =
    {
        {1, 2, 1},
        {0, 0, 0},
        {-1, -2, -1},
    };

    assert(m_bLoad);
    if (m_bLoad)
    {
        Filter(s_fGdFactors[0], GRADIENT_NEIGHBOUR_SIZE, FALSE);
    }
}

//梯度滤波
void CxBitmap::GradientFilterDown()
{
    const int GRADIENT_NEIGHBOUR_SIZE = 3;
    static double s_fGdFactors[GRADIENT_NEIGHBOUR_SIZE][GRADIENT_NEIGHBOUR_SIZE] =
    {
        {-1, -2, -1},
        {0, 0, 0},
        {1, 2, 1}
    };

    assert(m_bLoad);
    if (m_bLoad)
    {
        Filter(s_fGdFactors[0], GRADIENT_NEIGHBOUR_SIZE, FALSE);
    }
}

void CxBitmap::GaussFilter(int nRadius)
{
    int nSize = 2 * nRadius + 1;
    int nDis = 0;
    const double SIGMA = 1.5;
    const double A = 2 * SIGMA * SIGMA;
    const double B = 1.0 / (4 * atan(1.0) * A);
    double* pfFactors = new double[nSize * nSize];
    double fTotal = 0.0;
    int i, j;

    for (i = 0; i < nSize; ++i)
    {
        for (j = 0; j < nSize; ++j)
        {
            nDis = (i - nRadius) * (i - nRadius) + (j - nRadius) * (j - nRadius);
            pfFactors[i * nSize + j] = B * exp(-nDis / A);
            fTotal += pfFactors[i * nSize + j];
        }
    }
    for (i = 0; i < nSize; ++i)
    {
        for (j = 0; j < nSize; ++j)
        {
             pfFactors[i * nSize + j]  /= fTotal;
        }
    }

    assert(m_bLoad);
    if (m_bLoad)
    {
        Filter(pfFactors, nSize, FALSE);
    }

    delete [] pfFactors;
}

void CxBitmap::LogTransfer()
{
    const int C = 10;
    int nRead = 0;
    int nScale = 0;

    for (int i = 0; i < bitmapinfoheader.biHeight; ++i)
    {
        nRead = i * m_nBytesPerLine;
        for (int j = 0; j < bitmapinfoheader.biWidth; ++j)
        {
            for (int k = 0; k < m_nBytesPerPixel; ++k)
            {
                nScale = C * log(1 + pbyBuffer[nRead]);
                pbyBuffer[nRead++] = nScale;
            }
        }
    }
}

void CxBitmap::ExpTransfer()
{
    const int C = 10;
    int nRead = 0;
    int nScale = 0;

    for (int i = 0; i < bitmapinfoheader.biHeight; ++i)
    {
        nRead = i * m_nBytesPerLine;
        for (int j = 0; j < bitmapinfoheader.biWidth; ++j)
        {
            for (int k = 0; k < m_nBytesPerPixel; ++k)
            {
                nScale = C * exp(pbyBuffer[nRead]);
                if (nScale > 255)
                {
                    nScale = 255;
                }
                pbyBuffer[nRead++] = nScale;
            }
        }
    }
}

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
                for(iTh = 0; iTh < iThMax; iTh++)
                {
                    iR = (int)(x * cos(iTh * fRate) + y * sin(iTh * fRate));

                    if(iR > 0)
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
        for(iTh = 0; iTh < iThMax; iTh++)
        {
            int iCount = pnArray[iR * iThMax + iTh];
            if(iCount > iMax)
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

extern int Pow2Big(int nA);
int CxBitmap::WriteMeshObj(const char* pcszObjFileName)
{
	int i, j;
	int nPos;
	char szTexFileName[MAX_PATH];
	FILE* fpFile;

	strcpy(szTexFileName, pcszObjFileName);
	strcat(szTexFileName, ".mtl");
	fpFile = fopen(szTexFileName, "w");
	fprintf(fpFile, "newmtl %s.mtl\n", m_szBitmapName);
	fprintf(fpFile, "map_Kd %s\n", m_szBitmapName);
	fclose(fpFile);

	fpFile = fopen(pcszObjFileName, "w");
	if (fpFile == NULL)
	{
		return 0;
	}

	fprintf(fpFile, "mtllib %s\n", szTexFileName);
	//v
	for (i = 0; i < bitmapinfoheader.biHeight; ++i)
	{
		for (j = 0; j < bitmapinfoheader.biWidth; ++j)
		{
			fprintf(fpFile, "v %d %d %d\n", j, i, 0);//v x y z
		}
	}
	//vt(纹理)
	for (i = 0; i < bitmapinfoheader.biHeight; ++i)
	{
		for (j = 0; j < bitmapinfoheader.biWidth; ++j)
		{
			fprintf(fpFile, "vt %f %f 0.0\n", (double)(j + 1) / bitmapinfoheader.biWidth,
				(double)(i + 1) / bitmapinfoheader.biHeight);//vt s t
		}
	}
	fprintf(fpFile, "usemtl %s.mtl\n", m_szBitmapName);
	//f 1//1 2//2 101//101
	for (i = 0; i < bitmapinfoheader.biHeight - 1; ++i)
	{
		for (j = 0; j < bitmapinfoheader.biWidth - 1; ++j)
		{
			nPos = i * bitmapinfoheader.biWidth + j;
			//上三角,面标记为nPos
			fprintf(fpFile, "f %d/%d/ %d/%d/ %d/%d/ %d\n", nPos, nPos,
					nPos + bitmapinfoheader.biWidth, nPos + bitmapinfoheader.biWidth,
					nPos + bitmapinfoheader.biWidth + 1, nPos + bitmapinfoheader.biWidth + 1,
					nPos);
			nPos++;
			//下三角
			fprintf(fpFile, "f %d/%d/ %d/%d/ %d/%d/ %d\n", nPos, nPos, nPos - 1, nPos - 1,
				nPos + bitmapinfoheader.biWidth, nPos + bitmapinfoheader.biWidth, nPos);
		}
	}
	fclose(fpFile);

	return 1;
}
```

下面我再演示一下使用该类得到的一些效果吧。
加载原图的效果，我都是用使用该类加载文件并绘制到指定位置。
![](https://c2.staticflickr.com/8/7430/27379325441_7a1813b273_o.jpg)

下面这张是对一张24位彩色图像灰度化后得到灰度直方图。

![](https://c8.staticflickr.com/8/7215/27379325591_dee18f854e_o.jpg)

对同样的图片进行某个方向梯度变换后的效果如下图，可以看到边缘都增强了。
![](https://c4.staticflickr.com/8/7314/26843672643_53ae21931b_o.jpg)

再下面这张是另外一个实现进行下边缘梯度滤波再hough变换的结果，该实验的目的是检测三角形。
![](https://c8.staticflickr.com/8/7299/26843673903_0af7938b59_o.jpg)