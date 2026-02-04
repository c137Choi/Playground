//
//  SetAlgebraPlus.swift
//  KnowLED
//
//  Created by Choi on 2025/10/16.
//

import Foundation

extension SetAlgebra {
    
    /// 是否和另一个集合相交
    public func intersects(with other: Self) -> Bool {
        !isDisjoint(with: other)
    }
    
    /// 对比两个集合, 返回对比后的结果
    /// - Parameter updated: 新集合
    /// - Returns: 元组(移除的元素, 不变的元素, 新增的元素)
    /// let old: Set<Int> = [1, 2, 3]
    /// let new: Set<Int> = [2, 3, 4]
    /// old.compare(new) // (removedElements: Set([1]), remainedElements: Set([2, 3]), addedElements: Set([4]))
    public func compare(_ updated: Self) -> (removedElements: Self, remainedElements: Self, addedElements: Self) {
        (self - updated, self ^ updated, updated - self)
    }
    
    static func + (lhs: Self, rhs: Self) -> Self {
        lhs.union(rhs)
    }
    
    static func += (lhs: inout Self, rhs: Self) {
        lhs.formUnion(rhs)
    }
    
    static func += (lhs: inout Self, rhs: Element) {
        lhs.insert(rhs)
    }
    
    static func - (lhs: Self, rhs: Self) -> Self {
        lhs.subtracting(rhs)
    }
    
    static func -= (lhs: inout Self, rhs: Self) {
        lhs.subtract(rhs)
    }
    
    static func -= (lhs: inout Self, rhs: Element) {
        lhs.remove(rhs)
    }
    
    static func ^ (lhs: Self, rhs: Self) -> Self {
        lhs.intersection(rhs)
    }
}
