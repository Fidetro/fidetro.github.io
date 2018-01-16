---
layout:     post
title:      "CollectionViewLayout遇到的问题"
subtitle:   "CocoaPod，iOS，UI"
date:       2017-3-27
author:     "Fidetro"
header-img: "img/post-bg-old.jpg"
tags:
- 问题随笔
- iOS
---

```
2017-03-27 11:12:20.902274 DTSampleLight[1480:432147] The behavior of the UICollectionViewFlowLayout is not defined because:
2017-03-27 11:12:20.902372 DTSampleLight[1480:432147] the item height must be less than the height of the UICollectionView minus the section insets top and bottom values, minus the content insets top and bottom values.
2017-03-27 11:12:20.903319 DTSampleLight[1480:432147] The relevant UICollectionViewFlowLayout instance is <UICollectionViewFlowLayout: 0x1010c3170>, and it is attached to <UICollectionView: 0x1019c4e00; frame = (0 426; 320 78); clipsToBounds = YES; gestureRecognizers = <NSArray: 0x17425ac70>; layer = <CALayer: 0x174425780>; contentOffset: {0, 0}; contentSize: {132.74074073191042, 98}> collection view layout: <UICollectionViewFlowLayout: 0x1010c3170>.
2017-03-27 11:12:20.903366 DTSampleLight[1480:432147] Make a symbolic breakpoint at UICollectionViewFlowLayoutBreakForInvalidSizes to catch this in the debugger.
```
### 解决方法
```
- (void)viewWillLayoutSubviews {
    [self.containerView.collectionView.collectionViewLayout invalidateLayout];
}
```


>  [参考链接](http://stackoverflow.com/questions/16013209/uicollectionview-layout-issue)
