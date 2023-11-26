---
title: Unity3D代码规范
tags:
- Unity
- 代码规范
category:
- 游戏开发
- Unity
date: 2018-12-19 17:15:51
renderNumberedHeading: false
grammar_cjkRuby: true
---

# 一、命名法
Pascal命名法：每个单词首字母大写。
Camel命名法：第一个单词首字母小写，其余单词首字母大写。
C++标准库命名法：全小写，单词用下划线分割。

## 1.1 CSharp
函数和类采用Pascal命名法，变量采用Camel命名法。
代码目录和文件采用Pascal命名法。

## 1.2 Lua
类采用Pascal命名法，其余采用C\++标准库命名法。
代码目录和文件采用C\+\+标准库命名法。


## 1.3 其它
其它目录和文件采用Pascal命名法。

# 二、C\#代码规范
## 2.1 命名的基本约定
函数用动词命名，其它的用名词或者形容词命名。

### 避免使用拼音
原则上避免使用拼音命名代码。

### 尽量避免缩写
尽量不要缩写名字，名字长没关系，尽可能描述清楚。

### 类型前缀
类和变量前一般不要加前缀。模板类型加前缀T，接口加前缀I，枚举加前缀E。

### 类型后缀
特殊类型可选加后缀。
List：可选加List后缀。
Dictionary：可选加Dict后缀。
delegate：加上后缀Event。

### 命名空间
使用Pascal命名法。
命名空间采用GY开头，比如GYEngine、GYGame。

### 类
使用Pascal命名法。
类名要用名词。模板类开头用T。

### 接口
使用Pascal命名法。
接口开头用I。接口名要用名词或者形容词。

### 枚举
枚举类型采用Pascal命名法，需要加上前缀E，比如EMessageType。
枚举常量不需要加前缀，采用Pascal命名法，特殊情况下可以拆成两部分用下划线区分，比如Message_Start。

``` c#
public Enum EWeaponType
{
	Knife,
	Pistol,
	MachineGun,
}

public Enum EMessageType
{
	Message_Start,
	Message_End,
}
```

### 函数
使用Pascal命名法。
函数名最好用动词开头。

### 委托和事件
使用Pascal命名法。
使用动词短语命名，delegate类型的命名需要加上后缀Event。
event类型的实例需要加上On前缀，Event后缀。

``` C#
  public delegate void KillMonsterEvent();
  
  public event KillMonsterEvent OnKillMonsterEvent = null;
```

### 属性
使用Pascal命名法。
属性是对Get和Set的语法封装，一般是public或者protected采有意义。

### 特性(Attribute)
使用Pascal命名法。
用名词或名词短语+Attribute方式命名特性。
比如，

``` C#
public class ObsoleteAttribute
{
}
```

### 局部变量
采用Camel命名法。

#### 函数参数
采用Camel命名法。

### 成员变量
类非公有非静态成员变量用m开头。比如mActorId。
类的公有成员变量大写开头，不需要加m前缀，尽量用属性代替公有变量。

### 静态变量
类的静态成员变量用s开头。
函数内的静态变量用s开头。
比如，

``` C#
public Actor
{
	private int mActorId = 0;
	
	private static int sActorNumInClass = 0;
	
	protected int mActorClassId = 0;
	
	public string ActorName = "name";
	
	public int ActorId
	{
		get
		{ 
			return mActorId;
		}
		
		set
		{ 
			mActorId = value;
		}
	}
	
	public delegate void KillMonsterEvent();
  
  	public event KillMonsterEvent OnKillMonsterEvent = null;
  
  	public Actor()
	{
		mActorId = 0;
	}
	
	public int GetActorNum(bool isFirstTime)
	{
		static int sActorNumInFun;
		int addNum = 1;
		return sActorNumInFun = (isFirstTime ? 0 : sActorNumInFun + addNum);
	}
}
```

### 常量
所有单词大写，多个单词之间用下划线隔开，比如public const int MAX_NUM = 10。

## 注释
原则上，尽量写可读性良好、自解释的代码，避免写冗余的注释。

### 文件注释
文件开头必须要有注释，如果是单个类的文件，可以将用类注释替代。

### 类注释
单个类的文件，必须有类注释。
类注释说明该类是做什么的，可选包含怎么实现以及为什么这么实现的原因。

### 函数注释
简单函数不需要注释，难以使用的函数需要加注释，想想为什么难以使用，这个时候往往需要重构或者拆分函数代码了。

### 语句注释
关键难以理解的代码语句，需要加上注释说明。

### 变量注释
关键变量加上注释，普通的不需要加注释。

