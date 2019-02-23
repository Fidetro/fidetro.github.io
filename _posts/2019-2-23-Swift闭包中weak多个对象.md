---
layout:     post
title:      "Swift闭包中weak多个对象"
subtitle:   "Swift，weak"
date:       2019-2-23
author:     "Fidetro"
header-img: "img/post-bg-andre-benz.jpg"
tags:
- iOS
- Swift
- Swift-Tips
---

无论是在OC还是Swift都会有在闭包中需要弱引用对象的时候，没有在Swift的文档中看到如何在闭包中对多个对象弱引用，最后在stackoverflow上[找到](https://stackoverflow.com/questions/28015394/how-can-you-capture-multiple-arguments-weakly-in-a-swift-closure)相关的资料：  

```swift  
{ [weak self,weak sender]  in
            
    //....
}
```