//
//  BoolPlus.swift
//
//  Created by Choi on 2022/8/18.
//

import Foundation

extension Bool {
    
    /// 返回Int值 | true ? 1 : 0
    var intValue: Int {
        self ? 1 : 0
    }
    
    var opposite: Bool {
        !self
    }
    
    var isTrue: Bool {
        self == true
    }
    
    var isFalse: Bool {
        self == false
    }
}

extension Optional where Wrapped == Bool {
    
    var isTrue: Bool {
        self == true
    }
    
    var isFalse: Bool {
        self == false
    }
}