## 2.2 代码风格
### 类成员排列顺序
1. 属性：公有属性 、受保护属性 
2. 字段：受保护字段、私有字段（公有字段当作属性对待）
3. 事件：公有事件、受保护事件、私有事件
4. 构造函数：参数数量最少的构造函数，参数数量中等的构造函数，参数数量最多的构造函数
5. 方法：重载方法的排列顺序与构造函数相同，从参数数量最少往下至参数最多。方法按照功能分块，尽可能按照公有、保护、私有的访问级别来分布。

### 变量
1. 一行只能声明一个变量，尽量避免用var定义变量类型，除非类型写起来很冗余。
2. 尽量在声明的同时初始化。
3. 变量定义在开头，比如类开头或者函数开头。除非是根据条件定义的块变量。

比如，

``` C#
public class People
{
	private string mName = "PeopleName";
	private int mAge = 0;
	
	public void ChangeAge(int newAge, bool needAddAge)
	{
		mAge = newAge;	
		if (needAddAge)
		{
			int tempAddAge = 1;
			mAge += tempAddAge;
		}
	}
}
```

### 语句
1. 一行只能有一条语句。
2. 单行复合语句必须加大括号。原则上，即使只有一行语句，也需要加大括号包起来，防止后续修改代码破坏忘记语句范围。比如，

3. else if等必须新起一行。比如，
``` C#
if (isWorkday)
{
	Work();
}
else if (isHoliday)
{
	Rest();
}
```

### 缩进
代码缩进使用Tab键实现，最好不要使用空格，为保证在不同机器上使代码缩进保持一致，设置Tab键宽度为4个字符。

### 大括号
1. 大括号需要占一行对齐，而不是将左大括号放在行尾。
2. Lambda函数可以将左大括号放在同一行，不需要另起一行。

### 空格
1. if、while、for、return等关键词后应有一个空格［eg. “if (a == b)”］。
2. 运算符前后应各有一个空格［eg. “a = b + c;”］。
3. 函数调用后不需要加空格。
4. 左括号后面和右括号前面不需要加额外的空格。

### 空行
1. 函数之间必须加空行。
2. 较长函数的代码块直接用空行分割。
3. 变量定义可以分块加空行分割。

### 行长度
每一行代码的行长度，建议不要超过110个字符或者说不超过屏幕宽度。如果超过这个长度，可以按照以下规则换行：
1. 在逗号后换行。
2. 在操作符前换行。
3. 第一条优先于第二条。

### 函数长度
建议单个函数长度不要超过80行。越简短越好。
超过80行，可以考虑拆分函数重用代码。

### 类长度
单个类文件原则上不超过1000行。接近或者超过，考虑拆分类或者多个文件实现类。

## 2.3 示例代码

``` csharp
namespace YMGame
{
	public Enum EWeaponType
	{
		Knife,
		Pistol,
		MachineGun,
	}
	
	public Actor
	{
		private int mActorId = 0;
	
		private static int sActorNumInClass;
	
		protected int mActorClassId;
	
		public string ActorName;
	
		public int ActorId
		{
			get
			{ 
				return mActorId;
			}
		
			set
			{ 
				mActorId = value;
			}
		}
	
		public int GetActorNum(bool isFirstTime)
		{
			static int sActorNumInFun;
			int addNum = 1;
			return sActorNumInFun = (isFirstTime ? 0 : sActorNumInFun + addNum);
		}
		
		public void SetActorId(int classId, int actorId)
		{
			static int sNonClassIdActorNum = 0;
			
			mActorClassId = classId;
			mActorId = actorId;
			
			if (mActorClassId <= 0 )
			{
				sNonClassIdActorNum++;
				bool isNonClassIdActor = true;
				actorId = 0;
			}
		}
	}
}
```

# 三、Lua代码规范
除了以下特殊提及到的，Lua的代码规范参照C#的代码规范。

## 3.1 命名规则

### 文件（类）名
采用Pascal命名法。

### 函数
采用Pascal命名法。

### 文件的local变量
下划线开头，采用Camel命名法。比如_classType。

### 函数的local变量
采用Camel命名法。

### 函数参数
采用Camel命名法。

### C\#代码导出到Lua
必须增加Cs前缀以做区分，比如CsFileManager = CS.GYEngine.FileManager.Instance。

### 双下划线
双下划线用于一些特殊函数的前缀，比如类的初始化和销毁函数。

### 日志打印
使用项目规定的log函数。比如使用log.l，可以通过个人logid来过滤其他人日志；警告使用log.w；错误使用log.e，避免使用默认的error。

# 四、编程技巧

## 避免使用魔数
代码里面不要出现魔法数字，用常量来替代。

