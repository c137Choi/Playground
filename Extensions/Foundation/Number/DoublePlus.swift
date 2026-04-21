//
//  NumberPlus.swift
//  ExtensionDemo
//
//  Created by Choi on 2021/1/22.
//  Copyright © 2021 Choi. All rights reserved.
//

import UIKit

extension Numeric {
    var spellout: String? {
        NumberFormatter.spellout.string(for: self)
    }
}

// MARK: - __________ Common __________

extension Double {
    /// 0...1.0 | 这里储存一份静态属性,避免重复创建Range
    static let percentRange = Double.hotPercentRange
    
    /// Double根剧步长和小数位长度进行格式化
    /// - Parameters:
    ///   - increment: 步长
    ///   - fractionLength: 小数位长度
    /// - Returns: 格式化后的字符串
    func formatted(increment: Double? = nil, fractionLength: Int) -> String {
        /// 小数位长度(不可为负值所以这里用max方法约束一下)
        let fractionLength = max(0, fractionLength)
        /// 基础格式化样式
        let baseStyle = FloatingPointFormatStyle<Double>.number
            .grouping(.never)
            .precision(.fractionLength(fractionLength))
            .sign(strategy: .automatic)
        /// 处理步长
        if let increment {
            /// 步长小于1时必须经过下面的处理过程否则会有精度丢失的问题
            if increment < 1.0, fractionLength > 0 {
                /// 将参数分成整数和小数两个部分
                let modf = modf
                /// 整数部分转成Int
                let integerPart = "\(Int(modf.0))"
                /// 小数部分根剧increment取整
                let fractionPart = (modf.1 / increment).rounded(.towardZero) * increment
                /// 格式化后的小数部分(小数部分取绝对值,解决参数为负数时返回-0.xxx而导致的,替换整数部分后字符串错误的问题)
                let formatted = abs(fractionPart).formatted(baseStyle)
                /// 替换整数部分(小数部分格式化之后整数部分总为'0')
                return formatted.replacingCharacters(in: formatted.startIndex...formatted.startIndex, with: integerPart)
            }
            /// 其他情况: 步长大于1或小数位长度为0
            /// 2026年04月19日23:21:34 | 参数: 21345.12345; increment: 21.34567; fractionLength: 3的情况
            /// 使用parameter.formatted(style.rounded(rule: .towardZero, increment: increment))格式化输出: 21324.32433(显示了五位小数, 不符合3位小数长度的需求)
            /// 2026年04月21日10:33:36更新: 为什么会显示五位, 根剧谷歌AI的解释, 在FloatingPointFormatStyle中，当你显式指定了 increment（步长）时
            /// Swift 认为你的首要需求是按这个精确的步长进行对齐
            /// 由于你的步长 21.34567 本身就有 5 位小数，格式化引擎为了保证取整后的数值准确性（即 999 * 21.34567 的精确结果）
            /// 会自动扩展精度以容纳步长本身的位数，从而导致 .precision(.fractionLength(3)) 被“忽略”或失效。
            /// 所以这里根剧increment步进的逻辑需要自己做处理
            else {
                /// 参数除以步长:计算步长的个数. 使用.towardZero规则可同时兼顾正数和负数两种情况
                let incrementCount = (self / increment).rounded(.towardZero)
                /// 有一种情况-49.2345(增量:50.0 小数位:0)时, incrementCount为-0(输出字符串为:-0)
                /// 使用Double.zero.addingProduct(意为: 0 + 乘积)处理参数为负值incrementCount为-0的情况: -0 + 0 == 0(无负号)
                /// addingProduct方法能更好地处理边界符号. 而且(Double.zero + 任意乘积)不会对其他情况产生影响
                return Double.zero.addingProduct(incrementCount, increment).formatted(baseStyle)
            }
        }
        /// 无步长的情况: 直接按小数位格式化输出并按照.towardZero规则进位
        else {
            let style = baseStyle.rounded(rule: .towardZero)
            return self.formatted(style)
        }
    }
    
    var percentClip: PercentClip {
        PercentClip(percent: self)
    }
    
    var durationDescription: String {
        int.durationDescription
    }
    
    /// 返回毫秒数
    var milliseconds: Int {
        Int(self * 1000)
    }
}

// MARK: - __________ Date __________
extension Double {
    
    /// 计算指定日期元素内的秒数
    /// - Parameter component: 日期元素 | 可处理的枚举: .day, .hour, .minute, .second, .nanosecond
    /// - Returns: 时间间隔
    static func timeInterval(in component: Calendar.Component) -> TimeInterval {
        let now = Date.now
        let treatableComponents: [Calendar.Component] = [.day, .hour, .minute, .second, .nanosecond]
        guard treatableComponents.contains(component) else {
            assertionFailure("\(component)'s time interval may vary in current date: \(now)")
            return 0.0
        }
        return Calendar.gregorian.dateInterval(of: component, for: now).map(\.duration) ?? 0.0
    }
}
