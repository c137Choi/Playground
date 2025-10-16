//
//  SetPlus.swift
//
//  Created by Choi on 2022/10/19.
//

import Foundation

extension Set {
    
    init(@ArrayBuilder<Element> _ builder: () -> [Element]) {
        let elements = builder()
        self.init(elements)
    }
    
    /// 拼接元素
    /// - Parameter element: Optional<Element>类型元素, 有值时才拼接
    public mutating func insert(_ element: Element?) {
        if let element {
            insert(element)
        }
    }
    
    public mutating func insert(@ArrayBuilder<Element> _ builder: () -> [Element]) {
        let elements = builder()
        formUnion(elements)
    }
    
    /// 添加新元素 | 慎用(使用不当可能导致未能更新元素其他属性的问题)
    /// - Parameters:
    ///   - other: 新元素序列
    ///   - keyPath: 指定要对比的KeyPath
    public mutating func formUnion<S>(_ other: S, identifiedBy keyPath: KeyPath<Element, some Equatable>) where Element == S.Element, S: Sequence {
        for element in other {
            let exist = contains { elementInSet in
                elementInSet[keyPath: keyPath] == element[keyPath: keyPath]
            }
            if exist {
                continue
            } else {
                self.insert(element)
            }
        }
    }
}


extension Set {
    
    /// 交集
    static func ^ <S>(lhs: Set<Element>, rhs: S) -> Set<Element> where Element == S.Element, S: Sequence {
        lhs.intersection(rhs)
    }
    
    /// 并集
    static func + <S>(lhs: Set<Element>, rhs: S) -> Set<Element> where Element == S.Element, S: Sequence {
        lhs.union(rhs)
    }
    
    /// 将右侧集合中的元素合并到左侧集合中
    static func += <S>(lhs: inout Set<Element>, rhs: S) where Element == S.Element, S: Sequence {
        lhs.formUnion(rhs)
    }
    
    /// 相对差集
    /// 在集合A中却不在集合B中的集合，如：「1，2，3」 - 「2，3，4」= 「1」；「2，3，4」 - 「1，2，3」= 「4」
    static func - <S>(lhs: Set<Element>, rhs: S) -> Set<Element> where Element == S.Element, S: Sequence {
        lhs.subtracting(rhs)
    }
    
    /// 对等式左边的元素进行相对差集操作
    static func -= <S>(lhs: inout Set<Element>, rhs: S) where Element == S.Element, S: Sequence {
        lhs.subtract(rhs)
    }
    
    /// 相对差
    /// 只在集合A及B中的其中一个出现，没有在其交集中出现的元素
    /// 即并集减去交集（A∪B)\(A∩B）。如：「1，2，3」 +- 「2，3，4」= 「1，4」
    static func +- <S>(lhs: Set<Element>, rhs: S) -> Set<Element> where Element == S.Element, S: Sequence {
        lhs.symmetricDifference(rhs)
    }
}
