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
先打开Mac应用虚拟定位，可以看到以下的界面，可以在这里下载（应用还在审核，审核完再补链接）：  

![](http://images.foolishtalk.org/mock_location_1.png)

1. 双击选择你要定位的位置点；
2. 在左上角填速度，每个点之间移动的速度会根据这个速度移动；
3. 右上角保存会生成出一个gpx文件；

先用Xcode新建一个工程，按照以下步骤操作，Xcode可以在App Store下载：    

![](http://images.foolishtalk.org/mock_location_2.png)  

1. 选择创建iOS App：  
![](http://images.foolishtalk.org/mock_location_3.png)  
2. 输入工程名：  
![](http://images.foolishtalk.org/mock_location_4.png)  
3. 按照以下步骤，选择工程，然后添加账号，这里填你苹果账号：  
![](http://images.foolishtalk.org/mock_location_5.png)  
4. 把刚刚生成的GPX文件拖进去工程目录中：  
![](http://images.foolishtalk.org/mock_location_6.png)  
![](http://images.foolishtalk.org/mock_location_7.png)  
5. 把手机连到Mac上，然后选中你的手机：  
![](http://images.foolishtalk.org/mock_location_8.png)  
6. 点击运行：  
![](http://images.foolishtalk.org/mock_location_9.png)  
7. 选中你拖进去gpx文件名字的选项：  
![](http://images.foolishtalk.org/mock_location_10.png)  
8. 这时候你会发现定位已经改变了，但是要注意，这时候手机和Mac是不能断开连接的，以及运行的App不能被杀死，否则定位修改都会失败。