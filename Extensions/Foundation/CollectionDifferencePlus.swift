//
//  CollectionDifferencePlus.swift
//  KnowLED
//
//  Created by Choi on 2025/7/17.
//

import Foundation

extension CollectionDifference.Change {
    
    public var offset: Int {
        switch self {
        case .insert(let offset, _, _):
            return offset
        case .remove(let offset, _, _):
            return offset
        }
    }
    
    /// 插入的元素
    public var insertedElement: ChangeElement? {
        if case .insert(_, let element, _) = self {
            return element
        } else {
            return nil
        }
    }
    
    /// 删除的元素
    public var removedElement: ChangeElement? {
        if case .remove(_, let element, _) = self {
            return element
        } else {
            return nil
        }
    }
}
