---
layout:     post
title:      "iOS模拟移动定位"
subtitle:   "Xcode，iOS，定位"
date:       2019-4-11
author:     "Karim"
header-img: "img/post-bg-andre-benz.jpg"
tags:
- iOS
- Xcode
---

# 前言  
在阅读这篇文章之前，先保证你必须符合以下几个条件：
- 有台Mac可以使用
- 有一定的编程经验（如果你愿意折腾，没有经验也是可以的）  


# 正文  
因为有太多人说看不懂了，所以我又录了个[视频](https://www.bilibili.com/video/av53629147)  

先打开Mac应用虚拟定位，可以看到以下的界面，可以在这里[下载](https://itunes.apple.com/cn/app/%E8%99%9A%E6%8B%9F%E5%AE%9A%E4%BD%8D/id1459663647?mt=12)，另外有什么App使用上的问题和建议，也可以来[微博](https://weibo.com/p/1005052095454814)私信我：  

![](http://images.foolishtalk.org/mock_location_12.png)

1. 双击选择你要定位的位置点；
2. 在左上角填速度，每个点之间移动的速度会根据这个速度移动；
3. 右上角保存会生成出一个gpx文件；

先用Xcode新建一个工程，按照以下步骤操作，Xcode可以在App Store[下载](https://itunes.apple.com/cn/app/xcode/id497799835?mt=12)：    

![](http://images.foolishtalk.org/mock_location_2.png)  

1. 选择创建iOS App：  
![](http://images.foolishtalk.org/mock_location_3.png)  
2. 输入工程名，`Organization Name`随便填就可以了，`Organization Identifier`填"com.xxx.xxx"，xxx替换成任意英文即可：  
![](http://images.foolishtalk.org/mock_location_4.png)  
3. 按照以下步骤，选择工程，然后添加账号，这里填你苹果账号：  
![](http://images.foolishtalk.org/mock_location_5.png)  
4. 把手机连到Mac上，然后选中你的手机，如果没有看到你的手机，可以打开iTunes看看手机是否有连接，如果也没有，拔掉线重新连，应该会看到iTunes有个弹窗，点击信任此电脑，手机上也需要点击信任此电脑：  
![](http://images.foolishtalk.org/mock_location_8.png) 
5. 输入你手机iOS系统的版本，这里代表可以运行的最低版本，例如你是iOS 10.2，输入10就可以了：  
![](http://images.foolishtalk.org/mock_location_11.png) 
6. 下载[虚拟定位](https://itunes.apple.com/cn/app/%E8%99%9A%E6%8B%9F%E5%AE%9A%E4%BD%8D/id1459663647?mt=12)，然后按照你想模拟的路径双击地图，按保存会生成一个GPX文件，把生成的GPX文件拖进去工程目录中：  
![](http://images.foolishtalk.org/mock_location_6.png)  
![](http://images.foolishtalk.org/mock_location_7.png)  

7. 点击运行，首次运行可能会弹出需要信任证书的提示，这时候点击手机的设置-通用-描述文件与设备管理-「找到自己的开发证书」-点击信任，再重新运行一遍：  
![](http://images.foolishtalk.org/mock_location_9.png)  
8. 选中你拖进去gpx文件名字的选项：  
![](http://images.foolishtalk.org/mock_location_10.png)  
9. 这时候你会发现定位已经改变了，但是要注意，这时候手机和Mac是不能断开连接的，以及运行的App不能被杀死，否则定位修改都会失败。