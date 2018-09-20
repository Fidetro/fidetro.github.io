---
layout:     post
title:      "NS_ASSUME_NONNULL_BEGIN && NS_ASSUME_NONNULL_END"
subtitle:   "iOS，Xcode 10"
date:       2018-9-19
author:     "Fidetro"
header-img: "img/post-bg-ismael.jpg"
tags:
- iOS
---

更新了Xcode 10之后在新建OC的类的时候，都会默认加上了`NS_ASSUME_NONNULL_BEGIN`和`NS_ASSUME_NONNULL_END`。  
```objc
NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

@end

NS_ASSUME_NONNULL_END
```  
在Objective-C中，是没有像swift中`!`和`?`的概念，为了解决和swift混编的问题，增加了`__nullable`和`___nonnull`的关键字。 `__nullable`代表修饰的对象可以为nil。  

`___nonnull`代表修饰的对象不可以为NULL或者为nil。  
当我们给类中其中一个对象声明`__nullable`或`___nonnull`时候，需要把所有的对象都加上`__nullable`或`___nonnull`。  

而`NS_ASSUME_NONNULL_BEGIN`和`NS_ASSUME_NONNULL_END`中间声明的对象会把所有对象默认当作是`__nonnull`，而我们只需要可能为nil的对象声明为`__nullable`就可以了。
