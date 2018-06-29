---
layout:     post
title:      "用Swift打造一个轻量级POP的网络请求库"
subtitle:   "Swift，Tips，Alamofire"
date:       2018-3-9
author:     "Fidetro"
header-img: "img/post-bg-sea.jpg"
tags:
- Swift-Tips
- Swift
---
我从`Objective-C`转到`Swift`已经有好些时间了，`Swift`起码在iOS开发这块，开源组件已经很完善，为什么还要再造轮子呢？  
> 目的只有一个，为了简化对业务层的操作。  
事实上，在写这篇文章的时候，这个[轮子](https://github.com/Fidetro/PSea)已经做好了,所以来聊聊他做了什么：  
在`Objective-C`时候我所遇到很多网络层都是这样的结构:
```objc
 ______________
|              |
| AFNetWorking | 
|______________|
        |
        |
        v
 ______________
|              |
|  APIManager  | 
|______________|
        |
        |
        v
 ______________
|              |
|  Controller  | 
|______________|        
```

然后APIManager只管请求，然后回调都在Controller上处理
```objc
successHanlder:^(NSDictonary *dict){
//转模型   
Model *model = [Model jsonToModel:dict];
if (model.errorCode == 0) {
    //数据加工  
    //刷新页面  
}else{
    //处理错误  
    //错误显示  
}

} errorHanlder:^(NSDictionry *dict,NSError *error){

};

```
总结一下关于业务层能抽象出来的部分有哪些呢？  
1. 判断数据是否正确
2. 转成数据模型
3. 处理业务错误
4. 错误提示  

知道要解决的问题之后，剩下就是怎么去解决了，还在用`Objective-C`的时候，使用过`YTKNetwork`，`YTKNetwork`是用继承解决的，但是`Swift`中更推荐使用`protocol`和`extension`这套组合拳来解决问题。

`PSea`如果说是网络请求库可能不太准确，它更像是一种思想，它依赖`Alamofire`,介于网络层和业务通用层之间的媒介。在这基础上，我给他增加了链式，让他更加Swiftly一点。

1. 基本设置  

```swift
public protocol PSea: class {

    /// 请求方式
    func method() -> HTTPMethod
    /// 设置域名
    func baseURL() -> String
    /// 请求路由
    func requestURI() -> String
    /// 请求参数
    func parameters() -> Parameters?
    /// 请求头
    func headers() -> HTTPHeaders?
    /// 参数编码
    func encoding() -> ParameterEncoding
    
}
```

这部分是http最基本的支持，用法如下：
```swift
    public func headers() -> HTTPHeaders? {
        return ["Content-type":"application/json",
                "Accept":"application/json"]
    }
    func baseURL() -> String {
        return "http://localhost:23333"
    }
    public func parameters() -> Parameters? {
        return ["hello":"world"]
    }
```

```swift
    func complete(_ completionHandler: @escaping ((DataResponse<Any>) -> ()))
```
`    func complete(_ completionHandler: @escaping ((DataResponse<Any>) -> ()))`是和`Alamofire`接触，实现请求的方法
```swift
    func successParse(response: DataResponse<Any>)
    func errorParse(response: DataResponse<Any>)
    func failureParse(response:DataResponse<Any>,error: Error)
 ```  

这三个是`protocol`中的接口，需要遵循`PSea`的类去解析  
整个`PSea`目前100行代码不到，因为`PSea`只提供了把`Alamofire`的用法转成的POP，具体涉及业务层是需要通过遵循`PSea`再衍生出一个业务类，还是废话少说，上代码。

就拿我个人项目来讲
```swift

public protocol PetRequest : PSea {
   /// 是否需要token
    func needToken() -> Bool
    /// 请求参数
    func petParameters() -> Parameters?
}
```
`func needToken()`和`func petParameters()`都是对外需要重写的，可以先不管  
接下来是把`PSea`需要重写的接口，实现
```swift
extension PetRequest {
    public func headers() -> HTTPHeaders? {
        return ["Content-type":"application/json",
                "Accept":"application/json"]
    }
    func baseURL() -> String {
        return "设置域名"
    }
    public func parameters() -> Parameters? {
        //对参数进行处理
        let params = petParameters()    
    
        return params
    }
    
    public func encoding() -> ParameterEncoding {
        if method() == .get {
            return URLEncoding(destination: .methodDependent)
        }else{
            return JSONEncoding.default
        }
    }
    
    //成功结果的解析
    func successParse(response:DataResponse<Any>){
        guard let value = response.result.value as? [String:Any],
            let _ = value["errcode"] as? Int else{
                return
        }
        if let handler = self.successHandler {
            handler(response,value)
        }else{
            //成功不处理
        }
    }
    //请求成功，但结果不是我们需要的解析
    func errorParse(response:DataResponse<Any>){
        guard let value = response.result.value as? [String:Any],
            let code = value["errcode"] as? Int else{
                return
        }
        let errmsg = value["errmsg"] as? String
        guard code == 0 else {
            if let handler = self.errorHandler {
                handler(response,code,errmsg ?? "")
            }else{
                //不处理的时候会提示
                SVProgressHUD.showError(withStatus: errmsg ?? "")
            }
            return
        }
    }
    //网络错误的解析
    func failureParse(response: DataResponse<Any>, error: Error) {
        guard let _ = response.result.value as? [String:Any] else{
            if let handler = self.failureHandler {
                handler(response,error)
            }else{
                //TODO: 提示请求超时
                SVProgressHUD.showError(withStatus: "网络连接超时")
            }
            return
        }
    }
}

```

这样就通过`PSea`设计好了一个简单的POP网络请求库，再举一个简单的登录api使用例子：
```swift
class LoginApi: PetRequest {

    var username : String = "xxx"
    var password : String = "xxx"
    var successHandler: SccuessCallBack?    
    var errorHandler: ErrorCallBack?
    var failureHandler: FailureCallBack?

    func needToken() -> Bool {
        return false
    }

    func petParameters() -> Parameters? {
        return ["username":username,
                "password":password]
    }
    
    func method() -> HTTPMethod {
        return .post
    }
    
    func requestURI() -> String {
        return "/petday/login"
    }
  
}

//使用例子
        LoginApi().request().success { (_, value) in
            
            }.failure { (_, _, _) in
                
                
            }.error { (_, _, _) in                
                
        }

//然后又因为failure和error都已经经过业务层做处理了，不是特殊情况下，不需要额外做处理，又可以简写成
        LoginApi().request().success { (_, value) in
            
            }
```  

另外如果需要将成功的结果返回的时候转成对象，
首先在处理
```swift
func successParse(response: DataResponse<Any>) {
           guard let value = response.result.value as? [String:Any] else{
                return
        }
    //经过处理一系列结果
    //...
    //...
    let modelJSON =  //...需要转换成对象的合法JSON字典
        if let handler = self.successHandler {
            handler(modelJSON,value)
        }
}
```
然后可以写成这样:
```swift
ListApi().request().success(ListModel.self) { (model,value) in

}
```  


