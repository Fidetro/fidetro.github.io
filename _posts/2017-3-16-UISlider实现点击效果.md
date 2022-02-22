---
layout:     post
title:      "UISlider实现点击效果"
subtitle:   "CocoaPod，iOS，UI"
date:       2017-3-16
author:     "Karim"
header-img: "img/post-bg-old.jpg"
tags:
- 问题随笔
- iOS
---

找了很久网上文章都是各种复制，而且不管用，最后在stackOverFlow找到怎么解决，记录一下[链接](http://stackoverflow.com/questions/22717167/how-to-enable-tap-and-slide-in-a-uislider)

关键是用UILongPressGestureRecognizer，实现拖动和点击
```objc
- (void)actionLongGesture:(UILongPressGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        CGPoint touchPoint = [sender locationInView:self.progressSlider];
        CGFloat value = (self.progressSlider.maximumValue - self.progressSlider.minimumValue) * (touchPoint.x / self.progressSlider.frame.size.width );
        NSInteger index = (NSInteger)(value + 0.5);
        [self.progressSlider setValue:index animated:NO];
        [self valueChange:self.progressSlider];
    }else if (sender.state == UIGestureRecognizerStateChanged){
        CGPoint touchPoint = [sender locationInView:self.progressSlider];
        CGFloat value = (self.progressSlider.maximumValue - self.progressSlider.minimumValue) * (touchPoint.x / self.progressSlider.frame.size.width );
        NSInteger index = (NSInteger)(value + 0.5);
        [self.progressSlider setValue:index animated:NO];
        [self valueChange:self.progressSlider];
    }
 
}
```
