---
layout:     post
title:      "国行iPhone开启Apple Intelligence体验Foundation Models"
subtitle:   "swift、Foundation Models、Apple Intelligence"
date:       2025-12-2
author:     "Karim"
header-img: "img/DSC01667.jpg"
tags:
- iOS
- Foundation Models
- Apple Intelligence
- WWDC2025
---

# 前言
最近爆出iOS系统存在漏洞，国行iPhone可以在iOS18.1Beta-iOS26.2Beta1版本中，通过修改手机地区的配置文件可以开启Apple Intelligence功能，笔者也是第一时间尝试了该方法，成功在国行iPhone上体验到了Apple Intelligence，并且尝试了使用Foundation Models进行文本生成，效果也不错。


# 一、开启Apple Intelligence  
要在国行iPhone开启Apple Intelligence功能，首先需要准备：
- 美区Apple ID
- iOS18.1Beta-iOS26.2Beta1版本的iPhone
- iPhone 15 Pro以上机型


1. 通过shortcut快捷指令获取修改地区配置文件：
https://www.icloud.com/shortcuts/313d0562fc7f466b9775cef026577670
2. 执行快捷指令：  
![](https://www.foolishtalk.org/cloud/158781-04d4e0b10b902cb0fde5c5c0e24c7de3.jpg)  
3. 根据提示步骤操作：  
![](https://www.foolishtalk.org/cloud/205885-9ea3ee9994baa41a1eec30b7cfe09980.jpg)  
4. 全选复制，导出到mac上，并保存为MobileGestalt.plist：
![](https://www.foolishtalk.org/cloud/415969-ac43cc756257450898860556148e18be.jpg)   
5. 在[这里](https://support.apple.com/zh-cn/108044),找到自己手机的型号，举个例子，我的是国行iPhone 16 Pro Max对应的型号就是`A3297`，通过Xcode打开MobileGestalt.plist，搜索找到`A3297`，将值改为美区对应的型号，如果是iPhone 16 Pro Max则改成`A3084`。另外还需要搜索`CH`改为`LL`,`CH/A`改为`LL/A`。
![](https://www.foolishtalk.org/cloud/mobilegestalt_change.png)   
6. 保存修改后的`MobileGestalt.plist`，在GitHub上下载[misaka26项目](https://github.com/straight-tamago/misaka26/releases)。
7. iPhone连接上Mac，然后打开misaka26，选择`MobileGestalt.plist`，勾选`Apple Intelligence`，点击`Apply`，等待手机重启即可。（强烈建议操作之前备份手机，操作有误有可能导致无限重启！）  
![](https://www.foolishtalk.org/cloud/c47c466b-2390-41b2-9f81-cfb1899eefaf.png)  
![](https://www.foolishtalk.org/cloud/53b28a21-e761-416d-aaa6-1823c459d402.png)  

8. 开启成功后，地区可以语言选择中国大陆&简体中文或者美国&English，均可使用Apple Intelligence功能，如果没出现Apple Intelligence可以尝试多重启几次手机。  
![](https://www.foolishtalk.org/cloud/215619-98a77a1da845b23317a18bc5d175c7c9.jpg)  


# 二、体验Foundation Models
当手机下载完成Apple Interlligence模型后，就可以使用Foundation Models进行文本生成了，举一个简单的调用的例子：
```swift
import FoundationModels


let session = LanguageModelSession()
do {
    let response = try await session.respond(to: "What's a good name for a trip to Japan? Respond only with a title")
    
    print(response.content)
} catch {
    print(error)
}
```  

如果已经正确下载了模型，运行后会得到类似下面的结果：
```
Journey of the Rising Sun
```  

# 参考
- [misaka26](https://github.com/straight-tamago/misaka26/releases)  
- [Code-along: Bring on-device AI to your app using the Foundation Models framework](https://developer.apple.com/videos/play/wwdc2025/259/)