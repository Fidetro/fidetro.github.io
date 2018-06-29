---
layout:     post
title:      "更新自己的CocoaPods库"
subtitle:   "CocoaPod，iOS"
date:       2017-06-21
author:     "Fidetro"
header-img: "img/post-bg-old.jpg"
tags:
- 问题随笔
- iOS
---




以自己写的一个库为例子

```ruby
Pod::Spec.new do |s|

  s.name         = "FFDB"
  s.version      = "1.7.0"
  s.summary      = "easy to use FMDB"
  s.homepage     = "https://github.com/Fidetro/FFDB"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "fidetro" => "zykzzzz@hotmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/Fidetro/FFDB.git", :tag => "1.7.0" }
  s.source_files  = "FFDB", "FFDB/*.{h,m}"
  s.library = 'sqlite3'
  s.dependency "FMDB","~> 2.6.2"


end

```
原本在CocoaPods的版本是`s.version = "1.7.0"`
如果要更新成`1.8.0`版本，先改成`s.version = "1.8.0"`
同时把`s.source`的tag改成` s.source       = { :git => "https://github.com/Fidetro/FFDB.git", :tag => "1.8.0" }`
```
git add *
git commit -m "tag 1.8.0"
git push origin -u master
```

再打上标签
```
git tag 1.8.0
git push --tags
```
最后提交到Pod
```
pod trunk push FFDB.podspec
```
