---
layout:     post
title:      "swift使用protocol的时候出现循环引用"
subtitle:   "Swift，iOS，Protocol"
date:       2017-12-7
author:     "Karim"
header-img: "img/post-bg-old.jpg"
tags:
- Swift
- iOS
---
在给Alamofire用protocol封装一层业务的时候，定义了以下的协议和方法
```swift
protocol BaseRequest {
}
extension FIDRequest {
    func complete(_ completionHandler: @escaping ((DataResponse<Any>) -> ())) {
        let url = baseURL()+requestURI()
            Alamofire.request(url, method: method(), parameters: parameters(), encoding: encoding(), headers: headers()).responseJSON(completionHandler: completionHandler)
    }
}

protocol Request {

}

extension Request {
    func request() -> WBBaseRequest {
            complete {  (response)  in
//这里还有段代码造成循环引用
            }
       }
}
```
这时候问题就来了，正常情况下，应该使用`[weak self]`就可以解决了，但是在使用`protocol`的时候，是无法使用`[weak self]`的，然后就会有以下的报错
`'weak' may only be applied to class and class-bound protocol types, not 'Self'`
```swift
    func request() -> WBBaseRequest {
            complete {  (response) [weak self]  in //这个地方会报错 'weak' may only be applied to class and class-bound protocol types, not 'Self'
//这里还有段代码造成循环引用
            }
       }
```

直接解决这个问题的方式是，将 `BaseRequest`声明为只有类才可以使用
```swift
protocol BaseRequest : class {
}
```
然后就可以愉快的使用`[weak self]`

总结：
`weak`只能用在类或者类的协议中，如果在协议扩展中使用了类而造成了循环引用，协议就需要指定必须是`class`才可以使用，`struct`和`enum`是不会造成循环引用的
参考链接： 
[Why can the keyword “weak” only be applied to class and class-bound protocol types](https://stackoverflow.com/questions/38841127/why-can-the-keyword-weak-only-be-applied-to-class-and-class-bound-protocol-typ)
 [How can I make a weak protocol reference in 'pure' Swift (w/o @objc)](https://stackoverflow.com/questions/24066304/how-can-i-make-a-weak-protocol-reference-in-pure-swift-w-o-objc)

