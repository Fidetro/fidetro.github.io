---
layout:     post
title:      "你真的了解p、po、v区别吗"
subtitle:   "iOS，Xcode，LLDB"
date:       2020-6-1
author:     "Karim"
header-img: "img/post-white-room.png"
tags:
- iOS
- Xcode
---

# 正文
平常在使用Xcode断点调试问题时，`po`可能是最常用到的`LLVM`命令了。  
通过`po`命令，我们可以在Xcode的`LLDB`控制台打印对象的描述，系统在运行时会提供一个默认值，如图：  
![](https://www.foolishtalk.org/cloud/caed4a8d6cbafa4387d2fb57155cf6e7.png)  

我们可以通过重写`func debugDescription()`达到我们希望在`po`的时候返回预期的返回值。  
![](https://www.foolishtalk.org/cloud/54e45465efc65c1b4fd93f2d8995ea4e.png)  

`po`的底层逻辑实现：  
![](https://www.foolishtalk.org/cloud/57320d88124faf7812bbaa673f37fee4.png)

事实上打印对象有三种方法，`po`只是其中一种。  

第二种方式是`p`。

`p`和`po`的区别在于，`p`不会随着`func debugDescription()`方法修改而且改变打印的值。
![](https://www.foolishtalk.org/cloud/0bb5fdda413e64e8b3ba45c58d1c2ec3.png)  

但是`p`和`po`，遵循swift的语法，在下面的例子中，是无法打印的。  
![](https://www.foolishtalk.org/cloud/f65d30492a3fc575e641976544a7aa1e.png)  
同样下面的代码也会报错：  
```Swift
    let student : Person = Student(name:"john")
    print(student.name) //这里是会报错的
```  

`p`的底层逻辑实现：  
![](https://www.foolishtalk.org/cloud/e2b0f3feefd02283937b5230a420110d.png)

第三种方式是通过`v`打印。  
`v`同样不会不会随着`func debugDescription()`方法修改而且改变打印的值。  
而且`v`有自己的语法，不需要通过编译，而是进行动态类型解析，但是它无法执行代码。  
![](https://www.foolishtalk.org/cloud/849c0b54225807f00201d31cd8bf072c.png)  

`v`的底层逻辑实现：  
![](https://www.foolishtalk.org/cloud/67340b5668cffd5d75e007e1839d46fd.png)

# 总结

|  | po | p | v |
| :-: | :-: | :-: | :-: |
| 显示对象的方式 | 通过对象描述方法打印 | 通过格式化打印 | 通过格式化打印 |
| 计算结果的方式 | 通过编译表达，可以完整访问编程语言 | 通过编译表达，可以完整访问编程语言 | 有自己的语法、解释和表达，解释过程中会多次动态类型解析 |  


# 参考链接  

[LLDB: Beyond "po"](https://developer.apple.com/videos/play/wwdc2019/429/)