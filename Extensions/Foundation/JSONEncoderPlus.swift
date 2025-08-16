//
//  JSONEncoderPlus.swift
//  KnowLED
//
//  Created by Choi on 2024/8/7.
//

import Foundation

extension JSONEncoder {
    
    /// 通用JSONEncoder
    static let instance = JSONEncoder()
    
    /// 时间以毫秒解析的Encoder
    static let millisecondsDateEncodingEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        return encoder
    }()
}
