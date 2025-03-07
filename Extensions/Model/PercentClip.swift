//
//  PercentClip.swift
//  KnowLED
//
//  Created by Choi on 2023/12/20.
//

import Foundation

/// 将0...1.0的百分比从中间0.5切分成左右两半百分比
struct PercentClip<T: BinaryFloatingPoint> {
    let lower: T?
    let upper: T?
    
    init(lower: T?, upper: T?) {
        self.lower = lower.flatMap { lower in
            T.hotPercentRange << lower
        }
        self.upper = upper.flatMap { upper in
            T.hotPercentRange << upper
        }
    }
    
    /// 翻转左侧百分比
    /// 0.6 -> 0.4 | 0.3 -> 0.7
    var reverseLower: T? {
        lower.flatMap { left in
            1.0 - left
        }
    }
    
    /// 分割百分比(带符号): 左侧百分比为负数
    var signedLower: T? {
        lower.map(\.negative)
    }
    
    /// 解包并回调相应的半边百分比
    /// - Parameters:
    ///   - lower: 较低的一半百分比
    ///   - middle: 0.5
    ///   - upper: 较高的一半百分比
    func unwrap(lower: (_ lower: T) -> Void, middle: SimpleCallback = {},  upper: (_ upper: T) -> Void) {
        if let unwrapLower = self.lower {
            lower(unwrapLower)
        } else if let unwrapUpper = self.upper {
            upper(unwrapUpper)
        } else {
           middle()
        }
    }
}
