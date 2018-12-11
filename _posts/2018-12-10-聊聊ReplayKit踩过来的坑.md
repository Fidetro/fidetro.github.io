---
layout:     post
title:      "聊聊ReplayKit踩过来的坑"
subtitle:   "iOS，动画，ReplayKit"
date:       2018-12-10
author:     "Fidetro"
header-img: "img/post-bg-ismael.jpg"
tags:
- iOS
- Objective-C
---

# 前言  

`ReplayKit`是WWDC15推出的苹果原生录屏框架，目的在于让开发者更方便的使用屏幕录制功能，在悦跑圈的项目中也有用到，API对开发者可以说是非常友好了。我们先来看看`ReplayKit`的API。  

开始录制
```objc
    [[RPScreenRecorder sharedRecorder] startRecordingWithHandler:^(NSError * _Nullable error) {
       
    }];
```

停止录制  
```
[[RPScreenRecorder sharedRecorder] stopRecordingWithHandler:^(RPPreviewViewController * _Nullable previewViewController, NSError * _Nullable error) {
        
}];
``` 
另外停止录制的时候，会返回一个系统的previewViewController，对此可以进行最基本视频剪辑的。  
只需要在回调的时候调用一下：
```objc
previewViewController.delegate = self;
[self presentViewController:previewViewController animated:YES completion:nil];

#pragma mark - RPPreviewViewControllerDelegate
- (void)previewControllerDidFinish:(RPPreviewViewController *)previewController {
    //处理dismiss回来的回调
}
```

整体上来看，可以说是真的对开发者非常友好了，然而这里面的坑还是不少。  

# 细数ReplayKit的坑  

1. 开始录屏和停止录屏的回调，并不是在主线程。  
```objc  
    [[RPScreenRecorder sharedRecorder] startRecordingWithHandler:^(NSError * _Nullable error) {
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            //要注意回到主线程，避免线程问题
        }];
    }];
```

2. 停止录屏的previewViewController有可能为空  
```objc
    [[RPScreenRecorder sharedRecorder] stopRecordingWithHandler:^(RPPreviewViewController * _Nullable previewViewController, NSError * _Nullable error) {
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            if (!error && previewViewController) 
            {
                previewViewController.delegate = self;
                [self presentViewController:previewViewController animated:YES completion:nil]; 
            }else
            {
                
            }
        }];
    }];
```  

3. previewViewController没有适配全面屏  
```objc
    if (/* 全面屏 && iOS 11以上 */) {
        UIEdgeInsets safeArea = self.view.safeAreaInsets;
        CGFloat safeAreaHeight = self.view.frame.size.height - (safeArea.top + safeArea.bottom);
        CGFloat safeAreaWidth = self.view.frame.size.width - (safeArea.left + safeArea.right);
        CGFloat scaleX = safeAreaWidth / self.view.frame.size.width;
    CGFloat scaleY = safeAreaHeight / self.view.frame.size.height;
    CGFloat scale = MIN(scaleX, scaleY);
    previewViewController.previewControllerDelegate = self;
    previewViewController.view.transform = CGAffineTransformMakeScale(scale, scale);
    [self presentViewController:previewViewController animated:YES completion:^{
        previewViewController.view.frame = CGRectMake(previewViewController.view.frame.origin.x+safeArea.left, previewViewController.view.frame.origin.y+safeArea.top, previewViewController.view.frame.size.width, previewViewController.view.frame.size.height);
    }];
} else {
    previewViewController.previewControllerDelegate = self;
    [self presentViewController:previewViewController animated:YES completion:nil];
}
```

4. 停止录屏后present到previewViewController有可能黑屏（window如果是白色是白屏）  
这个问题目前没办法解决，在[stackoverflow](https://stackoverflow.com/search?q=replaykit+black)上也有许多相同的问题，暂时没办法解决  

5. 调用停止录屏方法，不管成功或失败有几率不进入回调  
这个问题同样无法解决，在[forums-develop](https://forums.developer.apple.com/thread/87007)中，也同样有人提出，被苹果标记为已知重复的问题（但是至今没修复...



# 解决  
通过翻阅RPPreviewViewController的私有属性和方法，发现有一个`movieURL`的属性。
```objc
    NSURL *movieURL = [previewViewController valueForKey:@"movieURL"];
```  
可以通过获取KVC的方式，获取视频地址，这样就可以避免黑屏的问题了，只是这样，如果要做视频剪辑，就需要另外自定义页面了。但是停止录屏不进入回调和previewViewController有可能为nil的问题，依旧无法解决。