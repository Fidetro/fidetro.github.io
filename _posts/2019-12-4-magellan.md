---
layout:     post
title:      "使用虚拟定位修改iPhone定位"
subtitle:   "iOS，定位，Xcode，Magellan，虚拟定位"
date:       2019-12-4
author:     "Karim"
header-img: "img/post-bg-andre-benz.jpg"
tags:
- iOS
- Xcode
---

# 前言  

首先你需要通过Mac AppStore下载[虚拟定位(点这下载)](https://apps.apple.com/cn/app/%E8%99%9A%E6%8B%9F%E5%AE%9A%E4%BD%8D/id1459663647?mt=12)。
虚拟定位的界面如下：
![](https://www.foolishtalk.org/cloud/guide_zh_1.png)   

同时下载[Magellan(点这下载)](https://www.foolishtalk.org/magellan/magellan.dmg)，不然无法使用。

# 正文  

Magellan 的使用方式很简单，下载后，把 App 拖进 应用程序文件夹中，
![](https://www.foolishtalk.org/cloud/20191022225610.png)  
然后双击运行，就可以了。  
有可能会出现这个弹窗，直接打开就好了。  
![](https://www.foolishtalk.org/cloud/20191022105549.png)  

如果出现无法打开，因为无法确认开发者的身份的弹窗时，可以在`系统偏好设置-通用`下方找到，点击仍要继续运行即可。  

运行成功后，状态栏上方会出现一顶小帽子图标。  
![](https://www.foolishtalk.org/cloud/bc9e8955850855ca07147e65957f8087.png)  

首先手机要连接电脑，然后选择设备。  
![](https://www.foolishtalk.org/cloud/c81ff0aa45218b3cf8131ad8592eea96.png)
然后再点击安装驱动：  
![](https://www.foolishtalk.org/cloud/d762c75e8c2838d7f7bd7d1afff0c881.png)
如果出现：  
![](https://www.foolishtalk.org/cloud/2019_12_15_8.44.35.png)  
或者：  
![](https://www.foolishtalk.org/cloud/2019_12_15_8.46.55.png)  

##### 如果是首次安装驱动，记得要重新插拔一次手机，不然可能会没法识别。
如果等待超过2分钟没有反应，点击日志，会在桌面上生成一个“虚拟定位日志.txt”，可以通过邮箱zykzzzz@hotmail.com或者[微博](https://weibo.com/u/2095454814)联系到我，我会尽快帮你解决问题。


接下来，打开[虚拟定位](https://apps.apple.com/cn/app/%E8%99%9A%E6%8B%9F%E5%AE%9A%E4%BD%8D/id1459663647?mt=12)，把手机连接上电脑。

改定位的方式有两种：
1. 选中单点模式，双击虚拟定位App上的地图，就会发现手机上的定位已经被修改。
![](https://www.foolishtalk.org/cloud/guide_zh_1.png)   
2. 选中轨迹模式，直接双击地图，在地图上生成多个点，类似这样：
![](https://www.foolishtalk.org/cloud/guide_zh_2.png)  

然后输入速度，最后点击`开始移动`，你会发现手机正在按照规划的路线在移动。


# Q&A  
1. 显示“暂无可用设备”，找不到自己的设备怎么办？  
先通过 iTunes 检查手机是否连接成功，如果是旧版本的 iTunes 有可能会导致无法检测到设备，iTunes 需要更新到最新版本。  
  
2. 拿来改定位（玩游戏/打卡）会不会被封？  
不要出现瞬移非常严重的情况，从目前技术手段上无法判定，所以可以放心使用，但是也请勿用于违法/作弊行为，App的初心是用于平时开发测试定位移动。     
  
3. 提示“暂不支持 xx 版本，请联系作者升级”，怎么办？  
如果你之前已经安装过驱动了，就不需要管这个提示，依然可以正常使用，如果是从来没有安装过的，出现这个提示，请联系我，我会更新新的版本解决这个问题。  
  
4. 修改定位是所有App都有用吗？  
修改定位是全局的，整个App都会生效。   
  
5. 手机需要越狱吗？  
手机不需要越狱。   
  
6. 支持iPad吗？  
目前不支持，目前考虑到集成iPad驱动太大，所以暂不支持，以后考虑支持。 