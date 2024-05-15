---
layout:     post
title:      "appstore-server-api使用"
subtitle:   "StoreKit，appstore-server"
date:       2024-5-15
author:     "Karim"
header-img: "img/post-bg-andre-benz.jpg"
tags:
- iOS
- Xcode
---

# 前言  
前段时间有用户要求我退款，实际上退款只能由用户发起退款，苹果审核通过就可以了，开发者并没有权限处理退款。  
但是用户把订单号发我了，我也很好奇开发者能否查到相关的订单信息，因此我去折腾了一下，先说一下结论：  
###### 如果是用户是购买App产生的订单号，苹果并没有提供对应的能力给开发者查询。
###### 如果是用户是在App内购产生的订单号，那么可以通过AppStore-Server-API查询相关的信息。  

# 正文  
首先用户会向我们提供`orderId`，如下：
![](https://www.foolishtalk.org/cloud/82a4811eb5cc97db549425e0270847a8.png)  
但是我们会发现，苹果的API大多数都是需要通过`transactionId`，而不是`orderId`，幸好苹果提供了[API](https://developer.apple.com/documentation/appstoreserverapi/look_up_order_id)给我们可以通过`orderId`去查`transactionId`。  

苹果的接口文档写的很复杂，建议是通过他们已经封装好的框架进行调用，目前已经有Swift、Java、Python、Node。在[这里](https://developer.apple.com/documentation/appstoreserverapi/simplifying_your_implementation_by_using_the_app_store_server_library)可以获取到对应语言的框架。  

我这里也写了一个简单的demo调用可以[参考](https://github.com/Fidetro/appstore-server)
```swift  
func fromUser() async {

    let issuerId = "xxx-xxx-xxx-xxx-xxx"
    let keyId = "xxx"
    let bundleId = "com.karim.xxx"

    let encodedKey = try! String(contentsOfFile: "/appstore-server/appstore-server/XXXX.p8")
    let environment = Environment.production
    let client = try! AppStoreServerAPIClient(signingKey: encodedKey, keyId: keyId, issuerId: issuerId, bundleId: bundleId, environment: environment)

    let response = await client.lookUpOrderId(orderId: "XXXXXX")
    switch response {
    case .success(let response):
        print(response)
    case .failure(let errorCode, let rawApiError, let apiError, let errorMessage, let causedBy):
        print(errorCode)
        print(rawApiError)
        print(apiError)
        print(errorMessage)
        print(causedBy)
    }
}

await fromUser()
```

上面代码中的issuerId、keyId、p8密钥，需要在[appstoreconnect](https://appstoreconnect.apple.com/)中自己生成，bundleId填入对应app的bundleId即可。
![](https://www.foolishtalk.org/cloud/7b5ffc11e32b3e5c1c8b2c21d2384bea.png)