``` csharp
public double CalculateCircularArea(double radius) 
{
	return (3.1415) * radius * radius;
}

// 常量替代魔法数字
public static final Double PI = 3.1415;
public double CalculateCircularArea(double radius) 
{
 	return PI * radius * radius;
}
```

## 解释型变量
如下所示，用bool变量代替复杂的条件判断，bool变量的命名可以解释条件判断的意思。

``` csharp
if (date.after(SUMMER_START) && date.before(SUMMER_END))
{
  // ...
} 
else
{
  // ...
}

// 引入解释性变量后逻辑更加清晰
bool isSummer = date.after(SUMMER_START)&&date.before(SUMMER_END);
if (isSummer)
{
  // ...
} 
else
{
  // ...
} 
```

## 避免函数参数过多
参数过多时候，可以将参数组合成一个结构体传入，方便后续对参数的修改。

### 避免函数参数控制函数内部逻辑
可以考虑拆分成多个函数，保证函数职责单一。

## 避免嵌套过深
`可以考虑使用`continue、break、return关键字，提前退出嵌套。

## 分割代码和单一职责
如果函数或者类的代码过长，考虑拆分成多个函数或者类，保证职责单一。

## 预计算和缓存
比如Component或者UI控件的获得等，可以在初始化的时候获取然后缓存引用，避免重复查询。

## 避免频繁创建字符串
由于C#中的string是独一无二的，无法修改，所以字符串操作会创建新的字符串，不像C++可以就地初始化或者重复利用对象，因此避免大量使用string的操作符构建字符串，改成使用StringBuilder。

# 五、安全性编程
## 5.1 安全性编程原则
### 判空
C\#中的对象都是引用，使用前需要判空，空引用会造成异常。这个是良好的编程习惯。可以用空值传播操作符等，简略代码。

### 参数检查
对传入的参数要进行安全性检查，比如空引用，索引范围等，非法情况提前返回，然后再进行正常的逻辑处理。

### 尽可能使用错误处理而不是异常处理
异常有额外的性能消耗，加上异常会破坏调用链，应该尽可能用错误判断得方式处理各种可以预测的问题，而不是抛出异常。游戏引擎内一般不使用异常，比如UE4的源码内就禁用异常。

## 5.2 示例代码
``` csharp
public IEnumerator SpawnObjectAsync(string assetPath, Vector3 position, Quaternion rotation, Vector3 scale, Transform parent = null,
                    string name = "", Action<GameObject> onSpawnObjectDone = null)
{
    if (string.IsNullOrEmpty(assetPath))
    {
        GYLog.LogError("GameObjectPool SpawnObjectAsync assetPath is IsNullOrEmpty");
        yield break;
    }

    GameObjectPooledItemList pool = null;
    if (mAssetPathLookup.TryGetValue(assetPath, out pool) == false)
    {
        yield return WarmPoolAsync(assetPath, 1, (tempPool) => pool = tempPool);
    }

    if (pool == null)
    {
        GYLog.LogError("GameObjectPool SpawnObjectAsync Get GameObjectCollection return null");
        yield break;
    }

    GameObject clone = pool.GetItem();

    if (clone == null)
    {
        GYLog.LogError("GameObjectPool SpawnObject Get GameObject from GameObjectCollection return null");
        yield break;
    }

    clone.SetActiveEx(true);

    if (parent != null)
    {
        clone.transform.parent = parent;
    }
    clone.transform.position = position;
    clone.transform.rotation = rotation;
    clone.transform.localScale = scale;

    if (name != "")
    {
        clone.name = name;
    }

    mInstanceLookup.Add(clone.GetInstanceID(), pool);
    mIsDirty = true;

    onSpawnObjectDone?.Invoke(clone);
}
```

比如示例代码，首先做了输入参数检查，然后在执行过程中做了条件检查，检查失败直接主动报错，马上返回。



# 六、改动权限
项目中可以通过SVN或者Git的权限限制，避免过多人改动底层或者关键代码。下面举例说明，

## C\#的Engine代码
原则上，Engine代码不做改动，主程或者指定的人有权限改动，其它人需要改动需要事先跟主程沟通后才能改动。

## C\#的Game代码
在游戏发布之前，Game代码允许改动；在游戏发布之后，改动Game层的C#代码需要热更新二进制包或者打补丁更新，有改动需求需要事先跟主程沟通。

## Lua的框架代码
框架代码改动之前需要考虑清楚，客户端程序都有改动权限，改动大的部分最好同步主程或者执行主程等，并且负责跟踪和修复改动后引入的问题

## Lua的业务代码
客户端程序一直有改动权限，需要遵守代码规范。