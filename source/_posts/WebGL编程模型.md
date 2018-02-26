---
title: WebGL编程模型
tags:
  - WebGL
id: 2155
categories:
  - 图形学
  - WebGL
date: 2016-12-25 18:16:11
---

本文主要介绍编写一个原生的WebGL程序需要哪些步骤。

# WebGL程序的软件结构

默认情况下，一个动态网页程序只包括HTML和JavaScript两种语言。
而在WebGL程序中，还包括了第三种语言：GLSL ES。

![enter description here](https://c1.staticflickr.com/1/417/31743655591_e5815e1579_o.png)

# WebGL编程模型

![enter description here](https://c1.staticflickr.com/1/502/31050538443_ca9377f3a2_o.png)
上图表示一个WebGL程序运行的主要流程。主要分为3个阶段，应用程序阶段、着色器阶段、片元后处理阶段。
本文接下来按照一定的规律介绍编写一个原生WebGL程序主要的步骤。

## 获得WebGL渲染环境

### 在Html中定义canvas标签

``` stylus
<canvas id="webgl" width="400" height="400"> </canvas>
```

### 在JS代码中获得canvas对象

``` stylus
var canvas = document.getElementById('webgl');
```
### 通过canvas对象获得WebGL渲染环境

``` stylus
var gl = getWebGLContext(canvas);
```

## 编写着色器

### 编写顶点着色器

顶点着色器是用来描述顶点属性（比如位置、颜色、纹理坐标等的程序）
![enter description here](https://c1.staticflickr.com/1/441/31822594876_583f762171_o.png)

### 编写片元着色器

片元着色器处理光栅后的数据，可以片元将其理解为像素。
片元着色器的输出构成了最终的像素值（开启多重采样的话只构成了某个像素的一部分值）
![enter description here](https://c1.staticflickr.com/1/771/31822601086_e8b7848d25_o.png)

## 初始化着色器

初始化着色器基本上是一个固定的流程，主要分为以下几个步骤。

### 创建shader

### 加载shader源码

### 编译shader

### 创建程序

### 附加编译好的shader

### 链接程序

### 使用程序

## 获得顶点属性

顶点上有各种属性，比如空间坐标、纹理坐标、材质等，一个顶点就是一个属性集合。
如下图所示的立方体，顶点上有2个属性，坐标和颜色。
![enter description here](https://c1.staticflickr.com/1/280/31487505630_7c7a69ed2f_o.png)
顶点属性可以通过读取模型文件，比如obj文件等获得，或者简单写在代码定义中，比如上图的立方体。

## 创建顶点缓冲区

缓冲区存在于显存中，能够被显卡直接用来进行渲染，不需要进行数据传输。
在WebGL中，通过以下调用获得一个缓冲区对象。

``` cpp
var vertexColorBuffer = gl.createBuffer();
```

## 写入顶点数据到顶点缓冲区对象

这个步骤分为两个操作。

### 首先，绑定创建的缓冲区
``` cpp
gl.bindBuffer(gl.ARRAY_BUFFER, vertexColorBuffer);
```

### 然后，传输系统内存中上的顶点数据到缓冲区（显存中）
``` cpp
gl.bufferData(gl.ARRAY_BUFFER, verticesColors, gl.STATIC_DRAW);
```
### 传输数据的标志

gl.bufferData的第三个参数表示数据的使用标志，表示三种不同的应用场景。
1\. gl.STATIC_DRAW ：表示数据不会经常改变，通常用于静态物体，比如地形、墙体等。
2\. gl.STREAM_DRAW：表示数据使用一次后就会被丢弃。
3\. gl.DYNAMIC_DRAW：表示数据会被多次修改，也会被使用多次。

系统会根据usage标示符为缓冲区对象分配最佳的存储位置。
STATIC_DRAW和STREAM_DRAW分配在显存上，DYNAMIC_DRAW可能分配在AGP中。

## 将顶点数据传输到顶点着色器

目前，我们已经准会了WebGL渲染环境，并且数据已经从系统内存传输到显存中的缓冲区对象中。现在，我们要将缓存区对象中的数据指定给顶点着色器中对应的变量。
顶点着色器中的attribute变量对象顶点的属性。我们的顶点着色器中定义了2个变量，a_Position，a_Color。下面我们分为三步为这其指定数据。

1.  获得着色器中attribute变量位置
``` cpp
var a_Position = gl.getAttribLocation(gl.program, 'a_Position');
```
2.  根据变量位置传入缓冲区中的顶点属性数组
``` cpp
gl.vertexAttribPointer(a_Position, 3, gl.FLOAT, false, FSIZE * 6, 0);
```

3.  启用该attribute变量的属性数组
``` cpp
gl.enableVertexAttribArray(a_Position);
```

对于a_Color，我们在系统内存中定义在坐标的后面，因此在第2步中需要进行**偏移**，gl.vertexAttribPointer的最后一个参数可以指定数据的偏移位置，因此第2步修改为：
``` cpp
gl.vertexAttribPointer(a_Position, 3, gl.FLOAT, false, FSIZE * 6, FSIZE * 3);
```
FSIZE表示float的大小。

## 传入uniform变量到着色器

着色器中还存在一种uniform变量，这种变量对于所有顶点来说都是一样的。
比如，mvp矩阵就应该定义为uniform变量。一般情况，我们在js代码中计算好mvp矩阵，然后传输到着色器中的uniform变量中。主要步骤如下：
1\. 获取uniform变量的在着色中的位置
``` cpp
var u_MvpMatrix = gl.getUniformLocation(gl.program, 'u_MvpMatrix');
```

1.  计算uniform变量（比如mvp矩阵）的值

``` cpp
var mvpMatrix = new Matrix4();
mvpMatrix.setPerspective(30, 1, 1, 100);
mvpMatrix.lookAt(3, 3, 7, 0, 0, 0, 0, 1, 0);
```

1.  传入uniform变量

``` cpp
gl.uniformMatrix4fv(u_MvpMatrix, false, mvpMatrix.elements);
```

目前，顶点着色器已经有了每个顶点的属性，以及用uniform变量表示的mvp矩阵，因此可以变换顶点属性后传入片元着色器中进一步处理。

## 定义面片索引

上面我们处理的数据都是顶点属性，但是我们实际要绘制的图元是面片，比如三角面片。
通常情况下，我们会用三个顶点索引表示一个三角面片。
如下所示：

``` cpp
// Indices of the vertices
var indices = new Uint8Array([
0, 1, 2, 0, 2, 3, // front
0, 3, 4, 0, 4, 5, // right
0, 5, 6, 0, 6, 1, // up
1, 6, 7, 1, 7, 2, // left
7, 4, 3, 7, 3, 2, // down
4, 7, 6, 4, 6, 5 // back
]);

```

indices表示一个立方体的面片索引。

## 创建索引缓冲区，写入索引

接下来，我们要创建索引缓冲区，并将内存中的索引数据传入缓存区。
1\. 创建索引缓冲区

``` cpp
var indexBuffer = gl.createBuffer();
```

1.  绑定索引缓冲区

``` cpp
gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
```

1.  将面片索引写入缓冲区对象

``` cpp
gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, indices, gl.STATIC_DRAW);
```

## 根据索引绘制图元

最后一步只需要根据面片索引绘制图元即可。
根据面片的顶点索引绘制图元节省内存，不需要存储重复的顶点数据。
我们只需要调用gl.drawElements即可。

``` cpp
gl.drawElements(gl.TRIANGLES, n, gl.UNSIGNED_BYTE, 0);
```

其中，第二个参数n表示要绘制的图元（三角形面片）个数。最后一个参数0表示使用已经绑定好的索引缓冲区对象。

## 完整代码

下面给出绘制一个彩色立方体的完整代码。

``` cpp
// Vertex shader program
var VSHADER_SOURCE =
'attribute vec4 a_Position;\n' +
'attribute vec4 a_Color;\n' +
'uniform mat4 u_MvpMatrix;\n' +
'varying vec4 v_Color;\n' +
'void main() {\n' +
' gl_Position = u_MvpMatrix * a_Position;\n' +
' v_Color = a_Color;\n' +
'}\n';

// Fragment shader program
var FSHADER_SOURCE =
'#ifdef GL_ES\n' +
'precision mediump float;\n' +
'#endif\n' +
'varying vec4 v_Color;\n' +
'void main() {\n' +
' gl_FragColor = v_Color;\n' +
'}\n';

function main() {
// Retrieve <canvas> element
var canvas = document.getElementById('webgl');

// Get the rendering context for WebGL
var gl = getWebGLContext(canvas);
if (!gl) {
console.log('Failed to get the rendering context for WebGL');
return;
}

// Initialize shaders
if (!initShaders(gl, VSHADER_SOURCE, FSHADER_SOURCE)) {
console.log('Failed to intialize shaders.');
return;
}

// Set the vertex coordinates and color
var n = initVertexBuffers(gl);
if (n < 0) {
console.log('Failed to set the vertex information');
return;
}

// Set clear color and enable hidden surface removal
gl.clearColor(0.0, 0.0, 0.0, 1.0);
gl.enable(gl.DEPTH_TEST);

// Get the storage location of u_MvpMatrix
var u_MvpMatrix = gl.getUniformLocation(gl.program, 'u_MvpMatrix');
if (!u_MvpMatrix) {
console.log('Failed to get the storage location of u_MvpMatrix');
return;
}

// Set the eye point and the viewing volume
var mvpMatrix = new Matrix4();
mvpMatrix.setPerspective(30, 1, 1, 100);
mvpMatrix.lookAt(3, 3, 7, 0, 0, 0, 0, 1, 0);

// Pass the model view projection matrix to u_MvpMatrix
gl.uniformMatrix4fv(u_MvpMatrix, false, mvpMatrix.elements);

// Clear color and depth buffer
gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

// Draw the cube
gl.drawElements(gl.TRIANGLES, n, gl.UNSIGNED_BYTE, 0);
}

function initVertexBuffers(gl) {
// Create a cube
// v6----- v5
// /| /|
// v1------v0|
// | | | |
// | |v7---|-|v4
// |/ |/
// v2------v3
var verticesColors = new Float32Array([
// Vertex coordinates and color
1.0, 1.0, 1.0, 1.0, 1.0, 1.0, // v0 White
-1.0, 1.0, 1.0, 1.0, 0.0, 1.0, // v1 Magenta
-1.0, -1.0, 1.0, 1.0, 0.0, 0.0, // v2 Red
1.0, -1.0, 1.0, 1.0, 1.0, 0.0, // v3 Yellow
1.0, -1.0, -1.0, 0.0, 1.0, 0.0, // v4 Green
1.0, 1.0, -1.0, 0.0, 1.0, 1.0, // v5 Cyan
-1.0, 1.0, -1.0, 0.0, 0.0, 1.0, // v6 Blue
-1.0, -1.0, -1.0, 0.0, 0.0, 0.0 // v7 Black
]);

// Indices of the vertices
var indices = new Uint8Array([
0, 1, 2, 0, 2, 3, // front
0, 3, 4, 0, 4, 5, // right
0, 5, 6, 0, 6, 1, // up
1, 6, 7, 1, 7, 2, // left
7, 4, 3, 7, 3, 2, // down
4, 7, 6, 4, 6, 5 // back
]);

// Create a buffer object
var vertexColorBuffer = gl.createBuffer();
var indexBuffer = gl.createBuffer();
if (!vertexColorBuffer || !indexBuffer) {
return -1;
}

// Write the vertex coordinates and color to the buffer object
gl.bindBuffer(gl.ARRAY_BUFFER, vertexColorBuffer);
gl.bufferData(gl.ARRAY_BUFFER, verticesColors, gl.STATIC_DRAW);

var FSIZE = verticesColors.BYTES_PER_ELEMENT;
// Assign the buffer object to a_Position and enable the assignment
var a_Position = gl.getAttribLocation(gl.program, 'a_Position');
if(a_Position < 0) {
console.log('Failed to get the storage location of a_Position');
return -1;
}
gl.vertexAttribPointer(a_Position, 3, gl.FLOAT, false, FSIZE * 6, 0);
gl.enableVertexAttribArray(a_Position);
// Assign the buffer object to a_Color and enable the assignment
var a_Color = gl.getAttribLocation(gl.program, 'a_Color');
if(a_Color < 0) {
console.log('Failed to get the storage location of a_Color');
return -1;
}
gl.vertexAttribPointer(a_Color, 3, gl.FLOAT, false, FSIZE * 6, FSIZE * 3);
gl.enableVertexAttribArray(a_Color);

// Write the indices to the buffer object
gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, indices, gl.STATIC_DRAW);

return indices.length;
}

```

上面代码中使用到的创建WebGL渲染环境、初始化着色器、创建矩阵的操作，读者可以自行找相应的代码库替代。
或者在下面的链接中下载：
[WebGL Lib](http://pan.baidu.com/s/1mhVH5Ba)， 密码：tncd。