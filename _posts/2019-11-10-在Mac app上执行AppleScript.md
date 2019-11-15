---
layout:     post
title:      "在Mac app上执行AppleScript"
subtitle:   "Xcode，iOS，定位"
date:       2019-11-10
author:     "Karim"
header-img: "img/post-bg-andre-benz.jpg"
tags:
- Mac
- Xcode
---

# 前言  

前段时间我开发了[虚拟定位](https://itunes.apple.com/cn/app/%E8%99%9A%E6%8B%9F%E5%AE%9A%E4%BD%8D/id1459663647?mt=12)，一脚踩进了`AppleScript`的坑里无法自拔。  

# AppleScript  
`AppleScript`它是什么？  

`AppleScript`它是苹果提供在Mac OS上实现自动化的脚本语言，语法相对简单、易懂，类似英语语法。下面这段代码，你可以通过 Mac 自带的脚本编辑器运行：  
![](http://images.foolishtalk.org/apple-script-editor-1.png)

运行后它会打开 iTunes ：  
```shell
tell application "iTunes"
	play
end tell
```  

这三行可以简单的理解为：  
```shell
告诉 iTunes
    播放
结束
```  
`tell application "xxx"` 如果你是想让微信 App做点什么，就是`tell application "微信"`,而`play`这个事件，是iTunes独有的，怎么能知道app特有的事件？你可以通过`脚本编辑器`的导航栏中按照以下步骤找到：  
![](http://images.foolishtalk.org/apple-script-editor-2.png)  
然后选择`iTunes`:  
![](http://images.foolishtalk.org/apple-script-editor-3.png)   
这里可以看到关于play事件的一些描述。  
在编写Mac app之前，可以先通过脚本编辑器把我们想实现的功能调试好，然后再把脚本移到Mac app上，确保脚本是正确的，而不是因为App沙盒、权限等问题引起。  

# System Events  
上面已经说到，可以通过`tell application "xxx"`这种方式去调用 App 允许的行为，如果你看完了上面的介绍，打算自己动手去做一些 App 自动化的事情，你会发现 App 提供的事件很少，甚至有可能没有，所以接下来讲的是 `System Events` , `System Events` 为我们提供了系统事件，允许我们模拟用户点击行为，可以说所有用户界面相关的操作，你都可以通过 `System Events` 去进行自动化操作。  

下面这一段就是通过 `System Events` 启动 `Safari` 然后通过菜单栏的选项卡，新建标签页。
```shell
tell application "Safari"
	# 打开Safari
	activate
	tell application "System Events"
		tell process "Safari"
			# 点击Safari菜单栏-文件-新建标签页
			click menu item "新建标签页" of menu 1 of menu bar item "文件" of menu bar 1
		end tell
	end tell
end tell
```

 
# Mac App 调用 AppleScript 的方式  


通过 `NSAppleScript` 运行以下代码：

```Swift
        let source = """
tell application "Safari"
    # 打开Safari
    activate
    tell application "System Events"
        tell process "Safari"
            # 点击Safari菜单栏-文件-新建标签页
            click menu item "新建标签页" of menu 1 of menu bar item "文件" of menu bar 1
        end tell
    end tell
end tell
"""
        let script = NSAppleScript(source: source)!
        var error : NSDictionary?
        script.executeAndReturnError(&error)
        print(error)
```

预期结果是正常的，但是会发现打印出了这样的错误：  
```
2019-09-22 21:15:30.094229+0800 SwiftAppleScript[1453:42847] skipped scripting addition "/Library/ScriptingAdditions/SASyphonInjector.osax" because it is not SIP-protected.
Optional({
    NSAppleScriptErrorAppName = "System Events";
    NSAppleScriptErrorBriefMessage = "Not authorized to send Apple events to System Events.";
    NSAppleScriptErrorMessage = "Not authorized to send Apple events to System Events.";
    NSAppleScriptErrorNumber = "-1743";
    NSAppleScriptErrorRange = "NSRange: {168, 69}";
})
```  

这个地方非常的坑，如果没有打印`error`,在没有打开`App Sanbox`的情况下，是有可能预期效果是正常的，Safari能正常打开然后新建标签页。

如果之前是做iOS开发的，对这个错误应该会很自然的有头绪，应该就是一些权限问题，直接在Info.plist上就能找到一个看起来是这个权限的字段，`Privacy - AppleEvents Sending Usage Description`，把这个字段加上后，重新运行，发现多出了这个弹窗：  
![](http://images.foolishtalk.org/2019-09-28.4.55.09.png)
如果能够正常运行，那恭喜你，说明你没有打开`Capabilities`->`App Sanbox`
![](http://images.foolishtalk.org/2EE70BF91F39368ACF74DD225DEF0EE0.png)

# 为什么要打开App Sanbox？  

Mac OSX在10.6系统之后，为了防止恶意的App通过系统漏洞攻击系统，获取控制权限，要求上架的所有的App，都必须要开启沙盒。不要以为App安全离我们很远，Mac App一不留神就有可能被利用，System Events 就可以做到这个事情。  

讲回正题，当我们把 `App Sanbox` 打开后，新的报错又来了：  
```
Optional({
    NSAppleScriptErrorAppName = Safari;
    NSAppleScriptErrorBriefMessage = "Application isn’t running.";
    NSAppleScriptErrorMessage = "Safari got an error: Application isn’t running.";
    NSAppleScriptErrorNumber = "-600";
    NSAppleScriptErrorRange = "NSRange: {45, 8}";
})
```
![](http://images.foolishtalk.org/2019110_IMG_2412.png)  

这次是提示 `Safari` 没有运行，我们的代码里已经加了让 `Safari` 唤醒的功能了，这说明这段代码没办法执行，既然没有解决，只能靠 google 了。

在查阅了一大波资料后，在 `App.entitlements` 加上这个 `com.apple.security.temporary-exception.apple-events` 权限就可以了。  


到这里为止，一切正常的。  
在虚拟定位加入这个权限的第一个版本，上架也非常顺利，但是这之后更新的一个版本，仅涉及一些UI细节的修复，收到苹果拒审的邮件，内容如下：  
```
我知道你要使用 com.apple.security.temporary-exception.apple-events 干嘛，
但是我不能给你用，要么你就去掉这个功能，要么你要自己找别的方式去实现。
```  

既然不给我用，为什么上个版本还能给我上架成功？？？

![](http://images.foolishtalk.org/2019110_IMG_2412.png)

这个方法不行，只能另外再找方法了。

从苹果的[文档](https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/EntitlementKeyReference/Chapters/EnablingAppSandbox.html#//apple_ref/doc/uid/TP40011195-CH4-SW25)可以找到怎么通过 `AppleScript` 调用其他 App 功能的资料，苹果在文档中给我们举了个例子，如果要用 `Mail.app` 的邮件编写功能，可以在 `App.entitlements` 加上一下的权限：
```
<key>com.apple.security.scripting-targets</key>
    <dict>
        <key>com.apple.mail</key>
        <array>
            <string>com.apple.mail.compose</string>
        </array>
    </dict>
```

这样就可以使用`com.apple.mail.compose`这个访问组下的权限了，这个访问组下的权限，可以通过以下的命令看得到：
```shell
sdef /Applications/Mail.app > ~/Desktop/mail.xml
```

但是 Xcode 本身并没有提供一个可以修改定位的访问组权限给到我们，所以并不能使用以上的方法去解决。

这时候不禁会想到，`System Event` 能做什么呢，为什么苹果会不允许我们使用这个权限？对此我又对这个权限有了一个更深入的了解。

# 思考  

System Events其实是一个系统App，提供控制Mac OSX GUI和应用之间的交互，在这个路径下你可以找到`/System/Library/CoreServices/System Events.app`。   
通过System Events，我们可以做到以下这些东西：  
- 获取正在运行的App列表
- （得到/点击）任意一个正在运行App中的UI元素
- （打开/移动/删除）文件
- ...

等等...这不就是等于能远程监控和控制别人的电脑吗？  
所以苹果不开放这个权限也是有原因，既然这样，也只能找别的方法看看了。  
苹果不允许开发者动态调用`AppleScript`，但是可以调用 App 沙盒里的 `Application Scripts` 目录下的文件。
最终虚拟定位采用的方案也是这个，在`Info.plist`加上`NSAppleEventsUsageDescription`,并且通过弹窗引导用户把控制Xcode的脚本保存在`Application Scripts`目录下：
```Swift
FileManager.default.urls(for: .applicationScriptsDirectory, in: .userDomainMask)
```

最终，总算顺利上架成功了。  

# 总结  
App的沙盒机制，给用户带来了安全保障，但是也给开发者带来了很多开发上的困难，同时也一定程度上会增加用户在使用上带来不好的体验。  
如果你也想开发一款App并且上架AppStore，但是要依赖一个不是自己开发的App，大部分非Apple的App，都不会提供AppleScript的相关接口给到第三方使用，把applescript放在`Application Scripts`目录下使用是目前唯一能上架成功的方式。