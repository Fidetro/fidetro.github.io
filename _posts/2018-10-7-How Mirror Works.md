---
layout:     post
title:      "How Mirror Works"
subtitle:   "iOS，Swift，Mirror"
date:       2018-10-7
author:     "Fidetro"
header-img: "img/post-bg-ismael.jpg"
tags:
- iOS
- Swift
---

Swift非常重视静态类型，但它也支持丰富元数据的类型，这允许代码在运行时检查和操作任意值。这是通过`Mirror`API向Swift程序员公开。有人可能会想，`Mirror`究竟是怎样在一个如此重视静态类型的语言中工作的？让我们来看看！  

# 免责声明  
这里都是内部实现的细节。截至撰写本文时，是根据最新的代码写的，但可能会发生变化。（译注：这里指的是2018年9月26日之前）当ABI稳定的时候，元数据将成为一种可靠的格式，但现在依然可能发生改变。如果你在编写正常的Swift代码，请不要依赖这个类的代码。如果您正想要编写比Mirror提供的更复杂的反射的代码，这会给你一个起点，但是在ABI稳定之前，你需要保持持续更新（你的代码）。如果你想使用`Mirror`本身的代码，这会让你很好的理解到它们是如何组合起来的。但是记住，它可能会发生变化。  

# 接口  
`Mirror(reflecting:)`初始化接受一个任意值。生成的`Mirror`实例提供该值的信息，主要是它的子项，一个由子项组成的值和可选的标签。你可以使用`Mirror`去遍历整个对象，不需要在编译时知道它是什么类型。  
`Mirror`允许类通过符合`CustomReflectable`提供自定义表示。这在你想要返回比内省类型更好的类型的时候很有用。例如，`Array`遵循`CustomReflectable`协议和将数组的元素公开为未标记的子元素。`Dictionary`使用它的键值对作为公开的子元素。  
对于其他所有的类型，`Mirror`用了一些魔法根据值的实际内容提供一个子列表。对于结构体和类，它的存储属性为子元素。于元组，它是元组属性。枚举如果存在case和关联值，则显示case和关联值。  
这魔法是怎么运作的？让我们来看看吧！  

