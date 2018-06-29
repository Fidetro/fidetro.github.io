---
layout:     post
title:      "RxSwift从入门到放弃——开篇"
subtitle:   "Swift,RxSwift"
date:       2018-5-6
author:     "Fidetro"
header-img: "img/post-bg-unsplash.jpg"
tags:
- RxSwift
- Swift
---

# 前言  
最近正好在刚好被安排到用RxSwift开发一个小项目，借着这个机会学习了一下。在这之前也有断断续续用了几次，最后总会因为各种各样的Xcode问题弃坑，感觉能坚持下来真的是真爱啊。。主要学起来就是两个问题：  
- Xcode的自动补全十分不友好
- RxSwift学习曲线陡峭   

自动补全的问题对刚入门的时候来说，真的影响很大，一开始对RxSwift的不了解，看了下网上的资料，准备大干一场的时候，写着写着，突然没补全，然后怀疑自己是不是哪里写错了，把网上的代码复制过来，又可以了，体验极其的差...  
   
在学习RxSwift的时候，或者本来就有看过相关的资料，肯定会对下面这张图的名词有所听闻。  

![](http://images.foolishtalk.org/rxswift-know.png)
 

不了解的同学看完应该是这样的表情的：  
![](http://images.foolishtalk.org/black_question.png)  

看不懂没关系，看完这个系列的文章之后，就会懂了。  

# 疑问  
在学RxSwift之前，先提个问题，为什么要学习RxSwift？  
这段是从RxSwift文档翻译过来的回答  
- 可组合，因为Rx就是这个意思  
- 可复用，因为它是可组合的  
- 清晰，因为声明都是不可变的，改变的只有数据  
- 容易理解和简洁
- 稳定  
- 没有状态，因为RxSwift将应用程序建模为单向数据流  
- 不会有内存管理问题，因为内存管理变得简单  

总结：使用RxSwift可以简化代码，用更少而且清晰的代码，更专注于关心事件变化的本身  

说了这么多，RxSwift其实到底干了什么？
RxSwift将监听变化的`事件`封装成了可观察的`序列`，因此在编程的时候，通过框架已经帮我们创建好的序列或者自己创建的序列，实现对序列的监听，只关心序列的变化。
>   注  
可观察的事件：例如scrollView的contentOffset变化，textField每次输入时候变化的text等  
序列：一个可被观察的对象，后面会详细讲到。    

# 正文

讲了这么多，talk is cheap,show me the code.  

监听collectionView的contentOffset，没有引入RxSwift的时候，我们需要实现以下方法：  
```swift  
 func scrollViewDidScroll(_ scrollView: UIScrollView) {
     //...
 }
```

引入RxSwift之后
```swift  
    let disposeBag = DisposeBag()


       collectionView.rx
                    .contentOffset
                    .subscribe(onNext: { (point) in
            //do something
        }).disposed(by: disposeBag)
```
>   注  
disposeBag负责管理生命周期，相当于将当前的监听交给了disposeBag，大部分情况下disposeBag由Controller持有，并随控制器生命周期结束而结束  

KVO:  
```swift
view.rx.observe(CGRect.self, "frame")
    .subscribe(onNext: { frame in
        print("Got new frame \(frame)")
    })
    .disposed(by: disposeBag)
```  

Target-Action:  
传统的实现方法:

```swift
    lazy var button: UIButton = {
        var button = UIButton()
        button.addTarget(self, action: #selector(click), for: .touchUpInside)
        return button
    }()
    
    @objc func click() {
        // do something
    }
```

```swift
button.rx
    .controlEvent(.touchUpInside)
    .subscribe(onNext: {  () in
    //..touchUp

        }).disposed(by: disposeBag)

```  

上面的都是简单的例子应用，下面直接用登录功能举例示例代码，[代码](https://github.com/Fidetro/rx-sample-code)已经传到GitHub上了。  
要实现的功能：点击按钮的时候，判断用户名和密码是否合法，然后请求，拿到结果。
1. 创建一个ViewModel  
```swift
class LoginViewModel: NSObject {
    //由Controller负责订阅loginResult，得到登录结果
    let loginResult: Observable<Bool>
}
```  
2. 初始化loginResult     
```
    init(input: (username: Observable<String>, password: Observable<String>, touchUp: ControlEvent<()>)) {
        //将username和passowrd变形为Observable<(String,String)>
        let usernameAndPassword = Observable.combineLatest(input.username, input.password) {
            ($0, $1)
        }
        //初始化loginResult对象
        loginResult = input.touchUp.withLatestFrom(usernameAndPassword).flatMap { (username,password) -> Observable<Bool> in  

            //简单的对用户名和密码做校验
            guard  username.count > 6 else{
                return Observable.just(false)
            }

            guard  password.count > 6 else{
                return Observable.just(false)
            }

            return Observable.create { (observer) -> Disposable in
                //延时1s模拟异步请求登录成功
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                    observer.onNext(true)
                })
                return Disposables.create {}
            }
        }        
    }
```  
3. 在Controller监听点击后登录的结果：  
```swift
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewModel = LoginViewModel.init(input: (username: usernameTextField.rx.text.orEmpty.asObservable(),
                                                    password: passwordTextField.rx.text.orEmpty.asObservable(),
                                                    touchUp: loginButton.rx.controlEvent(.touchUpInside)))
        
        viewModel.loginResult.subscribe(onNext: { (result) in
            if result == true {
                print("登录成功")
            }else{
                print("登录失败")
            }
        }).disposed(by: disposeBag)
    }
```  

这样一个登录功能就基本完成了，相信看完上面的代码，肯定也会有很多疑问。  

1. `Observable.just(...)`和`Observable.create { }`是干什么用的？   
这些方法都是拿来将对象包装成可观察的序列，更多的构建方法可以参考[这里](https://beeth0ven.github.io/RxSwift-Chinese-Documentation/content/decision_tree.html)  

2. `observer.onNext(...)`又是干什么用的？  
observer是`AnyObserver<...>`类型，当使用`Observable.create { }`创建序列的时候，闭包内会返回`AnyObserver<...>`对象,`AnyObserver<...>`对象允许你通过`.onNext(...)`发出一个元素，`onError(...)`发出一个错误，`onCompleted()`通知任务已经完成。

# 参考  
[RxSwift官方文档](https://github.com/ReactiveX/RxSwift/blob/master/Documentation/Why.md)  
[RxSwift中文文档](https://beeth0ven.github.io/RxSwift-Chinese-Documentation/)

