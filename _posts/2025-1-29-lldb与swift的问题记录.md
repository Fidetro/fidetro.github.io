---
layout:     post
title:      "lldb与swift的问题记录"
subtitle:   "swift、lldb"
date:       2025-1-29
author:     "Karim"
header-img: "img/post-bg-andre-benz.jpg"
tags:
- iOS
- Xcode
---

# 问题  
自从升级了Xcode 16之后，swift环境下使用po就会出现问题，报错如下：
```shell
error: type for self cannot be reconstructed: type for typename "$s17swift_lldb_module10ModuleViewCD" was not found
error: Couldn't realize Swift AST type of self. Hint: using `v` to directly inspect variables and fields may still work.
```

# 正文  
从日志信息可以看出，是因为lldb无法获取到类型信息，导致的问题。  

## 类型信息的作用是什么？
编译器提供的调试信息会告诉给调试器变量在内存中的位置,然后通过Types，lldb可以知道聚合类型源变量中的结构和内存布局，从而知道有哪些字段，并且通过Types使用数据格式化打印出更客观的格式出来。

## 类型信息从哪里来
在调试器端，用frame variable或v命令的时候，lldb从debug info和swift反射获取类型信息。
![](https://www.foolishtalk.org/cloud/swift_lldb002.jpeg)  
而在编译器端，用expr或po命令的时候，lldb通过Modules获取类型信息。  
![](https://www.foolishtalk.org/cloud/swift_lldb003.jpeg)  
Modules是编译器构建类型声明的方式。   
![](https://www.foolishtalk.org/cloud/swift_lldb001.jpeg)  
由此可见，应该是因为Modules导入失败，导致了lldb无法获取到类型信息。  
通过`swift-healthcheck`命令，可以用来诊断swift环境的问题，在运行po命令发送错误之后，执行`swift-healthcheck`命令:  
```shell
(lldb) swift-healthcheck
Health check written to /var/folders/c5/7j9s6knn0wvfdhfkz1pv67bh0000gn/T/lldb/5648/lldb-healthcheck-cad017.log
```
然后可以看到输出的日志:
```shell
SwiftASTContextForExpressions(module: "swift_lldb_module", cu: "Base64.swift")::LoadOneModule() -- Missing Swift module or Clang module found for "swift_lldb_module", "imported" via SwiftDWARFImporterDelegate. Hint: Register Swift modules with the linker using -add_ast_path.
SwiftASTContextForExpressions(module: "swift_lldb_module", cu: "Base64.swift")::LoadOneModule() -- Missing Swift module or Clang module found for "swift_lldb_module", "imported" via SwiftDWARFImporterDelegate. Hint: Register Swift modules with the linker using -add_ast_path.
```  
因此更加可以确定是Modules导入失败导致的问题。  


## 解决  
接下来要怎么解决这个问题已经很明显了，可以通过`-add_ast_path`来注册Swift模块，让lldb可以找到类型信息。  
如果是使用cocoapods，可以通过在Podfile中添加`post_integrate`脚本来解决这个问题。  
```ruby
post_integrate do |installer|
    #将swift-lldb-debug替换成你的target名字
    xcconfig_path = installer.sandbox.target_support_files_root.to_s + '/Pods-swift-lldb-debug/Pods-swift-lldb-debug.debug.xcconfig'

    xcconfig_content = File.read xcconfig_path
    xcconfig_original_ld_flags = xcconfig_content.match(/OTHER_LDFLAGS = ([^\n]+)\n/)[1]

    swift_module_flags = installer.pods_project.targets.map do |target|
           "-Wl,-add_ast_path,$(TARGET_BUILD_DIR)/#{target.name}/#{target.name}.swiftmodule/$(NATIVE_ARCH_ACTUAL)-apple-$(SHALLOW_BUNDLE_TRIPLE).swiftmodule"
    end.join(' ')

    xcconfig_new_ld_flags = <<~CONTENT

    OTHER_LDFLAGS = #{xcconfig_original_ld_flags} #{swift_module_flags}

    CONTENT

    xcconfig_content.gsub! /OTHER_LDFLAGS = ([^\n]+)\n/, xcconfig_new_ld_flags

    File.open(xcconfig_path, 'w') do |f|
      f.puts xcconfig_content
    end
end
```  
执行`pod install`之后，就可以在`Pods-xxx.debug.xcconfig`中看到通过`-add_ast_path`注册的swift模块。  
![](https://www.foolishtalk.org/cloud/swift_lldb004.png)  

```shell
这样就可以解决lldb无法获取类型信息的问题了，这里还有一个小插曲，如果你的项目是通过rosetta运行到模拟器上，还需要注册到x86_64的swift模块，可以将`$(NATIVE_ARCH_ACTUAL)`替换成这段手动指定不同架构上：  
```ruby
    swift_module_flags = installer.pods_project.targets.map do |target|      
      "-Wl,-add_ast_path,$(TARGET_BUILD_DIR)/#{target.name}/#{target.name}.swiftmodule/x86_64-apple-$(SHALLOW_BUNDLE_TRIPLE).swiftmodule -Wl,-add_ast_path,$(TARGET_BUILD_DIR)/#{target.name}/#{target.name}.swiftmodule/arm64-apple-$(SHALLOW_BUNDLE_TRIPLE).swiftmodule"
    end.join(' ')
```  




# 参考  
[Debug Swift debugging with LLDB](https://developer.apple.com/videos/play/wwdc2022/110370/)  
[Breakpoint issue: 'self cannot be reconstructed'](https://developer.apple.com/forums/thread/767051)