# 结构  
反射的API部分在Swift中实现，部分在C++中实现。Swift更适合实现Swifty接口，同时让许多任务变得简单。Swift的运行时底层是通过C++实现的，直接通过Swift访问这些C++类是不可能的。所以这层通过C去连接两者。Swift的实现是[ReflectionMirror.swift](https://github.com/apple/swift/blob/master/stdlib/public/core/ReflectionMirror.swift)，而C++的实现是[ReflectionMirror.mm](https://github.com/apple/swift/blob/master/stdlib/public/runtime/ReflectionMirror.mm)。   

这两部分通过一小组的C++函数暴露给Swift通信，而不是使用Swift内置的C桥接，它们在Swift中使用指定的自定义符号的命令，然后这个名字的C++函数经过精心设计，可以让Swift直接调用。这允许两部分直接调用不用担心桥接会对值造成什么影响，但它必须知道Swift如何传递参数和返回值。除非你需要处理运行时代码，否则不要在家里运行这个。    

例如，请查看`ReflectionMirror.swift`的`_getChildCount`函数：  
```swift
@_silgen_name("swift_reflectionMirror_count")
internal func _getChildCount<T>(_: T, type: Any.Type) -> Int
```  
`@_silgen_name`关键字通知Swift编译器将此函数映射到符号名为`swift_reflectionMirror_count`,而不是将Swift的`_getChildCount`替换，请注意，开头的下划线是表示此属性是为标准库保留的。在C++方面，该函数如下所示：  
```c++
SWIFT_CC(swift) SWIFT_RUNTIME_STDLIB_INTERFACE
intptr_t swift_reflectionMirror_count(OpaqueValue *value,
                                      const Metadata *type,
                                      const Metadata *T) {
```  
`SWIFT_CC(swift)`告诉编译器这个函数使用Swift约定而不是C/C++的约定。`SWIFT_RUNTIME_STDLIB_INTERFACE`标记为函数，而且它是Swif接口的一部分，并且具有将其标记为extern "C"避免C++名称修改的效果，确保此函数是Swift期望调用的符号名。C++参数会谨慎匹配基于Swift声明函数的调用，当Swift代码调用`_getChildCount`，调用C++函数的value包含一个指向Swift value的指针，`type`包含该值的参数类型，并且包含泛型类型<T>。   

`Swift`和`C++`部分之间的完整接口`Mirror`包含以下函数：  
```swift  
@_silgen_name("swift_reflectionMirror_normalizedType")
internal func _getNormalizedType<T>(_: T, type: Any.Type) -> Any.Type

@_silgen_name("swift_reflectionMirror_count")
internal func _getChildCount<T>(_: T, type: Any.Type) -> Int

internal typealias NameFreeFunc = @convention(c) (UnsafePointer<CChar>?) -> Void

@_silgen_name("swift_reflectionMirror_subscript")
internal func _getChild<T>(
  of: T,
  type: Any.Type,
  index: Int,
  outName: UnsafeMutablePointer<UnsafePointer<CChar>?>,
  outFreeFunc: UnsafeMutablePointer<NameFreeFunc?>
) -> Any

// Returns 'c' (class), 'e' (enum), 's' (struct), 't' (tuple), or '\0' (none)
@_silgen_name("swift_reflectionMirror_displayStyle")
internal func _getDisplayStyle<T>(_: T) -> CChar

@_silgen_name("swift_reflectionMirror_quickLookObject")
internal func _getQuickLookObject<T>(_: T) -> AnyObject?

@_silgen_name("_swift_stdlib_NSObject_isKindOfClass")
internal func _isImpl(_ object: AnyObject, kindOf: AnyObject) -> Bool
```  
# 动态调用做的很奇怪  
没有一种通用方法可以从任何类型获取我们想要的信息。很多任务在元组、结构体、类和枚举都需要不同的代码，例如查找子项的数量。还有些微妙的地方，例如Swift和Objective-C之间类的处理。  
  
所有这些函数都需要根据动态检查的类型来解释不同实现的代码。这听起来很像方法的动态调用，检查方法方法使用对象的类比选择调用哪个实现更复杂。反射代码通过试图C++动态调度简化问题，该调度包含C++接口抽象基类和以及一系列涵盖所有各种情况的子类。单个函数将Swift类型C++类的实例。在实例调用方法的时候再调度到合适的实现上。  
调用映射函数`call`，其声明如下所示：  
```c++  
template<typename F>
auto call(OpaqueValue *passedValue, const Metadata *T, const Metadata *passedType,
          const F &f) -> decltype(f(nullptr))
```   

`passedValue`指向实际传入Swift值的指针。`T`是该值的静态类型，它对应Swift的<T>泛型参数。  

`passedType`是一个由Swift明确传入并用来真正反射步骤上的类型。（当使用`Mirror`的超类去处理子类的实例时，这个类型和对象的实际运行时类型不。）最后，`f`参数将会被调用，传入一个引用这个函数的实现对象。然后此函数在调用的时候返回任意值f，让用户更容易的获取返回值。  
`call`的实现并不让人兴奋。主要是用了个很大的`switch`声明和一些扩展的代码用于处理额外的情况。有个重要的事情是，它最终会调用`f`的`ReflectionMirrorImpl`的实例，然后将调用该实例上的方法来完成实际工作。  
这是`ReflectionMirrorImpl`,这是所有调用过的接口：  

```c++  
struct ReflectionMirrorImpl {
  const Metadata *type;
  OpaqueValue *value;

  virtual char displayStyle() = 0;
  virtual intptr_t count() = 0;
  virtual AnyReturn subscript(intptr_t index, const char **outName,
                              void (**outFreeFunc)(const char *)) = 0;
  virtual const char *enumCaseName() { return nullptr; }

#if SWIFT_OBJC_INTEROP
  virtual id quickLookObject() { return nil; }
#endif

  virtual ~ReflectionMirrorImpl() {}
};
```  
使用Swift和C++组件之间的接口`call`函数调用相应的方法。例如，这是`swift_reflectionMirror_count`如下：  
```c++
SWIFT_CC(swift) SWIFT_RUNTIME_STDLIB_INTERFACE
intptr_t swift_reflectionMirror_count(OpaqueValue *value,
                                      const Metadata *type,
                                      const Metadata *T) {
  return call(value, T, type, [](ReflectionMirrorImpl *impl) {
    return impl->count();
  });
}
```   
  
# 元组反射  
让我们从元组反射开始，这可能是最简单的一个依然可以完成一些工作。它首先返回一个显示样式，`t`表明它是一个元组：  
```c++
struct TupleImpl : ReflectionMirrorImpl {
  char displayStyle() {
    return 't';
  }
```  
像这里这样使用硬编码是不正常的，但考虑到C++中只有一个位置和Swift中的一个位置引用了这个值，并且他们没有使用桥接进行通信，这是一个合理的选择。  
接下来是`count`方法。在这点上，我们知道`type`是`TupleTypeMetadata *`而不仅是`Metadata *`.`TupleTypeMetadata`有一个`NumElements`字段，它保存元组中元素的数量，我们结束了：  
```c++
  intptr_t count() {
    auto *Tuple = static_cast<const TupleTypeMetadata *>(type);
    return Tuple->NumElements;
  }
```  
`subscript`方法需要做更多的工作。它开始在同样的`static_cast`:  
```c++
  AnyReturn subscript(intptr_t i, const char **outName,
                      void (**outFreeFunc)(const char *)) {
    auto *Tuple = static_cast<const TupleTypeMetadata *>(type);
```  
下一步，边界检查确保调用者没有要求这个元组不能包含下标：  
```c++
 if (i < 0 || (size_t)i > Tuple->NumElements)
      swift::crash("Swift mirror subscript bounds check failure");
```  
下标有两个工作：它检查值和符合的名字。对于结构体或者类，这个名字是存储属性的名字。对于元组来说，这个名字是可以是元组元素的标签，也可以是数字指示器，如果没有标签是`.0`。  
标签以空格分割组成列表，存储在Label元数据字段中。这段代码跟踪第i个字符串在列表中：  
```c++
  // Determine whether there is a label.
    bool hasLabel = false;
    if (const char *labels = Tuple->Labels) {
      const char *space = strchr(labels, ' ');
      for (intptr_t j = 0; j != i && space; ++j) {
        labels = space + 1;
        space = strchr(labels, ' ');
      }

      // If we have a label, create it.
      if (labels && space && labels != space) {
        *outName = strndup(labels, space - labels);
        hasLabel = true;
      }
    }
```  
如果没有标签，请生成相应的数字名称：  
```c++
    if (!hasLabel) {
      // The name is the stringized element number '.0'.
      char *str;
      asprintf(&str, ".%" PRIdPTR, i);
      *outName = str;
    }
```  
因为我们有相互调用Swift和C++，所以我们没有得到内存自动管理这种好东西，Swift有ARC，C++有RAII，但两者是独立的。`outFreeFunc`允许C++代码释放返回的名称调用者的功能，标签释放的时候需要调`free`，因此这代码设置值到`*outFreeFunc`。  
```c++
*outFreeFunc = [](const char *str) { free(const_cast<char *>(str)); };
```