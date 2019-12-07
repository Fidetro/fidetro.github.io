---
layout:     post
title:      "使用Magellan修改iOS定位"
subtitle:   "iOS，定位，Xcode"
date:       2019-12-4
author:     "Karim"
header-img: "img/post-bg-andre-benz.jpg"
tags:
- iOS
- Xcode
---

# 前言  

最初写的[虚拟定位](https://apps.apple.com/cn/app/%E8%99%9A%E6%8B%9F%E5%AE%9A%E4%BD%8D/id1459663647?mt=12)，需要依赖 Xcode 搭配使用，对用户使用造成很大的学习成本，但是由于沙盒机制，在AppStore下载没有办法做到。  

于是，我做了 Magellan 

# 正文  

Magellan 可以通过这里[下载](https://pan.baidu.com/s/14TwkfSDZRHjVNUvAmk5cXw)  提取码：jy4e  

[备用链接](https://media.githubusercontent.com/media/foolishtalk/Magellan/master/Magellan.dmg)，但是会很慢，可能要翻墙。


Magellan 的使用方式很简单，下载后，把 App 拖进 应用程序文件夹中，
![](http://images.foolishtalk.org/20191022225610.png)  
然后双击运行，就可以了。  
有可能会出现这个弹窗，直接打开就好了。  
![](http://images.foolishtalk.org/20191022105549.png)  

如果出现无法打开，因为无法确认开发者的身份的弹窗时，可以在`系统偏好设置-通用`下方找到，点击仍要继续运行即可。  

运行成功后，状态栏上方会出现一顶小帽子图标。  
![](http://images.foolishtalk.org/bc9e8955850855ca07147e65957f8087.png)  

首先手机要连接电脑，然后选择设备，然后再点击安装驱动，如果出现“安装成功”或者“可能已经安装过，无法再次安装”，可以跳过这一步。
如果等待超过2分钟没有反应，点击日志，会在桌面上生成一个“虚拟定位日志.txt”，可以通过邮箱zykzzzz@hotmail.com或者[微博](https://weibo.com/u/2095454814)联系到我，我会尽快帮你解决问题。


接下来，在使用虚拟定位的时候，只需要把手机连接上电脑，勾选键盘模式（目前这种方式仅支持键盘模式），双击虚拟定位App上的地图，就会发现手机上的定位已经被修改。
![](http://images.foolishtalk.org/f6f4ce34c5e2dfdb8d281c60950ea5c0.png)


# Q&A  
1. 拿来改定位（玩游戏/打卡）会不会被封？  
不要出现瞬移非常严重的情况，从目前技术手段上无法判定，所以可以放心使用。    

2. 提示“暂不支持 xx 版本，请联系作者升级”，怎么办？  
如果你之前已经安装过驱动了，就不需要管这个提示，依然可以正常使用，如果是从来没有安装过的，出现这个提示，请联系我，我会更新新的版本解决这个问题。  
