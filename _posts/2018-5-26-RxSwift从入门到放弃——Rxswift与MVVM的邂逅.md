---
layout:     post
title:      "RxSwift从入门到放弃——Rxswift与MVVM的邂逅"
subtitle:   "Swift,RxSwift"
date:       2018-5-26
author:     "Fidetro"
header-img: "img/post-bg-unsplash.jpg"
tags:
- RxSwift
- Swift
---

# 前言  
这篇出来的比较晚，最近事情也比较多，一直没时间写，这篇是作为[开篇](https://www.foolishtalk.org/2018/05/06/RxSwift%E4%BB%8E%E5%85%A5%E9%97%A8%E5%88%B0%E6%94%BE%E5%BC%83-%E5%BC%80%E7%AF%87/)到RxSwift源码分析的过渡。~~当然也是因为前几天我在公司内部分享ppt的内容也是这个~~就把这篇当作番外篇看看好了[doge]  

# 这篇聊点什么？  
- MVVM和RxSwift之间的关系
- MVVM是什么？  
- RxSwift能解决MVVM什么问题？
- RxSwift的看法

## MVVM和RxSwift之间的关系
我们在讲到RxSwift的时候，基本肯定会聊到MVVM，如果不太了解MVVM，可以先看后面`MVVM是什么？`。  
首先MVVM需要有ViewModel，iOS原生并没有提供很好的数据绑定方式，使用RxSwift、RxCocoa提供了已经封装好了数据与UI绑定的方法，使得数据绑定简单了起来。  
使用了RxSwift也并不是必须使用MVVM，使用MVVM架构，也并不是必须要使用RxSwift才能实现。  

## MVVM是什么？  
对于这个问题，我强烈推荐先去看看casa的[iOS应用架构谈 view层的组织和调用方案](http://casatwy.com/iosying-yong-jia-gou-tan-viewceng-de-zu-zhi-he-diao-yong-fang-an.html)，在这方面业内近年来已经都很少聊这方面的话题，我会讲讲我的看法，如果有什么错误，希望读者能在评论区指出。  

要聊MVVM是什么，就得先聊聊MVC。  
![](http://images.foolishtalk.org/mvc.png)    

一张来自斯坦福大学iOS公开课很经典的图，每次第一节课，都会放上这张图，这个图已经很好说明了MVC的关系。  

Model:  
- 给Controller监听，提供数据  

View:  
- 生成视图元素  
- 处理内部和业务无关的逻辑、交互，以及动画   

Controller:  
- 把View加载到Controller上  
- 负责实现View的delegate、dataSource，拿到Model，做对应业务逻辑的处理  
 
这种分工形成MVC的格局，然而在实际iOS开发中，往往会形成像下面的交互：  
![](http://images.foolishtalk.org/mvcnotify.png)  
在一些业务、界面复杂，多逻辑交互的时候，View的地位很尴尬，他不能直接和Model通讯，只能依赖Controller，这样就导致大量的delegate、action都由Controller去实现，业务的代码放View里又不方便监听变化，这时候能怎么办？只能往Controller里面放，因为这样，Controller变得异常的庞大同时难以复用，也是因为这个原因，就有人提出MVVM，来帮Controller瘦身。  
问题来了，MVVM是怎么帮Controller瘦身的呢？  
![](http://images.foolishtalk.org/MCVMVMV.gif)  
通过这张图就可以看出，MVVM其实就是在MVC的基础上，抽离了Controller的业务逻辑，移到了ViewModel,他们之间其实是这样的关系：  
![](http://images.foolishtalk.org/mvvm_logic.png)  

View层和之前做的事情一样，Controller订阅viewModel的事件变化，将View绑定到ViewModel上，要注意在Rx的思想里，ViewModel并不是直接拿到View，而是View的观察者属性或者可观察的序列。另外Controller也会基于ViewModel事件的响应做对应的交互逻辑。  

## RxSwift能解决MVVM什么问题？
RxSwift为我们平时使用的UI控件提供了响应式函数，使用自带的响应式函数就能非常方便的进行数据绑定。 
例如我们实现了一个选择体重尺子功能的View：  
以前的做法：
```swift
    func scrollRuleValue(collectionView: UICollectionView, value: CGFloat) {
        if collectionView == containerView.weightRuleView.collectionView {
            containerView.weightLabel.text = "\(value)kg"
        }
    }
```  
利用RxSwift的特性：
```swift
        containerView.weightRuleView.observerValue.map { (value) -> String in
            return "\(value)kg"
            }.bind(to: containerView.weightLabel.rx.text).disposed(by: disposeBag)
```
这行代码的意思：
1. 监听ruleView的observerValue序列发送;   
2. 将发送变化的体重值从CGFloat类型格式化成我们需要的字符串;  
3. 将尺子滑动变化的序列绑定到需要显示体重的label上;   

这是一个在Cocoa编程里最常见的委托代理模式，将视图变化交给Controller去处理，再去更新视图。而RxSwift只需要让ruleView创建一个发送数据的序列，再由Controller与需要更新的视图进行绑定，这样就能节省大量在写代理时候的代码。 

利用已经提供好的属性，既避免了ViewModel直接拿到View，可以随意的更改View属性，同时还节省了大量代码。另外一方面，由于业务逻辑已经都移到了ViewModel，对于业务的单元测试也变得极其简单，对于RxSwift的单元测试，可以了解一下`RxTest`和`RxBlocking`，本文就不展开说了。  


## RxSwift的看法  
个人觉得，RxSwift给我们带来最大影响的Reactive思想，OOP告诉我们，在编写应用程序的时候，要考虑的是对象有什么，对象做什么，对象与对象之间的联系，而Reactive思想将对象所做的都看成是数据流，我们关注的是事件本身的影响，学习一个新的编程范式，还是非常有意思的。  
当然RxSwift也会有不好的地方，RxSwift对工程的侵入性非常的大，引入RxSwift会让整个程序代码都焕然一新，和过去Cocoa开发方式截然不同，这样也导致Rx新手难以理解其中代码，可以说是极度不友好了。  
不过说了这么说，Reactive其中的响应式思想还是很值得我们去学习的，对于拿来开发项目，小项目可以拿来写着玩耍，体会新的编程范式，大型项目，就得做好踩坑的心理准备了。
