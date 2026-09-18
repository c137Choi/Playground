//
//  JSONEncoderPlus.swift
//  KnowLED
//
//  Created by Choi on 2024/8/7.
//

import Foundation

extension JSONEncoder: Configurable {}

nonisolated extension JSONEncoder {
    /// 时间以毫秒解析的Encoder
    static let millisecondsDateEncoder = JSONEncoder(dateEncodingStrategy: .millisecondsSince1970)
    /// 通用JSONEncoder | 不要修改属性, 只用于简单编解码. 其他情况需要使用单独的实例
    static let instance = JSONEncoder()
}

nonisolated extension JSONEncoder {
    
    convenience init(dateEncodingStrategy: JSONEncoder.DateEncodingStrategy) {
        self.init()
        self.dateEncodingStrategy = dateEncodingStrategy
    }
    
    static func encode<T>(_ value: T) throws -> Data where T: Encodable {
        try instance.encode(value)
    }
}
