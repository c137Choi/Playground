//
//  CollectionPlus.swift
//  KnowLED
//
//  Created by Choi on 2023/8/12.
//

import Foundation

extension Collection {
    
    /// 下标方式获取指定位置的元素
    subscript (elementAt index: Index) -> Element? {
        element(at: index)
    }
    
    /// 获取指定位置的元素
    /// - Parameter index: 元素位置
    /// - Returns: 如果下标合规则返回相应元素
    public func element(at index: Index) -> Element? {
        guard isValidIndex(index) else { return nil }
        return self[index]
    }
    
    /// 验证是否为有效的Index
    public func isValidIndex(_ index: Index) -> Bool {
        indices.contains(index)
    }
    
    func filled(or defaultCollection: Self) -> Self {
        isNotEmpty ? self : defaultCollection
    }
    
    /// 如果只包含一个元素则返回元素, 否则返回空
    var singleElement: Element? {
        containsSingleElement ? first : nil
    }
    
    /// 只包括一个元素或无元素
    var containsSingleElementOrEmpty: Bool {
        count <= 1
    }
    
    /// 只包含一个元素
    var containsSingleElement: Bool {
        count == 1
    }
    
    /// 如果为空则返回nil
    var filledOrNil: Self? {
        isEmpty ? nil : self
    }
    
    var isNotEmpty: Bool {
        !isEmpty
    }
}
