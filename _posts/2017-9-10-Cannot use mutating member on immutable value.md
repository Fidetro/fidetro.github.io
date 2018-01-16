---
layout:     post
title:      "Cannot use mutating member on immutable value"
subtitle:   "Swift，iOS"
date:       2017-9-10
author:     "Fidetro"
header-img: "img/post-bg-old.jpg"
tags:
- Swift
- iOS
---
这个报错是在我写swift的FFDB时候遇到的，因为在做swift版的时候，考虑到SQL语句层是通用的，所以打算抽象出来复用在Perfect上，选择用结构体和协议的方式去做，在使用结构体的时候，发现会报错，用类是不会报这个错的。原因是这样：
结构体中，func不可以改变self本身的成员变量，如果修改本身的成员变量，需要在func前加上`mutating`关键字
![1.png](http://foolishtalk.oss-cn-shenzhen.aliyuncs.com/73AD1856-8075-4CFE-A530-7F3E0D547F06.png)

加上了`mutating`之后本以为已经可以了，然后调这方法看看,报错来了，大概意思是不可以在一个不可变的值使用可以的成员，函数返回的是一个不可变的值，所以问题就出在函数的返回值

![2.png](http://foolishtalk.oss-cn-shenzhen.aliyuncs.com/0D9699AB-D8DB-4341-B1AF-7ACD8C56D082.png)

然后我改成这样就可以了，也不需要`mutating`修饰
```
     func into(_ tableClass:FFDataBaseModel.Type) -> Insert {
        var insert = self
        
        insert.sqlStatement?.append(" INSERT INTO " + tableClass.tableName())
        
            return insert
        }
```
