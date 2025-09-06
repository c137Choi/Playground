//
//  IntPlus.swift
//  ExtensionDemo
//
//  Created by Choi on 2021/2/26.
//  Copyright © 2021 Choi. All rights reserved.
//

import UIKit

extension Int {
	
	// 获取一个整形数字个十百千...位上的数字. 例如:
	// 746381295[0] == 5 个位数字
	// 746381295[1] == 9 十位数字...
	subscript(digitIndex: Int) -> Int {
		var decimalBase = 1
		for _ in 0 ..< digitIndex {
			decimalBase *= 10
		}
		return (self / decimalBase) % 10
	}
    
    /// 秒数 -> 时长的描述(1:05:07)
    var durationDescription: String {
        let hours = self / 3600
        let minutes = self % 3600 / 60
        let seconds = self % 3600 % 60
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
    
    /// 例: 1 -> 01; 10 -> 10
    var twoDigits: String? {
        digits(2)
    }
    
    func digits(_ minimumIntegerDigits: Int = 1) -> String? {
        NumberFormatter.shared.configure { formatter in
            formatter.minimumIntegerDigits = minimumIntegerDigits
        }.map { formatter in
            formatter.string(from: self.nsNumber)
        }
    }
    
    var isZero: Bool {
        self == 0
    }
    
    var isNegative: Bool {
        self < 0
    }
    
    var isPositive: Bool {
        self > 0
    }
    
    /// 索引转换成序号
    var number: Int {
        let result = addingReportingOverflow(1)
        return result.overflow ? .max : result.partialValue
    }
    
    /// 转换成索引值
    var index: Int {
        guard self >= 1 else { return 0 }
        return self - 1
    }
	
    var bool: Bool {
        self > 0 ? true : false
    }
    
    var nsNumber: NSNumber {
        NSNumber(value: self)
    }
    
    var half: Int {
        self / 2
    }
    
    /// 整形 -> 颜色16进制字符串
    /// 从左至右依次按照ARGB排列. 格式为: #(A)RGB
    var argbColorHexString: String {
        let maxRGB = 0xFF_FF_FF
        let maxARGB = 0xFF_FF_FF_FF
        switch self {
        case 0...maxRGB:
            let red   = (self & 0xFF_00_00) >> 16
            let green = (self & 0x00_FF_00) >> 8
            let blue  = (self & 0x00_00_FF) >> 0
            return String(format: "#%02lX%02lX%02lX", red, green, blue)
        case maxRGB.number...maxARGB:
            let alpha = (self & 0xFF_00_00_00) >> 24
            let red   = (self & 0x00_FF_00_00) >> 16
            let green = (self & 0x00_00_FF_00) >> 8
            let blue  = (self & 0x00_00_00_FF) >> 0
            return String(format: "#%02lX%02lX%02lX%02lX", alpha, red, green, blue)
        default:
            return ""
        }
    }
}

// MARK: - Int + Calendar
extension Int {
	
	static func * (lhs: Int, component: Calendar.Component) -> DateComponents {
		var components = DateComponents(calendar: .gregorian)
		components.setValue(lhs, for: component)
		return components
	}
	
	/// 计算指定日期元素的秒数
	/// - Parameter component: 日期元素 | 可处理的枚举: .day, .hour, .minute, .second, .nanosecond
	/// - Returns: 秒数
	static func seconds(in component: Calendar.Component) -> Int {
		Int(timeInterval(in: component))
	}
	
	/// 计算指定日期元素的纳秒数
	/// - Parameter component: 日期元素 | 可处理的枚举: .day, .hour, .minute, .second, .nanosecond
	/// - Returns: 纳秒数
	static func nanoseconds(in component: Calendar.Component) -> Int {
		Int(timeInterval(in: component) * 1e9)
	}
	
	/// 计算指定日期元素的时间间隔
	/// - Parameter component: 日期元素 | 可处理的枚举: .day, .hour, .minute, .second, .nanosecond
	/// - Returns: 时间间隔
	fileprivate static func timeInterval(in component: Calendar.Component) -> TimeInterval {
		Double.timeInterval(in: component)
	}
}
