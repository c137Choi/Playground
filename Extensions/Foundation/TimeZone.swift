//
//  TimeZone.swift
//  KnowLED
//
//  Created by Choi on 2026/2/6.
//

import Foundation

extension TimeZone {
    
    /// 北京时间 GMT+8
    /// TimeZone(identifier: "Asia/Shanghai")
    /// TimeZone(abbreviation: "GMT+8")
    static let beijing = TimeZone(secondsFromGMT: 28800).unsafelyUnwrapped
    
    /// 零时区
    static let gmt = if #available(iOS 16, *) {
        TimeZone.gmt
    } else {
        TimeZone(secondsFromGMT: 0).unsafelyUnwrapped
    }
}
