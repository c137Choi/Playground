//
//  URLComponentsPlus.swift
//  KnowLED
//
//  Created by Choi on 2025/12/26.
//

import Foundation

extension URLComponents {
    
    /// 初始化
    /// - Parameters:
    ///   - encodeHost: 是否给传入的host编码
    init(scheme: String?, host: String?, encodeHost: Bool = true) {
        self.init()
        self.scheme = scheme
        self.host = host.flatMap {
            encodeHost ? $0.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) : $0
        }
    }
}
