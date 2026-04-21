//
//  FloatingPointPlus.swift
//  KnowLED
//
//  Created by Choi on 2024/9/5.
//

import Foundation

extension FloatingPoint {
    
    /// 实时创建的百分比范围, 尽量避免直接使用. 在常用的类型扩展里储存一份静态常量
    static var hotPercentRange: ClosedRange<Self> { 0...1 }
}
