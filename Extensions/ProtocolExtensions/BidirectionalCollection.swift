//
//  BidirectionalCollection.swift
//  KnowLED
//
//  Created by Choi on 2024/11/18.
//

import Foundation

extension BidirectionalCollection {
    
    /// 最后一个Index | 如数组[1, 2, 3].lastIndex == 2
    var lastIndex: Index {
        index(before: endIndex)
    }
}
