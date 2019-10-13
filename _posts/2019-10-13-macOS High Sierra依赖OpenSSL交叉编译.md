---
layout:     post
title:      "macOS High Sierra依赖OpenSSL交叉编译"
subtitle:   "Xcode"
date:       2019-10-13
author:     "Karim"
header-img: "img/post-bg-andre-benz.jpg"
tags:
- Mac
---



有些比较老的库，又是依赖 openssl，要自己编译成静态库的时候，遇到了这个错误：
```
configure: error: OpenSSL support explicitly requested but OpenSSL could not be found
```
如果打算通过`brew link openssl`软连接，会得到这个错误：  
```
Warning: Refusing to link macOS-provided software: openssl
```
后来查阅了一些资料，在 High Sierra 上，openssl 被 禁止通过 `brew link openssl` 软链接。


设置这几个环境变量就可以了：  
```shell
export LD_LIBRARY_PATH=/usr/local/opt/openssl/lib:"${LD_LIBRARY_PATH}"
export CPATH=/usr/local/opt/openssl/include:"${CPATH}"
export PKG_CONFIG_PATH=/usr/local/opt/openssl/lib/pkgconfig:"${PKG_CONFIG_PATH}"
```