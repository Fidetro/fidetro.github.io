---
layout:     post
title:      "Modify iPhone positioning via Virtual Location"
subtitle:   "iOS，Virtual Location，Magellan"
date:       2020-4-19
author:     "Karim"
header-img: "img/post-bg-andre-benz.jpg"
tags:
- iOS
- Xcode
---


# Installation:

Firstly, download [Virtual Location App](https://apps.apple.com/cn/app/%E8%99%9A%E6%8B%9F%E5%AE%9A%E4%BD%8D/id1459663647?mt=12) and [Magellan App](https://www.foolishtalk.org/magellan/magellan.pkg). It requires running both these two apps to modify the location.

The Virtual Location interface looks like this:
![](https://www.foolishtalk.org/cloud/guide_en_1.png)

1. If Magellan is not installed, when the virtual location is first started, it will appear::
![](https://www.foolishtalk.org/cloud/b7cdd9f10f727ca59420902b277aa9c8_en.png)  
Or, when double-clicking on the map, the following pop-up will appear：  
![](https://www.foolishtalk.org/cloud/14d2cba4eeda3d9fa77b1efd8a1aa6d9_en.png)  

2. Click on "Open Magellan Downloader",If Magellan is installed successfully,
there is an ico at system navigation bar as following after `Magellan App` running successfully.  
![](https://www.foolishtalk.org/cloud/bc9e8955850855ca07147e65957f8087.png) 

If `Magellan` installation fails, please download and install it separately from [here]((https://www.foolishtalk.org/magellan/magellan.pkg))

3.	Connect your iPhone/iPad to your Mac using a USB or USB-C cable, then choose your personal mobile.  
![](https://www.foolishtalk.org/cloud/d944f3a7aa0e20280cb65dff013839e6.png)

4.	If there is no installing the driver before, please click to `Install the driver `firstly.  
![](https://www.foolishtalk.org/cloud/0d0da9bb126e3bd24ebfb83bd16ef3c0.png)

5.	It will download the driver automatically for the first installing.  
![](https://www.foolishtalk.org/cloud/0fcda7c41ae4197d268c1a01bb2392a8.png)

6.	Please click `Install the Driver` again after download successfully. After installation successfully, there will be following tips.  
![](https://www.foolishtalk.org/cloud/15393a5bdbede13840e344e94f5d4946.png)

7.	It need to run `Magellan app` again after installation.

In iOS 16 and above, you need to enable developer mode to work.
First you need to `Activate developer mode` by clicking on Magellan.   
![](https://www.foolishtalk.org/cloud/MTY2NDYxOTAwOQ%3D%3D.png)  

And then go to iPhone/iPad Settings > Privacy & Security on the iOS device.Scroll down to the Developer Mode list item and navigate into it. To toggle Developer mode, use the “Developer Mode” switch.  
![](https://docs-assets.developer.apple.com/published/72b149b975624bfaf5f6fb577655b200/developer-mode-03~dark@2x.png)  

If you are interested, you can click [Learn more](https://developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device)  


# Operation:
1.	Open `Virtual Location App`  
There are two ways to modify the position as followings:  
(1)   
Select `Point`. Double click the map on `Virtual Location App`. Then you will find your position on mobile phone has already changed.  
![](https://www.foolishtalk.org/cloud/guide_en_1.png)
(2)   
① Select `Route`. Double click the map on `Virtual Location　App`. There will be generated multi-spots on the map as picture shows.  
![](https://www.foolishtalk.org/cloud/guide_en_2.png)

② Please input Speed and click `Start` finally. You will find your mobile phone is moving along programmed route.


If there are any questions, please feel free to contact me and send email to zykzzzz@hotmail.com. 
In most case, it is better to provide the log file will be helpful. Please click `Export log file` to generate the log file by `Magellan App`.
