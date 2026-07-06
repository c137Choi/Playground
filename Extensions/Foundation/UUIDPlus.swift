//
//  UUIDPlus.swift
//  KnowLED
//
//  Created by Choi on 2024/12/30.
//

import Foundation

nonisolated extension UUID {
    
    /// 生成一个新的UUID
    static var new: UUID {
        UUID()
    }
    
    var data: Data {
        Data(bytes)
    }
    
    var bytes: [UInt8] {
        let (b0, b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15) = uuid
        return [b0, b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15]
    }
}
