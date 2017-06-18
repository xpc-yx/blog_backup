---
title: hnu 10076 Jimmy's Riddles DFA
tags:
  - DFA
id: 284
categories:
  - ACM-ICPC
date: 2012-10-12 20:00:00
---

句子的语法匹配。这个用DFA确实可以很方便做出来，用递归判断之类的应该也可以。感觉用dfa只需要保证状态转换图对了，基本上就不会出bug了，但是其它的方法去匹配这种类似正则表达式的字符串就容易出错多了。

百度百科的DFA定义如下：
英文全称：Deterministic Finite Automaton, 简写：DFA
DFA定义：一个确定的有穷自动机（DFA）M是一个五元组：M=（K，Σ，f，S，Z）其中
① K是一个有穷集，它的每个元素称为一个状态；
② Σ是一个有穷字母表，它的每个元素称为一个输入符号，所以也称Σ为输入符号字母表；
③ f是转换函数，是K×Σ→K上的映射，即，如 f（ki，a）=kj，（ki∈K，kj∈K）就意味着，
当前状态为ki，输入符为a时，将转换为下一个状态kj，我们把kj称作ki的一个后继状态；
④ S ∈ K是唯一的一个初态；
⑤ Z⊂K是一个终态集，终态也称可接受状态或结束状态。<sup>
</sup>
该题的状态转换图：
![](https://c2.staticflickr.com/8/7609/26803884313_f0a5f126d3_o.png)
现在再根据状态转换图，写一个模拟转换关系的匹配就非常方便了。。。
代码如下：

``` stylus
#include <string>
#include <vector>
#include <sstream>
#include <iostream>
#include <algorithm>
using namespace std;

string strNouns[8] =
{
    "tom", "jerry", "goofy", "mickey",
    "jimmy", "dog", "cat", "mouse"
};

bool IsNoun(string str)
{
    for (int i = 0; i < 8; ++i)
    {
        if (str == strNouns[i])
        {
            return true;
        }
    }
    return false;
}

bool IsVerb(string str)
{
    return str == "hate" || str == "love"
           || str == "know" || str == "like"
           || str == "hates" || str == "loves"
           || str == "knows" || str == "likes";
}

bool IsArticle(string str)
{
    return str == "a" || str == "the";
}

bool CheckState(vector<string> vs)
{
    if (vs.empty()) return false;

    int nState = 0;
    for (int i = 0; i < vs.size(); ++i)
    {
        //printf("nState:%d, str:%s\n", nState, vs[i].c_str());
        switch (nState)
        {
        case 0:
            if (IsArticle(vs[i]))
            {
                nState = 1;
                break;
            }
            else if (IsNoun(vs[i]))
            {
                nState = 2;
                break;
            }
            else
            {
                return false;
            }

        case 1:
            if (IsNoun(vs[i]))
            {
                nState = 2;
                break;
            }
            else
            {
                return false;
            }

        case 2:
            if (vs[i] == "and")
            {
                nState = 0;
                break;
            }
            else if (IsVerb(vs[i]))
            {
                nState = 3;
                break;
            }
            else
            {
                return false;
            }

        case 3:
            if (IsArticle(vs[i]))
            {
                nState = 4;
                break;
            }
            else if (IsNoun(vs[i]))
            {
                nState = 5;
                break;
            }
            else
            {
                return false;
            }

        case 4:
            if (IsNoun(vs[i]))
            {
                nState = 5;
                break;
            }
            else
            {
                return false;
            }

        case 5:
            if (vs[i] == "and")
            {
                nState = 3;
                break;
            }
            else if (vs[i] == ",")
            {
                nState = 0;
                break;
            }
            else
            {
                return false;
            }
        }
    }

    return nState == 5;
}

int main()
{
    int nT;

    scanf("%d%*c", &nT);
    while (nT--)
    {
        vector<string> vs;
        string line, str;

        getline(cin, line);
        stringstream ss(line);
        while (ss >> str)
        {
            vs.push_back(str);
        }
        printf("%s\n", CheckState(vs) ? "YES I WILL" : "NO I WON'T");
    }

    return 0;
}
```