---
title: CTex下如何使Beamer支持中文
id: 1718
categories:
  - Tips
  - 生产力
date: 2015-11-28 19:17:05
tags:
---

我使用的是windows下的最新版CTex，版本号是CTeX_2.9.2.164_Full.exe。注意使用full版本，如果不是，可能不支持beamer。beamer是一个流行的演讲文档模板，有多种主题，效果也还不错。

我在尝试beamer的过程中，发现网上大部分例子都不支持中文，或者不支持我使用的环境下的中文，即windows下的最新版CTex。折腾了几天，试了很多个模板，发现xeCJK能够完美解决这个问题，因为很多老的模板都是用的CJK，我将其中一个模板改成xeCJK就支持中文了。
 下面给出这个模板的设置。  


``` stylus
\documentclass{beamer}
\usetheme{Warsaw}
\usepackage{fontspec,xunicode,xltxtra}
\usepackage[slantfont,boldfont]{xeCJK} % 允许斜体和粗体
\setbeamercovered{transparent}
\usepackage[english]{babel}
% or whatever
\usepackage{hyperref}
\usepackage[T1]{fontenc}
% or whatever
\usefonttheme{professionalfonts}
\usepackage{times}
\usepackage{mathptmx}
\usepackage{tabularx}
% Or whatever. Note that the encoding and the font should match. If T1
% does not look nice, try deleting the line with the fontenc.
\usepackage{xcolor}
\usepackage{booktabs, multirow, enumerate}
\usepackage{animate}
\usepackage{multimedia}

% ... or whatever. Note that the encoding and the font should match.
% If T1 does not look nice, try deleting the line with the fontenc.
\usepackage{lmodern} %optional
\usepackage{listings}

% Delete this, if you do not want the table of contents to pop up at
% the beginning of each subsection:
\AtBeginSection[]
{
    \begin{frame}<beamer>
        \frametitle{内容大纲}
        \tableofcontents[currentsection]
    \end{frame}
}

\setCJKmainfont{Microsoft YaHei}   % 设置缺省中文字体
\setCJKmonofont{SimSun}   % 设置等宽字体
\setmainfont{TeX Gyre Pagella} % 英文衬线字体
\setmonofont{Microsoft YaHei} % 英文等宽字体
\setsansfont{Trebuchet MS} % 英文无衬线字体

\begin{document}

\title[***纹理***]% optional, use only with long paper titles
{ ***纹理***\\[2ex]}

%\subtitle[malloc] %optional
%{malloc\ 实现}

\author[yx] % optional, use only with lots of authors
{
\textcolor[rgb]{0.00, 0.41, 0.66}{yx}
}

% the titlepage
% the plain option removes the sidebar and header from the title page
\begin{frame}[plain]
  \titlepage
\end{frame}
%%%%%%%%%%%%%%%%

\begin{frame}
        \frametitle{内容大纲}
        \tableofcontents
\end{frame}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\section{研究背景和意义}
%%%%%%%%%%%%%%%%
\begin{frame}{纹理的作用}{}
  \begin{block}<1->{}
    纹理是图形学中增强真实性的重要手段。
  \end{block}
  \begin{block}<2->{}
    应用纹理到三维表面能够有效的表示物体表面的颜色，材质，几何等属性。
  \end{block}
\end{frame}
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\end{document}
```

值得注意的是，请用utf8来保存该文档，并且在WinEdit中用utf8来打开，否则还是可能看到乱码的。 
boats against the current, borne back ceaselessly into the past.