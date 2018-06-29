---
layout:     post
title:      "自己动手做Swift-Package-Manager"
subtitle:   "Swift，iOS，Swift Package Manager"
date:       2017-10-22
author:     "Fidetro"
header-img: "img/post-bg-old.jpg"
tags:
- Swift
- iOS
---
Swift Package Manager是苹果自家的包管理工具，他和iOS开发中的Cocoapod或者Carthage类似，但是我们可以从他[GitHub](https://github.com/apple/swift-package-manager)文档看到
```
Note that at this time the Package Manager has no support for iOS, watchOS, or tvOS platforms.
```
就是SPM是不支持  iOS, watchOS, or tvOS 平台，不过如果你想在不是mac OS的系统下使用swift，那就能用到SPM了。

建立一个以下的目录
```
example[这是个文件夹，起什么名字都行]
├── Sources[这是个文件夹，默认这个名字，里面放你需要生成库的.swift文件]
│   ├── Person.swift
│   ├── Cat.swift
│   └── Dog.swift
└── Package.swift[必须这个名字]
```

然后在Package.swift中写上依赖的内容
```swift
import PackageDescription

let package = Package(
    name: "exmaple" // 这里填你这个Package的名字
)
```
然后去github生成一个远程仓库，在example目录下
```swift
$ git init
$ git add *
$ git commit -m "SPM example"
$ git remote add origin git@github.com:xxx/example.git
$ git push -u origin master
$ git tag 1.0.0
$ git push --tags
```
这时候就可以新建一个目录测试是否成功了
```
$ mkdir test
$ cd test
$ vim Package.swift
```
在Package.swift中输入
```iswift
import PackageDescription

let package = Package(
    name: "test",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/xxx/example.git", 
majorVersion: 1)
        ]
)
```
在 test 目录下：
```
$ swift build
```
这时候应该看到提示成功了，到这里已经完成了 

## 附带一些自己踩过的坑
1. 如果example的目录下有很多别的文件夹，在`$ swift build`的时候有可能会出现这个错误
`package has unsupported layout; multiple source roots found:`

```
example
├── Sources
│   ├── Person.swift
│   ├── Cat.swift
│   └── Dog.swift
└── Package.swift
│── a[不需要参与编译的文件]
│── b[不需要参与编译的文件]
└── Package.swift
```
出现这个错误的时候example/Package.swift 需要这样写：
```swift
import PackageDescription

let package = Package(
    name: "exmaple", // 这里填你这个Package的名字
    exclude:["a","b"]
)
```
如果你这个库还依赖了别的库，还可以这样写：
```swift
import PackageDescription

let package = Package(
    name: "exmaple", // 这里填你这个Package的名字
	dependencies: [
		.Package(url: "https://github.com/depend/depend.git", majorVersion: 0)
	],
    exclude:["a","b"]
)
```

2. majorVersion只能是Int，我如果发布的不是整数tag怎么办？
可以换成选择版本范围，默认是根据当前范围最高的版本更新的
```swift
import PackageDescription
let package = Package(
    name: "test", 
	dependencies: [
		     .Package(url: "https://github.com/xxx/example.git",versions: Version(0, 0, 0)..<Version(1, .max, .max))]
	]
)
```

3. swift build了很久最后出现 error: reachedTimeLimit
这种情况我之前遇到过，具体是为什么导致当时没留意，但是你可以从这几个方面排查：  
   1. Package指定的版本是否有错
   2. 更新了新的版本，不能直接`$ swift build`需要：
```
$ rm -rf .build/
$ rm Package.resolved
```  
  3. dependencies是否有错
4. 如果有引入c文件还需要特殊处理，因为我还没试过，只是在看文档的时候发现有，如果工程中有使用可以去[Swift.org](https://swift.org/package-manager/)和[GitHub](https://github.com/apple/swift-package-manager)了解更多
