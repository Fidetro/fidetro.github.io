---
layout:     post
title:      "iPhoneX和iOS-11的适配你可能会踩到的坑"
subtitle:   "iOS，UI"
date:       2017-10-7
author:     "Fidetro"
header-img: "img/post-bg-old.jpg"
tags:
- 问题随笔
- iOS
---
这几天都在看关于适配的问题，看WWDC的时候，哇这个功能好酷炫，API变得好方便，适配一定很方便，然后自己用的时候一看这些方法后面带着`API_AVAILABLE(ios(11.0),tvos(11.0))`
![](http://images.foolishtalk.org/2357E228-C575-46EF-AFEF-C28514BBD380.png)
那么iPhone X究竟给我们带来了什么，导致适配变得麻烦呢？凶手就是这个刘海！
![](http://images.foolishtalk.org/C4439A59-7652-49B4-A437-31D56F8744AA.png)

在没有iPhoneX的时代，我们的statusBar是20pt，navigationBar是44pt，iPhone X的statusBar变成了44pt，navigationBar是44pt

![](http://images.foolishtalk.org/0B24C760-58CD-40DB-B212-A1DF9A65ED40.png)
为了方便我们适配，引入了`Safe Area`的概念，根据苹果最新的[人机交互指南](https://developer.apple.com/ios/human-interface-guidelines/overview/iphone-x/)中我们布局UI时候应该在`Safe Area`中而不应该超出`Safe Area`的范围
![](http://images.foolishtalk.org/764E4AA7-A3BE-4782-AACF-69E4EBE4CAF7.png)
说完这些坑之后，也该讲讲怎么适配了，talk is cheap，show me the code！
 在iOS 11发布后，Masonry也更新了最新适配的方法，增加了以下属性方便我们适配
```objc
@property (nonatomic, strong, readonly) MASViewAttribute *mas_safeAreaLayoutGuide NS_AVAILABLE_IOS(11.0);
@property (nonatomic, strong, readonly) MASViewAttribute *mas_safeAreaLayoutGuideLeading NS_AVAILABLE_IOS(11.0);
@property (nonatomic, strong, readonly) MASViewAttribute *mas_safeAreaLayoutGuideTrailing NS_AVAILABLE_IOS(11.0);
@property (nonatomic, strong, readonly) MASViewAttribute *mas_safeAreaLayoutGuideLeft NS_AVAILABLE_IOS(11.0);
@property (nonatomic, strong, readonly) MASViewAttribute *mas_safeAreaLayoutGuideRight NS_AVAILABLE_IOS(11.0);
@property (nonatomic, strong, readonly) MASViewAttribute *mas_safeAreaLayoutGuideTop NS_AVAILABLE_IOS(11.0);
@property (nonatomic, strong, readonly) MASViewAttribute *mas_safeAreaLayoutGuideBottom NS_AVAILABLE_IOS(11.0);
@property (nonatomic, strong, readonly) MASViewAttribute *mas_safeAreaLayoutGuideWidth NS_AVAILABLE_IOS(11.0);
@property (nonatomic, strong, readonly) MASViewAttribute *mas_safeAreaLayoutGuideHeight NS_AVAILABLE_IOS(11.0);
@property (nonatomic, strong, readonly) MASViewAttribute *mas_safeAreaLayoutGuideCenterX NS_AVAILABLE_IOS(11.0);
@property (nonatomic, strong, readonly) MASViewAttribute *mas_safeAreaLayoutGuideCenterY NS_AVAILABLE_IOS(11.0);
```
但是这些属性只有在iOS 11中才可以使用，所以如果要适配从iOS 8开始，做下面的效果得写判断

![](http://images.foolishtalk.org/E6C62EB6-71E0-4253-80FC-EFBEE4657537.png)

![](http://images.foolishtalk.org/C9391B5F-D768-48F7-B003-0E7964D48820.png)

```objc
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"First";
    UIView *colorView = [[UIView alloc]init];
    [self.view addSubview:colorView];
    colorView.backgroundColor = [UIColor redColor];
    [colorView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.mas_equalTo(self.view.mas_top).mas_offset(64);
        }
        make.left.bottom.right.mas_equalTo(self.view);
    }];
}
```
`@available(iOS 11.0, *)`只是判断iOS系统版本，并不是判断是否iPhoneX，即时是iPhoneX以下，只要升到了iOS11也是可以用`SafeArea`的
在iOS 11之前，ViewController中的`automaticallyAdjustsScrollViewInsets`是默认`YES`的，这样会导致在有导航栏的情况下，第一个subView如果`UIScrollView`的子类，例如`UITableView`的时候，`TableView`的本身不会做偏移，但是`UITableViewWrapperView`会往下偏移到导航栏下面，让导航栏不会发生挡住TableView内容的情况。但是在iOS11后，`automaticallyAdjustsScrollViewInsets`被废弃了，这个属性被移到了`UIScrollView`中的`contentInsetAdjustmentBehavior`，大家应该都遇过导航栏是透明的但是导航栏的Item是显示的需求，如果要做这种效果

![](http://images.foolishtalk.org/5759B33B-9C3F-485A-801C-32C421E0023F.png)
![](http://images.foolishtalk.org/B7D623C5-CBF1-47A8-9D07-3EA684D8BBD9.png)
```objc
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor greenColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
 
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            if (((UIApplication *)[UIApplication performSelector:@selector(sharedApplication)]).keyWindow.safeAreaInsets.top > 0.0) {//iOS11而且是iPhone X
                make.top.mas_equalTo(self.view.mas_top).mas_offset(44);//这个也可以用    self.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0); make.top.mas_equalTo(self.view.mas_top);代替

            } else {//iOS11，但是不是iPhone X
                make.top.mas_equalTo(self.view.mas_top).mas_offset(20);
            }
        } else {//iOS11以下，而且不是iPhone X
            make.top.mas_equalTo(self.view.mas_top).mas_offset(20);
        }
    }];
}
```
或者使用scrollView的contentInset
```objc
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor greenColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    if (@available(iOS 11.0, *)) {
        if (((UIApplication *)[UIApplication performSelector:@selector(sharedApplication)]).keyWindow.safeAreaInsets.top > 0.0) {//iOS11而且是iPhone X
            self.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
        } else {//iOS11，但是不是iPhone X
            self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
        }
    } else {//iOS11以下，而且不是iPhone X
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
        
    }
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
 
   [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(self.view);
    }];
}
```
总的来说，如果不出现很多这种导航栏隐藏的情况，适配应该工作量不会很大，如果TabBar和NavigationBar全是自定义的话，估计工作量会大很多。
附上参考链接和WWDC链接：
1. [官方适配指南](https://developer.apple.com/cn/ios/update-apps-for-iphone-x/)
2. [Designing for iPhone X](https://developer.apple.com/videos/play/fall2017/801/)
3. [Building Apps for iPhone X](https://developer.apple.com/videos/play/fall2017/201/)
4. [Updating Your App for iOS 11](https://developer.apple.com/videos/play/wwdc2017/204/)
5. [Modern User Interaction on iOS](https://developer.apple.com/videos/play/wwdc2017/219/)
6. [Auto Layout Techniques in Interface Builder](https://developer.apple.com/videos/play/wwdc2017/412/)
