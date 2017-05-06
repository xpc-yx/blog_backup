---
title: Assimp与CGAL的联合使用问题
tags:
  - Assimp
  - cgal
  - 拓扑
id: 957
categories:
  - CGAL
  - 三维模型处理
  - 图形学
date: 2013-11-15 10:44:03
---

 昨天一直在尝试使用assimp导入obj模型，再把数据导入到cgal的Polyhedron_3中。结果发现，所有的模型都是平滑着色的。好奇怪的现象。。。我尝试了很多次修改着色模式，一点反应都没有。我去掉assimp显示就是对的。后面，怀疑到我在cgal中计算顶点法线的过程。果然是这里出问题了。计算顶点法线的过程中基本上只使用了一个邻接面。也就是cgal里面已经没有原有obj模型的拓扑性质了。所以，顶点法线基本上等于面法线了，效果就成了flat着色了。

 这有什么办法了。难道在assimp中计算法线。即使这样，我能够得到正确的顶点法线，但是cgal里面已经没有原有模型的拓扑性质了。我的数据结构还是加载失败的。所以，我不能使用assimp。而且，assimp还不能导入.m模型。虽然，它能导入格式麻烦的obj模型已经很不错了。

 下面是我用assimp加载模型，并且导入到cgal中的代码。

``` stylus
#include <CGAL/Polyhedron_incremental_builder_3.h>
#include "Enriched_polyhedron.h"
#include <vector>
#include <assimp/Importer.hpp>      // C++ importer interface
#include <assimp/scene.h>           // Output data structure
#include <assimp/postprocess.h>     // Post processing flags

template <class HDS>
class Builder_obj : public CGAL::Modifier_base<HDS>
{
private:
	typedef typename HDS::Vertex::Point Point;
	typedef typename CGAL::Polyhedron_incremental_builder_3<HDS> Builder;
	const char* pcszfileName;
	const aiScene* scene;

public:
	Builder_obj(const char* pFilename)
	{
		pcszfileName = pFilename;
	}

	~Builder_obj() {}

	void operator()(HDS hds)
	{
		Builder builder(hds,true);
		builder.begin_surface(3,1,6);

		Assimp::Importer importer;
		scene = importer.ReadFile(pcszfileName,  aiProcessPreset_TargetRealtime_Quality);
		if (!scene) {
			fprintf (stderr, "ERROR: reading mesh %s\n", pcszfileName);
			return;
		}

		for (unsigned int m_i = 0; m_i < scene->mNumMeshes; m_i++)
		{
			const aiMesh* mesh = scene->mMeshes[m_i];

			for (unsigned int v_i = 0; v_i < mesh->mNumVertices; v_i++) 
			{
				if (mesh->HasPositions())
				{
					const aiVector3D* vp = (mesh->mVertices[v_i]);
					printf ("      vp %i (%f,%f,%f)\n", v_i, vp->x, vp->y, vp->z);
					builder.add_vertex(Point(vp->x, vp->y, vp->z));
				}
			}

			for (unsigned int j = 0; j < mesh->mNumFaces; ++j)
			{
				const aiFace face = mesh->mFaces[j];
				assert(face.mNumIndices == 3);

				builder.begin_facet();
				builder.add_vertex_to_facet(face.mIndices[0]);
				builder.add_vertex_to_facet(face.mIndices[1]);
				builder.add_vertex_to_facet(face.mIndices[2]);
				builder.end_facet();
			}

		}

		builder.end_surface();
	}
};

template <class kernel, class items>
class Parser_obj
{
public:
	typedef typename Enriched_Model::HalfedgeDS HalfedgeDS;
	Parser_obj() {}
	~Parser_obj() {}

public:
	bool read(const char*pFilename,
		Enriched_Model *pMesh)
	{
		CGAL_assertion(pMesh != NULL);
		Builder_obj<HalfedgeDS> builder(pFilename);
		pMesh->delegate(builder);
		return true;
	}
};
```

 代码确实非常简洁，但是不能到达要求，又有什么办法了。如果谁有什么解决办法的，欢迎回复啊。。。所以，我打算自己实现一个适用于cgal的导入obj模型（我只导入顶点），.m模型，.off模型等的类吧，以方便以后扩充和重复使用吧。