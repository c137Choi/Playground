//
//  FormatStylePlus.swift
//  KnowLED
//
//  Created by Choi on 2026/2/4.
//

import Foundation

extension FormatStyle where Self == FloatingPointFormatStyle<Double> {
    
    /// 0-2个小数位, 整数位不分组, 进位规则.down
    static var f2: Self {
        number.grouping(.never)
            .precision(.fractionLength(0...2))
            .rounded(rule: .down)
    }
    
    /// 0-4个小数位, 整数位不分组, 进位规则.down
    static var f4: Self {
        number.grouping(.never)
            .precision(.fractionLength(0...4))
            .rounded(rule: .down)
    }
    
    /// 转换为色相: 0...1.0之间的值 × 360, 无小数位
    static var hueDegrees: Self {
        number.grouping(.never)
            .precision(.fractionLength(0))
            .scale(360)
    }
    
    /// 格式化色温: 每100K为一档
    static var cct: Self {
        number.grouping(.never)
            .precision(.fractionLength(0))
            .rounded(rule: .down, increment: 100)
    }
}

extension FormatStyle where Self == FloatingPointFormatStyle<Double>.Percent {
    /// 无小数位的百分比, 如, 0.9982 -> 99%
    /// rounded(rule: .down): 解决有多个小数位的情况, 如0.9988, 0.9989都会转换成99%, 如果不加则会转换成100%
    static var percentage: Self {
        percent.grouping(.never)
            .precision(.fractionLength(0))
            .rounded(rule: .down)
    }
}

// MARK: - Date
extension Date.FormatString {
    /// yyyy-MM-dd HH:mm:ss
    static let yyyyMMddHHmmss: Date.FormatString = "\(year: .padded(4))-\(month: .twoDigits)-\(day: .twoDigits) \(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits):\(second: .twoDigits)"
    /// yyyy-MM-dd HH:mm
    static let yyyyMMddHHmm: Date.FormatString = "\(year: .padded(4))-\(month: .twoDigits)-\(day: .twoDigits) \(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits)"
}

extension FormatStyle where Self == Date.VerbatimFormatStyle {
    
    static func dateFormat(_ format: Date.FormatString) -> Date.VerbatimFormatStyle {
        Date.VerbatimFormatStyle(format: format, locale: .chineseSimplified, timeZone: .autoupdatingCurrent, calendar: .gregorian)
    }
}
