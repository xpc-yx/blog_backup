---
title: 使用GDI+和CListCtrl实现缩略图控件
tags:
  - CListCtrl
  - GDI+
  - 缩略图控件
id: 900
categories:
  - MFC
  - UI框架
date: 2013-09-12 16:20:04
---

本来这个东西我是用CxImage加载了多种格式的图片，结果今天发现在vs2010的debug模型下有内存溢出，调试了半天才找到是它的原因，所以非常不爽，换了GDI+的实现方法。该控件支持加载多种格式的图片，并且在增加的项内部存储的图片路径。重要的一点是必须在控件的OnDestroy里面释放申请的ItemData，否则退出程序时候还是能检测到内存泄露。这个也是找了半天才找到的。郁闷之。
关于该控件类的具体实现过程，有点复杂。使用到是比较简单，绑定到CListCtrl控件上。用InitCtrl初始化，用AddImage添加。
该类还支持多选和全选，以及删除所有的选择。代码如下：

``` stylus
#pragma once
// CImageListCtrl

class CImageListCtrl : public CListCtrl
{
    DECLARE_DYNAMIC(CImageListCtrl)

public:
    CImageListCtrl();
    virtual ~CImageListCtrl();
    CImageList m_ImageList;
	WCHAR m_char16ImgName[MAX_PATH];

protected:
    DECLARE_MESSAGE_MAP()

public:
	// 添加图片
	int AddImage(CString imgPath);
	void DelImage(CString imgPath);
	void RemoveAllImg(void);
	// 获得当前显示所有图片的路径
	void GetImgPathList(CStringList strListPath);
	BOOL InitCtrl(int nX, int nY);
	void DeleteSelItem(void);

private:
	int m_nX;
	int m_nY;
	int m_nNum;

public:
    afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	afx_msg void OnDestroy();
	afx_msg void OnKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags);
};
```

