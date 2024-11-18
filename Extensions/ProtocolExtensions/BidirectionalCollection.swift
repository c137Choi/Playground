//
//  BidirectionalCollection.swift
//  KnowLED
//
//  Created by Choi on 2024/11/18.
//

import Foundation

extension BidirectionalCollection {
    
    /// 最后一个Index | 如数组[1, 2, 3].lastIndex == 2
    /// 注: 空的Range(例如: 0..<0)不要调用这个方法, 否则会崩溃, 使用maybeLastIndex替换
    var lastIndex: Index {
        index(before: endIndex)
    }
}
