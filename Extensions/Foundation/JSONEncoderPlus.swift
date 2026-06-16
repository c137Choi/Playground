//
//  JSONEncoderPlus.swift
//  KnowLED
//
//  Created by Choi on 2024/8/7.
//

import Foundation

extension JSONEncoder: Configurable {}

extension Configurable where Self == JSONEncoder {
    
    nonisolated static func make(_ configuration: (JSONEncoder) -> Void) -> JSONEncoder {
        JSONEncoder().setup(configuration)
    }
}

extension JSONEncoder {
    
    /// 通用JSONEncoder | 不要修改属性, 只用于简单编解码. 其他情况需要使用单独的实例
    nonisolated static let instance = JSONEncoder()
    
    nonisolated static func encode<T>(_ value: T) throws -> Data where T: Encodable {
        try instance.encode(value)
    }
    
    /// 时间以毫秒解析的Encoder
    nonisolated static let millisecondsDateEncoder = JSONEncoder.make { make in
        make.dateEncodingStrategy = .millisecondsSince1970
    }
}
