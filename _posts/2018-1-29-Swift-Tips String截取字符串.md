---
layout:     post
title:      "Swift-Tips String截取字符串"
subtitle:   "Swift，Tips"
date:       2018-1-29
author:     "Fidetro"
header-img: "img/post-bg-sea.jpg"
tags:
- Swift-Tips
- Swift
---

在`Objective-C`中我们可以使调`substringWithRange`的方法达到截取字符串的效果

```
[@"123" substringWithRange:NSMakeRange(1, 2)];
```

在Swift 4之前，也是有类似的方法`"ss".substring(with: <Range<String.Index>>)`  ,但是在Swift 4之后被弃用了，我们可以通过用`extension`的方法去给他增加截取字符串的方法

```
extension String{
    func to(_ index:Int) -> String? {
        let toIndex = String.Index.init(encodedOffset: index)
        guard toIndex < self.endIndex else { return nil }
        return String(self[...toIndex])
        
    }
    func from(_ index:Int) -> String? {
        let fromIndex = String.Index.init(encodedOffset: index)
        guard fromIndex < self.endIndex else { return nil }
        return String(self[fromIndex..<self.endIndex])
    }
    func subString(_ from:Int,to:Int) -> String? {
        let toIndex = String.Index.init(encodedOffset: from)
        let fromIndex = String.Index.init(encodedOffset: to)
        guard toIndex < self.endIndex,
            fromIndex < self.endIndex,
            toIndex <= fromIndex else { return nil }
        return String(self[toIndex...fromIndex])
    }
}
```

现在又可以方便的截取字符串了
```
print("12345678".to(3)) //Optional("1234")  

print("12345678".from(3)) //Optional("45678")  

print("12345678".subString(3, to: 5))  //Optional("456")  
```

另外我们还可以结合Swift下标的特性，达到通过取字符串下标截取字符串   
```
extension String{
    subscript(index:Int) -> String? {
        return subString(index, to: index)
    }
    subscript (bounds: CountableClosedRange<Int>) -> String? {
        return subString( bounds.lowerBound, to: bounds.upperBound)
    }
    subscript (bounds: CountableRange<Int>) -> String? {
        return subString( bounds.lowerBound, to: bounds.upperBound)
    }   
}
```   

```
print("12345678"[2])  //Optional("3")  

print("12345678"[3...5])  //Optional("456")

print("12345678"[100])  //nil
```
