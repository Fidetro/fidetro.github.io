---
layout:     post
title:      "知乎app内打开app store的功能分析"
subtitle:   "iOS，动画，SKStoreProductViewController"
date:       2018-12-13
author:     "Karim"
header-img: "img/post-bg-sea.jpg"
tags:
- iOS
- Swift
---

# 前言  

今天刚好有个朋友问了我一个像知乎那样，app内打开app store的app内容页面，上面还能播放视频这种是怎么实现的，虽然问题很简单，但是本着探讨功能实现的想法，记录了下来。知乎app内效果如下：  
![](http://images.foolishtalk.org/2018-10-13-image-zhihu-ad.jpeg)  

通过这个图可以看出，其实要做的事情很简单，就是把原来的view往下移一点，然后在上面放视频。  
无非就是几个思路，先看看原来的vc是否有子view属性，通过继承去重写约束，其次就是使用一些比较hack的手段。  

# 正文  
先从`SKStoreProductViewController`着手，不难发现，这个类并没有公开相关的属性，或者方法允许你直接改变原来的高度。  
既然如此，我们就从`UIViewController`的view下手：  
```swift
            let storeVC = SKStoreProductViewController()
            storeVC.delegate = self
                present(storeVC, animated: true, completion: {
                storeVC.view.frame.origin.y += 150
            })
```
这时候，的确效果达到了，但是如果你试着把控件放在上面，会发现点击并没有反应，因为我们把控制器的view往下移动了，这时候我们添加的控件超出了父视图，是没有办法响应点击事件的。所以直接修改控制器view的y是不可行的。  
另外一个思路是获取控制器上view的子视图，让它们所有都往下，这时候控制器的view的frame并没有改变，这样就能实现我们想要的效果了。  
```swift
            let storeVC = SKStoreProductViewController()
            storeVC.delegate = self
                present(storeVC, animated: true, completion: {
                for subview in storeVC.view.subviews {
                    subview.frame.origin.y += 150 ////子view往下移
                }
                let button = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: CGFloat.screenWidth(), height: 150))
                button.backgroundColor = .red
                storeVC.view.addSubview(button)
            })
```
效果如下:  
![](http://images.foolishtalk.org/2018-10-13-image-yuepao-ad.jpeg)

到了这里，基本已经差不多了，但是其实还有些小细节要注意，这样直接修改的话，会发现没办法将页面滚到最底下。这时候还需要将view的高度减少：  
```swift
            let storeVC = SKStoreProductViewController()
            storeVC.delegate = self
                present(storeVC, animated: true, completion: {
                for subview in storeVC.view.subviews {
                    subview.frame.origin.y += 150 //子view往下移
                }
                storeVC.view.frame.size.height -= 150 //将view的高度减少
                let button = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: CGFloat.screenWidth(), height: 150))
                button.backgroundColor = .red
                storeVC.view.addSubview(button)
            })
```

另外知乎其实是先push到一个原来已经放着videoView的Controller，然后在`viewDidLoad`的时候再present到`SKStoreProductViewController`。只是一些交互上的细节，这点没有在上面分析。