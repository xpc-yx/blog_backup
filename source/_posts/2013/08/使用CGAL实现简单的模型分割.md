---
title: 使用CGAL实现简单的模型分割
tags:
  - cgal
  - 分割模型
  - 模型编辑
  - 欧拉操作
id: 869
categories:
  - CGAL
  - 三维模型处理
date: 2013-08-05 22:00:43
---

第一步，先把鼠标轨迹点**逆投影**到三维世界的观察坐标系。
第二步，把第一步获得的三维坐标点集合**投射到模型上面**，获得笔画，就是模型内部的一些相互连接的边。
第三步，沿着第二步获得那些相互连接的边进行**欧拉操作分裂边**。可能需要多分割几次才会分割出模型的一部分。
第四步，**搜索整个模型，对不同的部分进行标记**。

下面是实现的一些效果。绿色线是鼠标轨迹，红色线是投影到模型上面的边的连接线。

![](https://c2.staticflickr.com/8/7641/27451248125_5ea8669c0c_o.png)

![](https://c2.staticflickr.com/8/7046/27417002526_77b7704140_o.png)

![](https://c2.staticflickr.com/8/7021/27174724330_dab475eef1_o.png)
下面具体解释下以上几个步骤。
步骤一，比较简单，网上代码一堆，不过要自己注意理解。

``` stylus
            glGetIntegerv(GL_VIEWPORT, m_nViewPort);
            glGetDoublev(GL_PROJECTION_MATRIX, m_fProjmatrix);
            glGetDoublev(GL_MODELVIEW_MATRIX, m_fMvmatrix);

            float fWinX, fWinY, fWinZ;
            int nX, nY;
            double fX, fY, fZ;

            m_pt3ds.clear();
            for (int i = 0; i < m_ptStroke.size(); ++i)
            {
                nX = m_ptStroke[i].x;
                nY = m_nViewPort[3] - m_ptStroke[i].y - 1;
                glReadBuffer(GL_BACK);
                glReadPixels(nX, nY, 1, 1, GL_DEPTH_COMPONENT, GL_FLOAT, fWinZ);
                //if (fabs(fWinZ - 1.0) > 1e-8)
                {
                    fWinX = nX;
                    fWinY = nY;
                    gluUnProject(fWinX, fWinY, fWinZ, m_fMvmatrix, m_fProjmatrix, m_nViewPort,
                        fX, fY, fZ);
                    m_pt3ds.push_back(Point_3(fX, fY, fZ));
                }
            }
            m_ptStroke.clear();
```

该代码就是把m_ptStroke的点转化为观察坐标系的点m_pt3ds。
步骤二，大致思路如下：第一步，把所有鼠标经过的点，都投影回观察空间。第二步，找到离第一个鼠标点p[0]，最近的模型内的顶点pClosed。第三步，循环剩余的鼠标点，如果当前鼠标点离pClosed的相邻顶点更近的话，那么将pClosed更新为上一次找到的pClosed的相邻顶点。所有的这些，pClosed点就是笔画的投影点。

``` stylus
        FILE* fpLog = fopen("log.txt", "w");
        char szStr[MAX_PATH];
        CString str;
        str.Format("%d", pt3ds.size());
        //AfxMessageBox(str);
        sprintf(szStr, "pt3ds.size():%d\n", pt3ds.size());
        fprintf(fpLog, "%s", szStr);

        if (pt3ds.size() == 0)
        {
            return;
        }

        double fX = CGAL::to_double(pt3ds[0].x());
        double fY = CGAL::to_double(pt3ds[0].y());
        double fZ = CGAL::to_double(pt3ds[0].z());
        double fX1, fY1, fZ1;

        //获得离第一个投影点最近的halfedge_handle
        Halfedge_handle heClosed = facets_begin()->halfedge();
        double fDiff = 1e10;
        for(Face_iterator pf = facets_begin();
            pf != facets_end(); pf++)
        {
            Halfedge_handle he = pf->halfedge();

            do
            {
                Point_3 p = he->vertex()->point();
                fX1 = CGAL::to_double(p.x());
                fY1 = CGAL::to_double(p.y());
                fZ1 = CGAL::to_double(p.z());
                double fTemp = (fX1 - fX) * (fX1 - fX) + (fY1 - fY) * (fY1 - fY)
                    + (fZ1 - fZ) * (fZ1 - fZ);
                if (fTemp < fDiff)
                {
                    fDiff = fTemp;
                    heClosed = he;
                }
                he = he->next();
            }while(he!= pf->halfedge());
        }

        vector<Halfedge_handle> vh;
        vh.push_back(heClosed);
        for (unsigned i = 1; i < pt3ds.size(); ++i)
        {
            sprintf(szStr, "处理第:%d个笔画点\n", i);
            fprintf(fpLog, szStr);

            fX = CGAL::to_double(pt3ds[i].x());
            fY = CGAL::to_double(pt3ds[i].y());
            fZ = CGAL::to_double(pt3ds[i].z());
            sprintf(szStr, "笔画点坐标为:%f,%f,%f\n", fX, fY, fZ);
            fprintf(fpLog, szStr);

            Halfedge_handle next = heClosed;
            Point_3 p = heClosed->vertex()->point();

            fX1 = CGAL::to_double(p.x());
            fY1 = CGAL::to_double(p.y());
            fZ1 = CGAL::to_double(p.z());
            sprintf(szStr, "heClosed坐标为:%f,%f,%f\n", fX1, fY1, fZ1);
            fprintf(fpLog, szStr);

            fDiff = (fX1 - fX) * (fX1 - fX) + (fY1 - fY) * (fY1 - fY)
                + (fZ1 - fZ) * (fZ1 - fZ);

            Vertex_handle v = heClosed->vertex();
            Halfedge_around_vertex_circulator he, end;
            he = end = v->vertex_begin();
            CGAL_For_all(he, end)
            {
                Halfedge_handle heTemp = he->opposite();
                p = heTemp->vertex()->point();
                fX1 = CGAL::to_double(p.x());
                fY1 = CGAL::to_double(p.y());
                fZ1 = CGAL::to_double(p.z());

                double fTemp = (fX1 - fX) * (fX1 - fX) + (fY1 - fY) * (fY1 - fY)
                    + (fZ1 - fZ) * (fZ1 - fZ);

                if (fTemp < fDiff  heClosed != he)
                {
                    sprintf(szStr, "heTemp坐标为:%f,%f,%f\n", fX1, fY1, fZ1);
                    fprintf(fpLog, szStr);

                    sprintf(szStr, "fDiff:%f,fTemp:%f\n", fDiff, fTemp);
                    fprintf(fpLog, szStr);

                    if (std::find(vh.begin(), vh.end(), heTemp) != vh.end())
                    {
                        continue;
                    }

                    //if (vh.size() != 1  heClosed->facet() == heTemp->facet())
                    {
                    //  continue;
                    }
                    fDiff = fTemp;
                    next = heTemp;
                    //sprintf(szStr, "next坐标为:%f,%f,%f\n", fX1, fY1, fZ1);
                    //fprintf(fpLog, szStr);
                }
            }

            //去掉已经出现过的顶点
            if (next != heClosed)
            {
                heClosed = next;
                vh.push_back(heClosed);
            }
        }

        glDisable(GL_LIGHTING);
        glDisable(GL_DEPTH_TEST);
        glColor3f(1.0, 0.0, 0.0);
        glLineWidth(3.0);
        glBegin(GL_LINE_STRIP);
        for (int i = 0; i < vh.size(); ++i)
        {
            glVertex3d(CGAL::to_double(vh[i]->vertex()->point().x()),
                CGAL::to_double(vh[i]->vertex()->point().y()),
                CGAL::to_double(vh[i]->vertex()->point().z()));
            sprintf(szStr, "i:%d, x:%f,y:%f,z:%f\n", i,
                CGAL::to_double(vh[i]->vertex()->point().x()),
                CGAL::to_double(vh[i]->vertex()->point().y()),
                CGAL::to_double(vh[i]->vertex()->point().z()));
            fprintf(fpLog, szStr);
        }
        glEnd();
        glFlush();
```

步骤三是欧拉操作。我的思路是将经过的边都变成边界边，方便第四步的搜索。首先，split_edge。然后，把沿着边的相邻的两个面沿着原来的边split_facet，再删除多余的面。那么，该经过的边就会变成边界边。代码如下：

``` stylus
        for (int i = 1; i < vh.size(); ++i)
        {
            Halfedge_handle hBegOne = vh[i]->next()->next();
            fprintf(fpLog ,"处理i:%d\n", i);
            split_edge(vh[i]);

            Halfedge_handle hBegTwo = vh[i]->opposite()->next();
            Halfedge_handle hEndOne = vh[i];
            Halfedge_handle hEndTwo = hBegTwo->next()->next();
            split_facet(hBegOne, hEndOne);
            split_facet(hBegTwo, hEndTwo);
            erase_facet(hEndOne);
            erase_facet(hBegTwo);
            fprintf(fpLog, "is border:%d\n", hBegOne->next()->is_border_edge());
        }
```

步骤五，对整个模型的面进行dfs即可了。代码如下：

``` stylus
    void SetComponent()
    {
        for (Facet_iterator i = facets_begin(); i != facets_end(); ++i)
        {
            i->component(-1);
        }

        int nComponent = 1;
        for (Facet_iterator i = facets_begin(); i != facets_end(); ++i)
        {
            if (i->component() == -1)
            {
                DfsComponent(i, nComponent);
                nComponent++;
            }

        }

    }

    void DfsComponent(Facet_iterator i, int nComponent)
    {
        CString str;
        str.Format("处理第:%d个面", i->tag());
        //AfxMessageBox(str);
        i->component(nComponent);

        Halfedge_around_facet_circulator  j = i->facet_begin();

        do {
            Halfedge_handle hfTemp = j;
            if (hfTemp->is_border_edge())
            {
                //AfxMessageBox("找到边界边");
                continue;
            }
            Halfedge_handle hf = j->opposite();
            Facet_handle fh = hf->facet();

            if (fh->component() == -1)
            {
                DfsComponent(fh, nComponent);
            }
        } while ( ++j != i->facet_begin());

    }
```

因为每个面里面都有个代表属于哪个组件的标记，这样就实现了模型的分割。利用该方法就能实现分割出狗的腿和头部等等。

代码分享链接：链接: http://pan.baidu.com/s/1eQ50rf0 密码: 7f6v