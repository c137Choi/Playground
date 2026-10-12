//
//  BinaryFloatingPointPlus.swift
//  KnowLED
//
//  Created by Choi on 2023/12/5.
//

import Foundation

nonisolated extension Optional where Wrapped: BinaryFloatingPoint {
    
    var orZero: Wrapped { self ?? 0.0 }
    
    var orNan: Wrapped { self ?? Wrapped.nan }
}

nonisolated extension BinaryFloatingPoint {
    
    /// 小数部分>=0.999的情况直接进一位
    var rectifiedInt: Int {
        rectified.int
    }
    
    /// 小数部分>=0.999的情况直接进一位
    var rectified: Self {
        rectified(0.999)
    }
    
    var int: Int {
        do {
            let constrained = try Int.doubleRange.constrainedResult(double).get()
            return Int(constrained)
        } catch {
            switch error {
            case .tooLow:
                return Int.min
            case .tooHigh:
                return Int.max
            }
        }
    }
    
    var half: Self {
        self / 2.0
    }
    
    var isNegative: Bool {
        self < 0.0
    }
    
    var isPositive: Bool {
        self > 0.0
    }
    
    var float: Float {
        Float(self)
    }
    
    var cgFloat: CGFloat {
        CGFloat(self)
    }
    
    var double: Double {
        Double(self)
    }
    
    var nsNumber: NSNumber {
        NSNumber(value: double)
    }
    
    var decimal: Decimal {
        Decimal(double)
    }
    
    /// 小数部分>=fractionalPartThreshold的情况直接进一位, 否则原样输出
    func rectified(_ fractionalPartThreshold: Self) -> Self {
        /// 拆分出整数部分和小数部分
        let modf = modf(self)
        /// 小数部分(如果可能的话进位为1.0)
        let fractionalPart: Self
        /// 根据符号填充小数部分
        switch modf.1.sign {
        case .plus:
            fractionalPart = abs(modf.1) >= fractionalPartThreshold ? 1.0 : modf.1
        case .minus:
            fractionalPart = abs(modf.1) >= fractionalPartThreshold ? -1.0 : modf.1
        }
        /// 返回: 整数部分 + 小数部分
        return modf.0 + fractionalPart
    }
    
    /// 将自己约束在指定范围内
    /// - Parameter range: 指定范围
    /// - Returns: 约束后的值
    func constrained(in range: ClosedRange<Self>) -> Self {
        range << self
    }
    
    /// 计算在指定范围内的百分比
    /// - Parameter range: 指定范围
    /// - Returns: 百分比
    func percentage(in range: ClosedRange<Self>) -> Self {
        range.percentage(self)
    }
}

nonisolated extension BinaryFloatingPoint {
    
    /// 保留两位小数的字符串
    var f2: String {
        formatted(.f2)
    }
    
    /// 格式化为字符串: 保留小数位0...4位, 进位规则.down
    var f4: String {
        formatted(.f4)
    }
    
    /// 0...1.0的小数转换成无小数位的百分比
    var percentage: String {
        formatted(.percentage)
    }
}
