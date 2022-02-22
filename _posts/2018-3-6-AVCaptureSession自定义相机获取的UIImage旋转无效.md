---
layout:     post
title:      "AVCaptureSession自定义相机获取的UIImage旋转无效"
subtitle:   "AVFoundation，Tips"
date:       2018-3-6
author:     "Karim"
header-img: "img/post-bg-sea.jpg"
tags:
- iOS
- 问题随笔
---



在使用`AVCaptureSession`自定义相机的时候，发现无论横竖拍出来，照片的方向总是不对，参考了下面的两个链接的方法依旧行不通，然后自己想了个办法去解决。

[is-uiimage-imagewithciimagescaleorientation-broken-on-ios10](https://stackoverflow.com/questions/39705993/is-uiimage-imagewithciimagescaleorientation-broken-on-ios10)  

[how-to-rotate-a-uiimage-90-degrees](https://stackoverflow.com/questions/1315251/how-to-rotate-a-uiimage-90-degrees/30703714#30703714)   

 
通过使用重力加速计判断手机旋转的方向，再去设置`AVCaptureConnection`的`videoOrientation`属性，代码如下：  
```objc
@interface FIDCameraHelper ()
@property (nonatomic,strong) CMMotionManager *motionManager;
@property (nonatomic,assign) UIImageOrientation orientation;
@end
@implementation FIDCameraHelper
- (CMMotionManager *)motionManager
{
    if (!_motionManager)
    {
        _motionManager = [[CMMotionManager alloc]init];
    }
    return _motionManager;
}

//启动重力加速计
+ (void)startUpdateAccelerometerResult:(void (^)(UIImageOrientation orientation))result
{   
    if ([sharedManager.motionManager isAccelerometerAvailable] 
        [sharedManager.motionManager setAccelerometerUpdateInterval:0.1];
        [sharedManager.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error)
         {
             double x = accelerometerData.acceleration.x;
             double y = accelerometerData.acceleration.y;
             if (fabs(y) >= fabs(x))
             {
                 if (y >= 0){
                     //Down
                     if (result) {
                         result(UIImageOrientationDown);
                     }
                 }
                 else{
                     //Portrait
                     if (result) {
                         result(UIImageOrientationUp);
                     }
                 }
             }
             else
             {
                 if (x >= 0){
                     //Right
                     if (result) {
                         result(UIImageOrientationRight);
                     }
                 }
                 else{
                     //Left
                     if (result) {
                         result(UIImageOrientationLeft);
                     }
                 }
             }
         }];
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldNotPropagate);
    CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(NSDictionary *)CFBridgingRelease(attachments)];
    //根据方向设置videoOrientation
    switch (self.orientation) {
        case UIImageOrientationUp:
        {
            connection.videoOrientation = AVCaptureVideoOrientationPortrait;
            break;
        }
        case UIImageOrientationDown:
        {
            connection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        }
        case UIImageOrientationLeft:
        {
            connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        }
        case UIImageOrientationRight:
        {
            connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        }
        default:
            break;
    }
    self.cameraImage = [UIImage imageWithCIImage:ciImage scale:1.0 orientation:self.orientation];
}

@end
```
