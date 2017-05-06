---
title: 使用VB.NET操作二进制文件以序列化对象集合
tags:
  - BinaryReader
  - BinaryWriter
  - VB.NET
  - 二进制文件
id: 831
categories:
  - .NET
date: 2013-06-05 09:09:04
---

如果是用c，c++这当然是相当熟悉的操作了，也不需要做个记录了。但是现在用的是vs2010版本的vb.net。而现在我有一个大对象，里面存储了整形，浮点，字符串，还有图片。我想将数据归档到文件里面，还有从文件中恢复出来。所以，只能使用二进制的读写方法，顺便记录图片的长度。至于要不要记录字符串的长度，只能问VB.NET了。
读取文件的使用BinaryReader，写文件的使用BinaryWriter。这2个对.net的string也支持二进制读写，所以只需要存储图片的长度了。图片本身当做byte[]存储。这2个类在Imports System.IO空间，都需要从FileStream创建。
虽说对VB.NET不熟悉，但是实现之后还是发现这个东西很好用的。以后还可以用来参考下。

存储的对象的类定义如下，
``` stylus
Imports System.IO

Public Class Project

    '建筑，供水，供电，结构，供暖，环境
    Public oldValueFactor(0 To 5) As Double
    Public oldValue(0 To 5) As Integer
    Public newValueFactor(0 To 5) As Double
    Public newValue(0 To 5) As Integer

    Public idLen As Integer
    Public id As String
    Public nameLen As Integer
    Public name As String
    Public placeLen As Integer
    Public place As String
    Public situationLen As Integer
    Public situation As String

    Public oldTotal As Integer  '总分
    Public newTotal As Integer

    Public oldLen As Integer
    Public oldPic() As Byte
    Public newLen As Integer
    Public newPic() As Byte '图片

    Public Sub New()
        oldLen = 0
        newLen = 0
        Dim j As Integer
        For j = 0 To 5
            oldValueFactor(j) = New Double()
            oldValue(j) = New Double()
            newValueFactor(j) = New Double()
            newValue(j) = New Double()
        Next
    End Sub

End Class
```

对象类的集合类定义如下。该类支持归档到文件，从文件恢复，查找，添加，删除操作。
``` stylus
Imports System.IO

Public Class ProjectSet
    Public nNum As Integer
    '1000000
    Public pros(0 To 100000) As Project

    Public Sub New()
        nNum = 0
    End Sub

    Public Sub LoadFromFile(ByVal fileName As String)

        Dim Stream As FileStream
        Dim BinaryStreamReader As BinaryReader
        Try
            Stream = New FileStream(fileName, FileMode.Open)
            BinaryStreamReader = New BinaryReader(Stream)
            nNum = BinaryStreamReader.ReadInt32()
        Catch E As Exception
            Return
        End Try

        Dim i As Integer
        For i = 0 To nNum - 1
            pros(i) = New Project
            Dim j As Integer
            For j = 0 To 5
                pros(i).oldValueFactor(j) = BinaryStreamReader.ReadDouble()
                pros(i).oldValue(j) = BinaryStreamReader.ReadInt32()
                pros(i).newValueFactor(j) = BinaryStreamReader.ReadDouble()
                pros(i).newValue(j) = BinaryStreamReader.ReadInt32()
            Next

            pros(i).id = BinaryStreamReader.ReadString()
            pros(i).name = BinaryStreamReader.ReadString()
            pros(i).place = BinaryStreamReader.ReadString()
            pros(i).situation = BinaryStreamReader.ReadString()

            pros(i).oldTotal = BinaryStreamReader.ReadInt32()
            pros(i).newTotal = BinaryStreamReader.ReadInt32()

            pros(i).oldLen = BinaryStreamReader.ReadInt32()
            pros(i).oldPic = BinaryStreamReader.ReadBytes(pros(i).oldLen)

            pros(i).newLen = BinaryStreamReader.ReadInt32()
            pros(i).newPic = BinaryStreamReader.ReadBytes(pros(i).newLen)

        Next

        BinaryStreamReader.Close()
        Stream.Close()
    End Sub

    Public Sub SaveToFile(ByVal fileName As String)

        Dim Stream = New FileStream(fileName, FileMode.Create)
        Dim BinaryStream As New BinaryWriter(Stream)

        BinaryStream.Write(nNum)

        Dim i As Integer
        For i = 0 To nNum - 1

            Dim j As Integer
            For j = 0 To 5
                BinaryStream.Write(pros(i).oldValueFactor(j))
                BinaryStream.Write(pros(i).oldValue(j))
                BinaryStream.Write(pros(i).newValueFactor(j))
                BinaryStream.Write(pros(i).newValue(j))
            Next

            BinaryStream.Write(pros(i).id)
            BinaryStream.Write(pros(i).name)
            BinaryStream.Write(pros(i).place)
            BinaryStream.Write(pros(i).situation)

            BinaryStream.Write(pros(i).oldTotal)
            BinaryStream.Write(pros(i).newTotal)
            BinaryStream.Write(pros(i).oldLen)
            BinaryStream.Write(pros(i).oldPic)
            BinaryStream.Write(pros(i).newLen)
            BinaryStream.Write(pros(i).newPic)

        Next

        BinaryStream.Close()
        Stream.Close()

    End Sub

    Public Sub AddProject(ByVal project As Project)
        pros(nNum) = project
        nNum += 1
    End Sub

    Public Sub DeleteProject(ByVal nIndex As Integer)

        Dim i As Integer
        For i = nIndex To nNum - 2
            pros(i) = pros(i + 1)
        Next

        nNum -= 1

    End Sub

    Public Function FindProject(ByVal id As String) As Integer

        Dim i As Integer
        For i = 0 To nNum - 1
            If id = pros(i).id Then
                Return i
            End If
        Next
        Return -1

    End Function

End Class
```
上面的集合类里面定义了个大数组，是因为我对.NET不熟悉，不知道这样的对象数组定义，产生的是对象集合，还是虚的引用集合。我觉得是引用集合就不用声明数据的大小了吧，结果还是需要声明。而且，读取文件的时候还需要给每个数据项new一个Project。反正不清楚为什么是这样的原因，因为对.NET真的一点不熟悉。