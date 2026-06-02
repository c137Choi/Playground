//
//  WeakLeash.swift
//  KnowLED
//
//  Created by Choi on 2025/10/28.
//

import Foundation

struct WeakLeash {
    
    /// 弱引用对象
    weak var reference: AnyObject?
    
    /// 初始化
    /// - Parameter reference: 弱引用对象
    init(_ reference: AnyObject?) {
        self.reference = reference
    }
}

extension NSObject {
    
    var weakLeash: WeakLeash {
        WeakLeash(self)
    }
}
