---
layout:     post
title:      "How Mirror Works"
subtitle:   "iOS，Swift，Mirror"
date:       2018-10-7
author:     "Fidetro"
header-img: "img/post-bg-ismael.jpg"
tags:
- iOS
- Swift
---

Swift非常重视静态类型，但它也支持丰富元数据的类型，这允许代码在运行时检查和操作任意值。这是通过`Mirror`API向Swift程序员公开。有人可能会想，`Mirror`究竟是怎样在一个如此重视静态类型的语言中工作的？让我们来看看！  

# 免责声明  
这里都是内部实现的细节。截至撰写本文时，是根据最新的代码写的，但可能会发生变化。（译注：这里指的是2018年9月26日之前）当ABI稳定的时候，元数据将成为一种可靠的格式，但现在依然可能发生改变。如果你在编写正常的Swift代码，请不要依赖这个类的代码。如果您正想要编写比Mirror提供的更复杂的反射的代码，这会给你一个起点，但是在ABI稳定之前，你需要保持持续更新（你的代码）。如果你想使用`Mirror`本身的代码，这会让你很好的理解到它们是如何组合起来的。但是记住，它可能会发生变化。  

# 接口  
`Mirror(reflecting:)`初始化接受一个任意值。生成的`Mirror`实例提供该值的信息，主要是它的子项，一个由子项组成的值和可选的标签。你可以使用`Mirror`去遍历整个对象，不需要在编译时知道它是什么类型。  
`Mirror`允许类通过符合`CustomReflectable`提供自定义表示。这在你想要返回比内省类型更好的类型的时候很有用。例如，`Array`遵循`CustomReflectable`协议和将数组的元素公开为未标记的子元素。`Dictionary`