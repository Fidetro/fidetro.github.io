---
layout:     post
title:      "记录点自己做CocoaPod时遇到的坑"
subtitle:   "CocoaPod，iOS"
date:       2017-6-19
author:     "Karim"
header-img: "img/post-bg-old.jpg"
tags:
- 问题随笔
- iOS
---

```
[!] The spec did not pass validation, due to 1 error.
[!] The validator for Swift projects uses Swift 3.0 by default, if you are using a different version of swift you can use a `.swift-version` file to set the version for your Pod. For example to use Swift 2.3, run: 
    `echo "2.3" > .swift-version`.

```
这是因为需要知道支持哪个swift版本，一般来讲现在都是支持Swift3的，输入这段就好了
```
echo "3.0" > .swift-version
```
