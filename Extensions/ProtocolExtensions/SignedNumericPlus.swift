//
//  SignedNumericPlus.swift
//  KnowLED
//
//  Created by Choi on 2023/12/20.
//

import Foundation

extension SignedNumeric {
    
    /// 正数变负数, 负数变正数
    /// 注: 使用时需要注意数字类型的范围
    /// 如: Int8类型的范围是: -128...127, 如果对Int8.min使用此方法则会触发运行时错误
    var negative: Self {
        var tmp = self
        tmp.negate()
        return tmp
    }
}
