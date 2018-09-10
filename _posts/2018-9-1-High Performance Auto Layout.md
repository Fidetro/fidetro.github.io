---
layout:     post
title:      "WWDC-2018笔记---High Performance Auto Layout"
subtitle:   "iOS，自动约束"
date:       2018-9-1
author:     "Fidetro"
header-img: "img/post-bg-ismael.jpg"
tags:
- iOS
---

最近总算有点时间写博客了，这次讲的是WWDC 2018中的[Session 220 High Performance Auto Layut](https://developer.apple.com/videos/play/wwdc2018/220/)  

`AutoLayout`作为平时用的最多的布局方案，但是在性能上总是饱受病垢，通过这个session，我们可以了解到`AutoLayout`是怎么工作的，以及在iOS 12上`AutoLayout`得到了怎样的提升。  

# 正文  

> talk is cheap,show me the code  
先上来就是一段代码，告诉了我们，不要每次更新约束的时候，都把所有的约束移除，这样是错误的：  
```swift
// Don’t do this! Removes and re-adds constraints potentially at 120 frames per second
override func updateConstraints() {
    NSLayoutConstraint.deactivate(myConstraints)
    myConstraints.removeAll()
    let views = ["text1":text1, "text2":text2]
    myConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[text1]-[text2]",
                                                    options: [.alignAllFirstBaseline],
                                                    myConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-[text1]-|",
                                                                                                    metrics: nil, views: views)
        options: [],
        metrics: nil, views: views)
    NSLayoutConstraint.activate(myConstraints)
    super.updateConstraints()
}
```
而且从这段注释就隐约透露了，尽管目前不能达到120fps，但是在未来的iPhone很有可能能达到120fps，所以并不建议我们这样操作。  
正确的做法应该是通过懒加载的方式，如果已经添加了约束，就不需要再移除，再添加了：  
```swift
// This is ok! Doesn’t do anything unless self.myConstraints has been nil’d out
override func updateConstraints() {
    if self.myConstraints == nil {
        var constraints = [NSLayoutConstraint]()
        let views = ["text1":text1, "text2":text2]
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[text1]-[text2]",
                                                      options: [.alignAllFirstBaseline],
                                                      metrics: nil,
                                                      views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-[text1]-|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: views)
    }
    NSLayoutConstraint.activate(constraints)
    self.myConstraints = constraints
    super.updateConstraints()
}
```   

为了更好让我们理解“为什么要这么做”，而不是让我们知道“就是得这样做”，这个session给出了更详细的解释。  

当我们创建了一个View，给这个View去添加约束的时候，会创建一个和约束对应的等式，将其添加到计算约束的引擎中，引擎会将约束解释成视图的布局变量，最终设置视图的x，y，width，height。  

例如我们要创建下图的视图关系：  
![](http://images.foolishtalk.org/2018_9_8_autolayout_1.png)  

约束会转换成以下的等式：  
![](http://images.foolishtalk.org/2018_9_8_autolayout_2.png)  


```swift  
text1.minX = 8
text1.width = 100
text2.minX = text1.minX + text1.width + 20
```  
最终将变量代入公式中得到最终的值： 

```swift  
text1.minX = 8
text1.width = 100
text2.minX = 8 + 100 + 20
text2.width = 128
```
到这里为止，引擎对这个布局的计算就已经完成了。  
每当引擎将计算得到的值赋值给变量的时候，它会告诉视图，你的变量已经发生了改变，这时候视图则会调用`Superview.setNeedsLayout()`通知父视图发生了变化,然后视图会执行`layoutSubviews()`,同时询问引擎变化的值是什么，引擎告诉视图的值，就会调用`setBounds()`和`setCenter()`，然后完成整个布局的过程。  

如果希望在使用`AutoLayout`的时候，提高性能，在遇到一个视图，会发生改变的时候，不要`removeAll()`，这样会造成约束流失，导致性能下降。而是在不需要使用的时候，调用`deactivate()`使约束暂时失效,而再次需要用到的时候调用`activate()`再次激活。  
我们在使用`AutoLayout`的时候，大多数会使用一些第三方库，而不会直接使用苹果原生提供的VFL或者其他原生api，在`Objective-C`中会使用`Masonry`，在`Swift`中会使用`SnapKit`，下面以`SnapKit`为例子：  
```swift
var firstConstraint: Constraint?
var secondConstraint: Constraint?

func setupLayout() {
  view.snp.makeConstraints { make in 
     firstConstraint = make.bottom.equalTo(otherView.snp.bottom).constraint
     secondConstraint = make.bottom.equalToSuperview().constraint
  }
  firstConstraint?.activate()
  secondConstraint?.deactivate()
}

func updateLayout() {
  let something: Bool = ...
  if something  {
    firstConstraint?.activate()
    secondConstraint?.deactivate()    
  } else {
    firstConstraint?.deactivate()
    secondConstraint?.activate()
  }

```

# 总结  
剩下一部分是比较零散的小技巧，所以放到总结中：  
- 在使用优先级的时候，引擎会进行更多的计算，导致性能下降。
- 在视图中的子试图存在不同状态的时候，需要显示或移除的时候，可以优先考虑使用隐藏视图、激活约束、失效约束去避免约束流失。
- 部分控件是具有固定尺寸的，例如UIImageView会根据UIImage的大小去适应尺寸，原理也是通过UIView创建约束，你可以自己去设定大小，这样就会跳过系统计算约束的步骤，但是不要认为这样可以提高性能。但是有一种情况下是可以提高性能的，就是在使用UILabel的时候，如果你自己手动去计算label的size的时候，可以通过重写`var intrinsicContentSize: CGSize`属性,告诉系统不需要帮我们计算。
```swift
override var intrinsicContentSize: CGSize {
    return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
}
```  
- 尽可能少调用`systemLayoutSizeFitting(_:)`方法，它会临时创建一个引擎，然后返回size之后丢弃，频繁的调用，会造成性能下降。