``` stylus
// ImageListCtrl.cpp : 实现文件
//

#include "stdafx.h"
#include "CxImage/ximage.h"
#include "ImageListCtrl.h"

// CImageListCtrl

IMPLEMENT_DYNAMIC(CImageListCtrl, CListCtrl)

CImageListCtrl::CImageListCtrl()
{
    m_nNum = 0;
}

CImageListCtrl::~CImageListCtrl()
{
    m_ImageList.DeleteImageList();
}

BEGIN_MESSAGE_MAP(CImageListCtrl, CListCtrl)
    ON_WM_CREATE()
    ON_WM_DESTROY()
	ON_WM_KEYDOWN()
END_MESSAGE_MAP()

// CImageListCtrl 消息处理程序

int CImageListCtrl::OnCreate(LPCREATESTRUCT lpCreateStruct)
{
    if (CListCtrl::OnCreate(lpCreateStruct) == -1)
        return -1;

    return 0;
}

BOOL CImageListCtrl::InitCtrl(int nX, int nY)
{
	m_nX = nX;
	m_nY = nY;
	SetExtendedStyle(LVS_EX_FULLROWSELECT | LVS_EX_GRIDLINES);//LVS_EX_CHECKBOXES
	if(!m_ImageList.Create(nX, nY, ILC_COLOR24, 1, 1))
	{
		return FALSE;
	}

	DeleteAllItems();
	m_ImageList.SetBkColor(RGB(125, 125, 0));
	if(SetImageList(m_ImageList, LVSIL_NORMAL) == NULL)
	{
		return FALSE;
	}
	return TRUE;
}

// 添加图片
/*
int CImageListCtrl::AddImage(CString imgPath)
{
	int nEndLen = imgPath.GetLength() - imgPath.ReverseFind('.') - 1;
	CString strEnd = imgPath.Right(nEndLen);
	strEnd.MakeLower();
	if(strEnd.Compare(_T("jpg")) == 0 || strEnd.Compare(_T("gif")) == 0
		|| strEnd.Compare(_T("bmp")) == 0 || strEnd.Compare(_T("png")) == 0
		|| strEnd.Compare(_T("tga")) == 0 || strEnd.Compare(_T("tiff")) == 0
		|| strEnd.Compare(_T("exif")) == 0 || strEnd.Compare(_T("wmf")) == 0
		|| strEnd.Compare(_T("emf")) == 0)
	{
		CxImage image;
		//应用CXImage载入图像，本程序是相对路径
		image.Load(imgPath);
		if (image.IsValid() == false)
		{
			return 0;
		}

		image.Resample(m_nX, m_nY, 2);
		CDC *pDC = GetDC();//应用CXImage在内存中生产位图
		HBITMAP hBit = image.MakeBitmap(pDC->GetSafeHdc());
		CBitmap bmp;
		bmp.Attach(hBit);
		int nResult = m_ImageList.Add(bmp, RGB(255, 255, 255));
		bmp.Detach();
		ReleaseDC(pDC);

		int nIndex = imgPath.ReverseFind(_T('\\'));
		CString strFileName = imgPath.Right(imgPath.GetLength() - (nIndex + 1));
		InsertItem(m_nNum, strFileName, nResult);
		SetItemData(m_nNum, (DWORD_PTR)strdup(imgPath));

		RedrawItems(m_nNum, m_nNum);
		m_nNum++;

		return 1;
	}

	return 0;
}
*/

int CImageListCtrl::AddImage(CString imgPath)
{
	int nEndLen = imgPath.GetLength() - imgPath.ReverseFind('.') - 1;
	CString strEnd = imgPath.Right(nEndLen);
	strEnd.MakeLower();
	if(strEnd.Compare(_T("jpg")) == 0 || strEnd.Compare(_T("gif")) == 0
		|| strEnd.Compare(_T("bmp")) == 0 || strEnd.Compare(_T("png")) == 0
		|| strEnd.Compare(_T("tga")) == 0 || strEnd.Compare(_T("tiff")) == 0
		|| strEnd.Compare(_T("exif")) == 0 || strEnd.Compare(_T("wmf")) == 0
		|| strEnd.Compare(_T("emf")) == 0)
	{
		int nStrLen = imgPath.GetLength();
		char* pCharBuf = imgPath.GetBuffer(0);
		imgPath.ReleaseBuffer();
		int nLen = MultiByteToWideChar(CP_ACP, 0, pCharBuf, nStrLen, NULL, 0);
		MultiByteToWideChar(CP_ACP, 0, pCharBuf, nStrLen, m_char16ImgName, nLen);
		m_char16ImgName[nLen] = '\0'; //添加字符串结尾，注意不是len+1

		Gdiplus::Bitmap* pImage = new Gdiplus::Bitmap(m_char16ImgName, true);
		if (pImage == NULL)
		{
			return 0;
		}
		Gdiplus::Bitmap* pThumbnail = (Gdiplus::Bitmap*)pImage->GetThumbnailImage(m_nX, m_nY);
		HBITMAP hBmp;
		pThumbnail->GetHBITMAP(Gdiplus::Color(255, 255, 255), hBmp);

		CBitmap bmp;
		bmp.Attach(hBmp);
		int nResult = m_ImageList.Add(bmp, RGB(255, 255, 255));
		bmp.Detach();
		int nIndex = imgPath.ReverseFind(_T('\\'));
		CString strFileName = imgPath.Right(imgPath.GetLength() - (nIndex + 1));

		InsertItem(m_nNum, strFileName, nResult);
		SetItemData(m_nNum, (DWORD_PTR)strdup(imgPath));
		RedrawItems(m_nNum, m_nNum);

		delete pThumbnail;
		delete pImage;
		m_nNum++;

		return 1;
	}

	return 0;
}

void CImageListCtrl::DelImage(CString imgPath)
{
    int nCount = GetItemCount();
    for (int i = 0; i < nCount; i++)
    {
        char *pData = (char *)GetItemData(i);
        if(pData != NULL)
        {
            CString str;
            str.Format(_T("%s"), pData);
            str = str.Trim();
            if(str.CompareNoCase(imgPath) == 0)
            {
                free(pData);
                DeleteItem(i);
				break;
            }
        }
    }
}

void CImageListCtrl::RemoveAllImg(void)
{
    int nCount = GetItemCount();
    for (int i=0;i<nCount;i++)
    {
        char *pData = (char *)GetItemData(i);
        if(pData!=NULL)
            free(pData);
    }
    DeleteAllItems();
    m_nNum = 0;
}

// 获得当前显示所有图片的路径
void CImageListCtrl::GetImgPathList(CStringList strListPath)
{
    int nCount = GetItemCount();
    strListPath.RemoveAll();
    for (int i=0;i<nCount;i++)
    {
        char *pData = (char *)GetItemData(i);
        if(pData!=NULL)
        {
            CString str;
            str.Format(_T("%s"),pData);
            str = str.Trim();
            strListPath.AddTail(str);
        }
    }
}

void CImageListCtrl::OnDestroy()
{
	int nCnt = GetItemCount();
	for (int i = 0; i < nCnt; i++)
	{
		char *pData = (char *)GetItemData(i);
		if (pData)
		{
			delete [] pData;
		}
	}

    CListCtrl::OnDestroy();
}

//删除所有选中的项
void CImageListCtrl::DeleteSelItem(void)
{
	POSITION pos = GetFirstSelectedItemPosition();
	while(pos != NULL)
	{
		int nItem = GetNextSelectedItem(pos);
		TRACE1("Item %d was selected!\n", nItem);

		char *pData = (char *)GetItemData(nItem);
		if(pData != NULL)
		{
			free(pData);
		}

		DeleteItem(nItem);
		pos = GetFirstSelectedItemPosition();
		--m_nNum;
	}

	Arrange(LVA_ALIGNLEFT);
}

void CImageListCtrl::OnKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags)
{
	// TODO: 在此添加消息处理程序代码和/或调用默认值
	if (nChar == VK_DELETE)
	{
		DeleteSelItem();
	}
	else if ((nChar == 'a' || nChar == 'A')  GetKeyState(VK_CONTROL))
	{
		for (int i = m_nNum - 1; i >= 0; --i)
		{
			SetItemState(i, LVIS_SELECTED, LVIS_SELECTED);
		}
	}

	CListCtrl::OnKeyDown(nChar, nRepCnt, nFlags);
}
```

实现效果如图：
[![](https://c2.staticflickr.com/8/7371/26844072333_a9a690360a_o.png)](https://c2.staticflickr.com/8/7371/26844072333_a9a690360a_o.png)
关于MFC方面的问题，欢迎加群：87236798交流。