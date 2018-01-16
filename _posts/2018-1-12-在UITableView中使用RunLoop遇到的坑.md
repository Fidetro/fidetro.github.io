---
layout:     post
title:      "在UITableView中使用RunLoop遇到的坑"
subtitle:   "Swift，iOS，Objective-C"
date:       2018-1-12
author:     "Fidetro"
header-img: "img/post-bg-sea.jpg"
tags:
- 经验
- RunLoop
- iOS
---
> 在做Pet Day的时候，遇到一个这样的需求，假定`tableView`中的section初始值为50,在往上或者往下的时候，需要通过计算得知更多的`dataSource` 

然后我一开始的做法，是在`- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;`的方法在接近顶部或者接近底部的时候，进行计算
```
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        //如果大于数据源总数-30，需要开始计算后面的内容
        if indexPath.section > dataSource.count - 30 {
           
        }else if indexPath.section < 30 {//如果小于30，需要开始计算前面的内容
           
    }
```
--------------------------------------
**但是，这样做会有问题**，在遇到向上刷新的时候，会多次调用`- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;`的方法，导致数据突然增多。  

后来用定时器实现触发后0.5秒内拦截，代码如下：
```
   guard share.operations.contains(tag) == false else {
            return
        }
        let timer = Timer.bs_scheduledTimer(withTimeInterval: interval, block: { (timer) in
            weak var weakTimer = timer

            weakTimer?.invalidate()
            weakTimer = nil
        }, repeats: false)
        share.operations.insert(tag)
        timer.fire()
        shareRunLoop().add(timer, forMode: .defaultRunLoopMode)

```

### **这时候RunLoop的坑就来了**
第一次触发...正常  
第二次触发...0.5秒过了，好几秒过去了，还是没有反应  
...  
终于在停止刷新后，再往上刷，正常了

我自己的推测是因为tableView在刷新的过程中，tableView的刷新事件比定时器的事件先进，需要等刷新停止了，定时器才能执行  
然后换了另外一种实现方式就没问题了
```
        
        guard share.operations.contains(tag) == false else {
            return
        }
            operation()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + interval, execute: {
            share.operations.remove(tag)
        })
        
        share.operations.insert(tag)
```