---
layout:     post
title:      "JSONDecoder源码分析"
subtitle:   "Codable，Swift，Swift-Foundation，JSONDecoder"
date:       2023-6-11
author:     "Karim"
header-img: "img/post-white-room.png"
tags:
- Codable
- Swift
- Swift-Foundation
- JSONDecoder
---

# 前言
`JSONDecoder`是Apple在`Swift`上实现JSON转模型的类，我在17年的时候，就写过相关介绍[WWDC-2017笔记---Codable](https://www.foolishtalk.org/2017/06/21/WWDC-2017%E7%AC%94%E8%AE%B0-Codable/)，所以这里就不做详细介绍了，有兴趣可以去考个古。  
  
因为很久之前有做过ORM数据库的封装，而JSON转模型是ORM很基本的能力，所以一直以来对这个实现很感兴趣，Swift开源出来了，难得有机会读了一下。

最早的时候，是在[swift-corelibs-foundation](https://github.com/apple/swift-corelibs-foundation)上看实现，但是`swift-corelibs-foundation`只是提供抽象到跨平台接口能力，
具体swift中怎么实现的，是看不到的，幸好在[swift-forums](https://forums.swift.org/t/how-to-build-and-debug-jsondecoder/44690/6)看到有相关讨论，很久之前有给swift提过mr，
找到当时的commit是还有当初泄漏的[JSONDecoder源码](https://github.com/Fidetro/swift/blob/JSONEncoder/stdlib/public/SDK/Foundation/JSONEncoder.swift)，在我看完这个版本之后，
我以为已经结束了。偶然发现Apple又开源了个[swift-foundation](https://github.com/apple/swift-foundation)？？？居然是23年1月开源的（ps:可以通过github api查开源时间https://api.github.com/repos/apple/swift-foundation），并且声称速度比原来快了200-500%：  
```
The tight integration of parsing JSON in Swift for initializing Codable types improves performance, too. In benchmarks parsing test data, there are improvements in decode time from 200% to almost 500%.
```  
现在先从旧的`JSONDecoder`开始，看看苹果做了什么优化。



# 泄漏的JSONDecoder  

![](https://www.foolishtalk.org/cloud/TW9uIEp1biAxMiAyMzoxNzoxMiBDU1QgMjAyMwo%3D.png)

先将data转成了json对象，初始化`_JSONDecoder`，`unbox`开始解包
```swift
    open func decode<T : Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let topLevel: Any
        do {
           topLevel = try JSONSerialization.jsonObject(with: data)
        } catch {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The given data was not valid JSON.", underlyingError: error))
        }

        let decoder = _JSONDecoder(referencing: topLevel, options: self.options)
        guard let value = try decoder.unbox(topLevel, as: type) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: [], debugDescription: "The given data did not contain a top-level value."))
        }

        return value
    }
```

因为我们都是要转成模型，就会直接走到对应类`init(from decoder: Decoder)`的方法
```swift
    fileprivate func unbox<T : Decodable>(_ value: Any, as type: T.Type) throws -> T? {
        if type == Date.self || type == NSDate.self {
            return try self.unbox(value, as: Date.self) as? T
        } else if type == Data.self || type == NSData.self {
            return try self.unbox(value, as: Data.self) as? T
        } else if type == URL.self || type == NSURL.self {
            guard let urlString = try self.unbox(value, as: String.self) else {
                return nil
            }

            guard let url = URL(string: urlString) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath,
                                                                        debugDescription: "Invalid URL string."))
            }

            return url as! T
        } else if type == Decimal.self || type == NSDecimalNumber.self {
            return try self.unbox(value, as: Decimal.self) as? T
        } else {
            self.storage.push(container: value)
            defer { self.storage.popContainer() }
            return try type.init(from: self)
        }
    }
```  

`init(from decoder: Decoder)`先要获取`container`
```swift
class Person: Codable {

    var name : String = ""
    var sex : Int = 0

    enum CodingKeys: String, CodingKey {
          case name
          case sex
      }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        var nameValue = try values.decode(String.self, forKey: .name)
        sex = try values.decode(Int.self, forKey: .sex)
    }
}

    public func container<Key>(keyedBy: Key.Type) -> KeyedEncodingContainer<Key> {
        // If an existing keyed container was already requested, return that one.
        let topContainer: NSMutableDictionary
        if self.canEncodeNewValue {
            // We haven't yet pushed a container at this level; do so here.
            topContainer = self.storage.pushKeyedContainer()
        } else {
            guard let container = self.storage.containers.last as? NSMutableDictionary else {
                preconditionFailure("Attempt to push new keyed encoding container when already previously encoded at this path.")
            }

            topContainer = container
        }

        let container = _JSONKeyedEncodingContainer<Key>(referencing: self, codingPath: self.codingPath, wrapping: topContainer)
        return KeyedEncodingContainer(container)
    }


```
从`container`拿到value更新属性，如果是对象，会递归触发`unbox`进行解包

```swift
        public func decode(_ type: String.Type, forKey key: Key) throws -> String {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: String.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }

    public func decode<T : Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(_errorDescription(of: key))."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: type) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }

```

# Swift-Foundation的JSONDecoder

![](https://www.foolishtalk.org/cloud/VHVlIEp1biAxMyAwMToyMTowMSBDU1QgMjAyMwo%3D.png)
```swift
open func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
    try _decode({
        try $0.unwrap($1, as: type, for: .root, _JSONKey?.none)
    }, from: data)
}
```

```swift
private func _decode<T>(_ unwrap: (JSONDecoderImpl, JSONMap.Value) throws -> T, from data: Data) throws -> T {
    do {
        //先通过二进制缓存区前几位，判断是否是utf8编码，如果不是，转成utf8编码
        return try Self.withUTF8Representation(of: data) { utf8Buffer in
            var impl: JSONDecoderImpl
            let topValue: JSONMap.Value
            do {
                // JSON5 is implemented with a separate scanner to allow regular JSON scanning to achieve higher performance without compromising for `allowsJSON5` checks throughout.
                // Since the resulting JSONMap is identical, the decoder implementation is mostly shared between the two, with only a few branches to handle different methods of parsing strings and numbers. Strings and numbers are not completely parsed until decoding time.
                let map: JSONMap
                if allowsJSON5 {
                    var scanner = JSON5Scanner(bytes: utf8Buffer, options: self.json5ScannerOptions)
                    map = try scanner.scan()
                } else {
                    var scanner = JSONScanner(bytes: utf8Buffer, options: self.scannerOptions)
                    //扫描字符串，记录key/value的位置
                    map = try scanner.scan()
                }
                topValue = map.loadValue(at: 0)!
                impl = JSONDecoderImpl(userInfo: self.userInfo, from: map, codingPathNode: .root, options: self.options)
            }
            impl.push(value: topValue) // This is something the old implementation did and apps started relying on. Weird.
            let result = try unwrap(impl, topValue)
            let uniquelyReferenced = isKnownUniquelyReferenced(&impl)
            impl.takeOwnershipOfBackingDataIfNeeded(selfIsUniquelyReferenced: uniquelyReferenced)
            return result
        }
    } catch let error as JSONError {
        #if FOUNDATION_FRAMEWORK
        let underlyingError: Error? = error.nsError
        #else
        let underlyingError: Error? = nil
        #endif
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The given data was not valid JSON.", underlyingError: underlyingError))
    } catch {
        throw error
    }
}
```

判断前几个字节是否是 utf8 编码，如果不是，转成 utf8 编码
```swift
static func withUTF8Representation<T>(of jsonData: Data, _ closure: (BufferView<UInt8>) throws -> T ) throws -> T {
    return try jsonData.withBufferView {
        [length = jsonData.count] bytes in
        assert(bytes.count == length)
        // RFC4627 section 3
        // The first two characters of a JSON text will always be ASCII. We can determine encoding by looking at the first four bytes.
        let byte0 = (length > 0) ? bytes[uncheckedOffset: 0] : nil
        let byte1 = (length > 1) ? bytes[uncheckedOffset: 1] : nil
        let byte2 = (length > 2) ? bytes[uncheckedOffset: 2] : nil
        let byte3 = (length > 3) ? bytes[uncheckedOffset: 3] : nil
        // Check for explicit BOM first, then check the first two bytes. Note that if there is a BOM, we have to create our string without it.
        // This isn't strictly part of the JSON spec but it's useful to do anyway.
        let sourceEncoding : String._Encoding
        let bomLength : Int
        switch (byte0, byte1, byte2, byte3) {
        case (0, 0, 0xFE, 0xFF):
            sourceEncoding = .utf32BigEndian
            bomLength = 4
        case (0xFE, 0xFF, 0, 0):
            sourceEncoding = .utf32LittleEndian
            bomLength = 4
        case (0xFE, 0xFF, _, _):
            sourceEncoding = .utf16BigEndian
            bomLength = 2
        case (0xFF, 0xFE, _, _):
            sourceEncoding = .utf16LittleEndian
            bomLength = 2
        case (0xEF, 0xBB, 0xBF, _):
            sourceEncoding = .utf8
            bomLength = 3
        case let (0, 0, 0, .some(nz)) where nz != 0:
            sourceEncoding = .utf32BigEndian
            bomLength = 0
        case let (0, .some(nz1), 0, .some(nz2)) where nz1 != 0 && nz2 != 0:
            sourceEncoding = .utf16BigEndian
            bomLength = 0
        case let (.some(nz), 0, 0, 0) where nz != 0:
            sourceEncoding = .utf32LittleEndian
            bomLength = 0
        case let (.some(nz1), 0, .some(nz2), 0) where nz1 != 0 && nz2 != 0:
            sourceEncoding = .utf16LittleEndian
            bomLength = 0
        // These cases technically aren't specified by RFC4627, since it only covers cases where the input has at least 4 octets. However, when parsing JSON with fragments allowed, it's possible to have a valid UTF-16 input that is a single digit, which is 2 octets. To properly support these inputs, we'll extend the pattern described above for 4 octets of UTF-16.
        case let (0, .some(nz), nil, nil) where nz != 0:
            sourceEncoding = .utf16BigEndian
            bomLength = 0
        case let (.some(nz), 0, nil, nil) where nz != 0:
            sourceEncoding = .utf16LittleEndian
            bomLength = 0
        default:
            sourceEncoding = .utf8
            bomLength = 0
        }
        let postBOMBuffer = bytes.dropFirst(bomLength)
        if sourceEncoding == .utf8 {
            return try closure(postBOMBuffer)
        } else {
            guard var string = String(bytes: postBOMBuffer, encoding: sourceEncoding) else {
                throw JSONError.cannotConvertEntireInputDataToUTF8
            }
            return try string.withUTF8 {
                // String never passes an empty buffer with a `nil` `baseAddress`.
                try closure(BufferView(unsafeBufferPointer: $0)!)
            }
        }
    }
}
```

`JSONScanner.scan()`的过程中，会将字段信息记录在一个数组中，方便后面直接取出
![](https://www.foolishtalk.org/cloud/VHVlIEp1biAxMyAwMDowMDowNiBDU1QgMjAyMwo%3D.png)
```swift
    enum TypeDescriptor : Int {
        case string  // [marker, count, sourceByteOffset]
        case number  // [marker, count, sourceByteOffset]
        case null    // [marker]
        case `true`  // [marker]
        case `false` // [marker]

        case object  // [marker, nextSiblingOffset, count, <keys and values>, .collectionEnd]
        case array   // [marker, nextSiblingOffset, count, <values>, .collectionEnd]
        case collectionEnd

        case simpleString // [marker, count, sourceByteOffset]
        case numberContainingExponent // [marker, count, sourceByteOffset]

        @inline(__always)
        var mapMarker: Int {
            self.rawValue
        }
    }

mutating func recordStartCollection(tagType: JSONMap.TypeDescriptor, with reader: DocumentReader) -> Int {
    resizeIfNecessary(with: reader)
    mapData.append(tagType.mapMarker)
    // Reserve space for the next object index and object count.
    let startIdx = mapData.count
    mapData.append(contentsOf: [0, 0])
    return startIdx
}

mutating func recordEndCollection(count: Int, atStartOffset startOffset: Int, with reader: DocumentReader) {
    resizeIfNecessary(with: reader)
    mapData.append(JSONMap.TypeDescriptor.collectionEnd.rawValue)
    let nextValueOffset = mapData.count
    mapData.withUnsafeMutableBufferPointer {
        $0[startOffset] = nextValueOffset
        $0[startOffset + 1] = count
    }
}

mutating func record(tagType: JSONMap.TypeDescriptor, count: Int, dataOffset: Int, withreader: DocumentReader) {
    resizeIfNecessary(with: reader)
    mapData.append(contentsOf: [tagType.mapMarker, count, dataOffset])
}
```

```swift
func unwrap<T: Decodable>(_ mapValue: JSONMap.Value, as type: T.Type, for codingPathNode: _JSONCodingPathNode, _ additionalKey: (some CodingKey)? = nil) throws -> T {
    if type == Date.self {
        return try self.unwrapDate(from: mapValue, for: codingPathNode, additionalKey) as! T
    }
    if type == Data.self {
        return try self.unwrapData(from: mapValue, for: codingPathNode, additionalKey) as! T
    }
#if FOUNDATION_FRAMEWORK // TODO: Reenable once URL and Decimal are moved
    if type == URL.self {
        return try self.unwrapURL(from: mapValue, for: codingPathNode, additionalKey) as! T
    }
    if type == Decimal.self {
        return try self.unwrapDecimal(from: mapValue, for: codingPathNode, additionalKey) as! T
    }
#endif// FOUNDATION_FRAMEWORK
    if T.self is _JSONStringDictionaryDecodableMarker.Type {
        return try self.unwrapDictionary(from: mapValue, as: type, for: codingPathNode, additionalKey)
    }
    return try self.with(value: mapValue, path: codingPathNode.pushing(additionalKey)) {
        try type.init(from: self)
    }
}
```

```swift
class Person: Codable {

    var name : String = ""
    var sex : Int = 0

    enum CodingKeys: String, CodingKey {
          case name
          case sex
      }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        var nameValue = try values.decode(String.self, forKey: .name)
        sex = try values.decode(Int.self, forKey: .sex)
    }
}
```

```swift
func container<Key: CodingKey>(keyedBy _: Key.Type) throws -> KeyedDecodingContainer<Key> {
    switch topValue {
    case let .object(region):
        let container = try KeyedContainer<Key>(
            impl: self,
            codingPathNode: codingPathNode,
            region: region
        )
        return KeyedDecodingContainer(container)
    case .null:
        throw DecodingError.valueNotFound([String: Any].self, DecodingError.Context(
            codingPath: self.codingPath,
            debugDescription: "Cannot get keyed decoding container -- found null value instead"
        ))
    default:
        throw DecodingError.typeMismatch([String: Any].self, DecodingError.Context(
            codingPath: self.codingPath,
            debugDescription: "Expected to decode \([String: Any].self) but found \(topValue.debugDataTypeDescription) instead."
        ))
    }
}


init(impl: JSONDecoderImpl, codingPathNode: _JSONCodingPathNode, region: JSONMap.Region) throws {
    self.impl = impl
    self.codingPathNode = codingPathNode
    self.dictionary = try Self.stringify(objectRegion: region, using: impl, codingPathNode: codingPathNode, keyDecodingStrategy: impl.options.keyDecodingStrategy)
}
```

```swift
static func stringify(objectRegion: JSONMap.Region, using impl: JSONDecoderImpl, codingPathNode: _JSONCodingPathNode, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy) throws -> [String:JSONMap.Value] {
            var result = [String:JSONMap.Value]()
            result.reserveCapacity(objectRegion.count / 2)

            var iter = impl.jsonMap.makeObjectIterator(from: objectRegion.startOffset)
            switch keyDecodingStrategy {
            case .useDefaultKeys:
                while let (keyValue, value) = iter.next() {
                    // Failing to unwrap a string here is impossible, as scanning already guarantees that dictionary keys are strings.
                    let key = try! impl.unwrapString(from: keyValue, for: codingPathNode, _JSONKey?.none)
                    result[key]._setIfNil(to: value)
                }
            case .convertFromSnakeCase:
                while let (keyValue, value) = iter.next() {
                    // Failing to unwrap a string here is impossible, as scanning already guarantees that dictionary keys are strings.
                    let key = try! impl.unwrapString(from: keyValue, for: codingPathNode, _JSONKey?.none)

                    // Convert the snake case keys in the container to camel case.
                    // If we hit a duplicate key after conversion, then we'll use the first one we saw.
                    // Effectively an undefined behavior with JSON dictionaries.
                    result[JSONDecoder.KeyDecodingStrategy._convertFromSnakeCase(key)]._setIfNil(to: value)
                }
            case .custom(let converter):
                let codingPathForCustomConverter = codingPathNode.path
                while let (keyValue, value) = iter.next() {
                    // Failing to unwrap a string here is impossible, as scanning already guarantees that dictionary keys are strings.
                    let key = try! impl.unwrapString(from: keyValue, for: codingPathNode, _JSONKey?.none)

                    var pathForKey = codingPathForCustomConverter
                    pathForKey.append(_JSONKey(stringValue: key)!)
                    result[converter(pathForKey).stringValue]._setIfNil(to: value)
                }
            }

            return result
        }
```


```swift
func decode(_ type: String.Type, forKey key: K) throws -> String {
    let value = try getValue(forKey: key)
    return try impl.unwrapString(from: value, for: self.codingPathNode, key)
}

mutating func decode<T: Decodable>(_ type: T.Type) throws -> T {
    let value = try self.peekNextValue(ofType: type)
    let result = try impl.unwrap(value, as: type, for: codingPathNode, currentIndexKey)
    advanceToNextValue()
    return result
}
```


```swift
private func unwrapString(from value: JSONMap.Value, for codingPathNode: _JSONCodingPathNode, _additionalKey: (some CodingKey)? = nil) throws -> String {
    try checkNotNull(value, expectedType: [String].self, for: codingPathNode, additionalKey)
    guard case .string(let region, let isSimple) = value else {
        throw self.createTypeMismatchError(type: String.self, for: codingPathNode.path(with: additionalKey), value: value)
    }
    return try withBuffer(for: region) { stringBuffer, fullSource in
    
        if isSimple {
            guard let result = String._tryFromUTF8(stringBuffer) else {
                throw JSONError.cannotConvertInputStringDataToUTF8(location: .sourceLocation(at: stringBuffer.startIndex, fullSource: fullSource))
            }
            return result
        }
        if options.json5 {
            return try JSON5Scanner.stringValue(from: stringBuffer, fullSource: fullSource)
        } else {
            return try JSONScanner.stringValue(from: stringBuffer, fullSource: fullSource)
        }
    }
}
```


