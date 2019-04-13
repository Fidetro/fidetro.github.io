---
layout:     post
title:      "Swift关键字-@escaping逃逸闭包"
subtitle:   "Swift，iOS"
date:       2017-7-2
author:     "Karim"
header-img: "img/post-bg-old.jpg"
tags:
- Swift
- iOS
---
这部分在[The Swift Programming Language的Closures一节](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Closures.html#//apple_ref/doc/uid/TP40014097-CH11-ID94)有详细的说，当时看的时候没特别注意，今天在看Perfect的源码的时候看到了，重新去看了一下文档，也看了[卓同学的一篇文章](http://www.jianshu.com/p/120069d493f5)，写的比我的更详细。
当闭包不是函数执行完之前就得到返回结果的时候，这个就是非逃逸闭包。
反之，闭包在函数执行完后才调用，则是逃逸闭包。
举两个常用例子，SnapKit和Masonry的添加约束方法，就是非逃逸闭包。Alamofire和AFNetWorking的网络请求方法，是逃逸闭包。
