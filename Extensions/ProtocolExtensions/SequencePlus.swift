//
//  SequencePlus.swift
//  KnowLED
//
//  Created by Choi on 2023/8/12.
//

import Foundation

extension Sequence {
    
    var array: Array<Element> {
        Array(self)
    }
    
    /// 根据KeyPath过滤掉重复的元素
    /// - Parameter keyPath: 元素的KeyPath
    /// - Returns: 无重复元素的数组
    func removingDuplicates<Value>(at keyPath: KeyPath<Element, Value>) -> [Element] where Value: Equatable {
        removingDuplicates { element1, element2 in
            element1[keyPath: keyPath] == element2[keyPath: keyPath]
        }
    }
    
    /// 移除重复项
    /// - Parameter includeElement: 判断是否重复的回调
    /// - Returns: 无重复元素的数组
    func removingDuplicates(includeElement: (Element, Element) -> Bool) -> [Element] {
        var results = [Element]()
        
        forEach { element in
            let existingElements = results.filter {
                return includeElement(element, $0)
            }
            if existingElements.count == 0 {
                results.append(element)
            }
        }
        
        return results
    }
    
    func with<T>(_ anything: T) -> [(Element, T)] {
        map { element in
            (element, anything)
        }
    }
    
    func `as`<T>(_ type: T.Type) -> [T] {
        compactMap { element in
            element as? T
        }
    }
}

extension Sequence where Element: Sequence {
    
    /// 展开:数组的数组
    var flattened: [Element.Element] {
        flatMap { $0 }
    }
}

extension Sequence where Element: Hashable {
    
    /// 移除重复项(保持原有的元素顺序) | Element必须遵循Hashable
    var duplicatesRemoved: [Element] {
        /// 创建临时的Element集合
        var seen: Set<Element> = []
        /// 利用Set类型的insert方法返回的tuple: (inserted: Bool, memberAfterInsert: Element)进行过滤
        /// inserted为true, 则表示插入成功(没有重复), 否则插入失败
        return filter { seen.insert($0).inserted }
    }
    
    var set: Set<Element> {
        Set(self)
    }
}

extension Sequence where Element: OptionalType {
    var unwrapped: [Element.Wrapped] {
        compactMap(\.optionalValue)
    }
}

extension Sequence where Self: ExpressibleByArrayLiteral {
    
    /// 空序列
    static var empty: Self {
        []
    }
}

extension Sequence where Self: ExpressibleByDictionaryLiteral {
    
    /// 空字典
    static var empty: Self {
        [:]
    }
}
