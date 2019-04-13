---
layout:     post
title:      "iOS11-tableView设置section头尾高度失效"
subtitle:   "CocoaPod，iOS，UI"
date:       2017-9-21
author:     "Karim"
header-img: "img/post-bg-old.jpg"
tags:
- 问题随笔
- iOS
---
在iOS 11之前，直接通过这两个代理，就可以修改section的高度
```objc
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
```
今天在适配iOS 11的时候发现，这两个代理方法都没走，解决方法：
```objc
//先设置默认高度，然后再通过代理修改
    self.tableView.sectionFooterHeight = CGFLOAT_MIN;
    self.tableView.sectionHeaderHeight = CGFLOAT_MIN;
```
目前这个问题，只有纯代码的时候使用才会出现这个问题，如果是使用storyboard的tableView，是不会出现这个问题的，原因还没时间去查，等有空的时候查了会更新文章
