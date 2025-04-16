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
    /// 这里储存一份静态属性,避免重复创建Range
    static let percentRange = Double.hotPercentRange
    
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
        let now = Date()
        let treatableComponents: [Calendar.Component] = [.day, .hour, .minute, .second, .nanosecond]
        guard treatableComponents.contains(component) else {
            assertionFailure("\(component)'s time interval may vary in current date: \(now)")
            return 0.0
        }
        return Calendar.gregorian.dateInterval(of: component, for: now).map(\.duration) ?? 0.0
    }
}
