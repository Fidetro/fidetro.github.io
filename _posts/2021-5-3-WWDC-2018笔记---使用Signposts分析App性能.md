---
layout:     post
title:      "WWDC-2018笔记---使用Signposts分析App性能"
subtitle:   "WWDC"
date:       2021-5-3
author:     "Karim"
header-img: "img/post-white-room.png"
tags:
- WWDC
- Instrument
- 性能分析
---


# 正文
`Signposts` 可以针对某段代码块进行性能分析，并且能在Instrument中显示,并且允许我们标记一段开始和结束，然后将这两点时间发生的事情与日志关联起来。
![](https://www.foolishtalk.org/cloud/8E243DC9-80EC-4729-A537-262254E0A542.png)
代码如下：   
```swift
import os.signpost

let refreshLog = OSLog(subsystem: "com.example.your-app", category: "RefreshOperations")
//标记单独获取所有图片的开始
os_signpost(.begin, log: refreshLog, name: "Refresh Panel")
for element in panel.elements {
    //标记单独获取一次图片的开始
    os_signpost(.begin, log: refreshLog, name: "Fetch Asset")
    //获取图片
    fetchAsset(for: element)
    os_signpost(.end, log: refreshLog, name: "Fetch Asset")
}
os_signpost(.end, log: refreshLog, name: "Refresh Panel")
```

同一个方法有可能被多次调用，在 Instrument 上会出现重叠的情况，如果我们希望区分是否是不同的对象调用，可以通过 `Signpost IDs` 实现。   
```swift
let spid = OSSignpostID(log: refreshLog)
os_signpost(.begin, log: refreshLog, name: "Fetch Asset", signpostID: spid)

os_signpost(.end, log: refreshLog, name: "Fetch Asset", signpostID: spid)
```
如果调用的对象本身具有唯一性，还可以用对象作为`Signpost IDs`。   
```swift
let spid = OSSignpostID(log: refreshLog, object: element)
os_signpost(.begin, log: refreshLog, name: "Fetch Asset", signpostID: spid)

os_signpost(.end, log: refreshLog, name: "Fetch Asset", signpostID: spid)
```

`os_signpost()`还允许我们在使用的时候通过格式化字符串的方式增加元数据。
```swift
os_signpost(.begin, log: log, name: "Compute Physics",
"for %{public}s at (%d, %.1f) with mass %.2f and velocity (%.1f, %.1f)", description, x1, y1, m, x2, y2)
```
更有利于我们后续分析和发现追踪特定场景下的问题，这里还要提到一点，对于字符串格式化，这里使用的了`%{public}s`，`description`如果是静态常量的字符串时，可以使用`%s`，但是需要格式化动态拼接的字符串
时，需要使用`%{public}s`，为了保护用户的隐私，苹果建议日志都使用静态字符串和数字组成。   
还有个小Tips，想让数据在`Instrument`上以内存大小的单位格式化，可以使用`%{xcode:size-in-bytes}llu`

苹果在WWDC上声称signpost进行了启动上优化，并且通过编译器的优化，使得它是在编译时运行而不是运行时，并且将很多工作都交给了`Instrument`,使得`signpost`在发送的时候只会占用非常少的系统资源。但是你依然有可能想停止`signpost`的使用。如果想在代码中停止某个`signpost`的使用，可以通过改变OSLog的初始化实现：   
```swift
let refreshLog: OSLog
if ProcessInfo.processInfo.environment.keys.contains("SIGNPOSTS_FOR_REFRESH") {
    refreshLog = OSLog(subsystem: "com.example.your-app", category: "RefreshOperations")
} else {
    refreshLog = .disabled //标记为不使用
}
os_signpost(.begin, log: refreshLog, name: "Refresh Panel")
for element in panel.elements {
    os_signpost(.begin, log: refreshLog, name: "Fetch Asset")
    fetchAsset(for: element)
    os_signpost(.end, log: refreshLog, name: "Fetch Asset")
}
os_signpost(.end, log: refreshLog, name: "Refresh Panel")
```   

`signpost`不仅支持Swift，同时也支持C、OC，API可以参考下图。  
![](https://www.foolishtalk.org/cloud/7548FA58-3851-4DFE-A885-0FD67F3EBFA3.png)

`signpost`如何使用这里就不展开说了，非常简单，在`Instrument`添加`os_signpost`的选项卡就可以使用。
![](https://www.foolishtalk.org/cloud/2021-05-03-12-34-02.png)

# 参考
[Measuring Performance Using Logging](https://developer.apple.com/videos/play/wwdc2018/405/)

[Why the Xcode 8 (iOS 10) print LogMessageLogging <private> in console](https://stackoverflow.com/a/39840862/6202715)
[Unified Logging and Activity Tracing](https://developer.apple.com/videos/play/wwdc2016/721/)