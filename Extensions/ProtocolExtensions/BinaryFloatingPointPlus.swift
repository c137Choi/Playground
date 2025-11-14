//
//  BinaryFloatingPointPlus.swift
//  KnowLED
//
//  Created by Choi on 2023/12/5.
//

import Foundation

extension Optional where Wrapped: BinaryFloatingPoint {
    
    var orZero: Wrapped { self ?? 0.0 }
}

extension BinaryFloatingPoint {
    
    /// 分割百分比: self必须在0...1.0之间, 返回左右两个百分比
    /// 通常用于滑块百分比分割
    /// 往左, 左侧百分比增大, 右侧百分比为空
    /// 往右, 右侧百分比增大, 左侧百分比为空
    /// 居中时(0.5), 两侧百分比都为空
    var percentClip: PercentClip<Self> {
        let percentage = Self.hotPercentRange << self
        if self < 0.5 {
            return PercentClip(lower: 1.0 - percentage / 0.5, upper: nil)
        } else if self == 0.5 {
            return PercentClip(lower: nil, upper: nil)
        } else {
            return PercentClip(lower: nil, upper: (percentage - 0.5) / 0.5)
        }
    }
    
    /// 小数部分>=0.999的情况直接进一位
    var rectifiedInt: Int {
        rectified.int
    }
    
    /// 小数部分>=0.999的情况直接进一位
    var rectified: Self {
        rectified(0.999)
    }
    
    var int: Int {
        let doubleValue = double
        if doubleValue < Int.min.double {
            return Int.min
        }
        else if doubleValue > Int.max.double {
            return Int.max
        }
        else {
            return Int(self)
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
        let modf = modf
        /// 小数部分(如果可能的话进位为1.0)
        let fractionalPart: Self
        /// 根据符号填充小数部分
        switch modf.fractionalPart.sign {
        case .plus:
            fractionalPart = abs(modf.fractionalPart) >= fractionalPartThreshold ? 1.0 : modf.fractionalPart
        case .minus:
            fractionalPart = abs(modf.fractionalPart) >= fractionalPartThreshold ? -1.0 : modf.fractionalPart
        }
        /// 返回: 整数部分 + 小数部分
        return modf.integerPart + fractionalPart
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
    func progress(in range: ClosedRange<Self>) -> Self {
        range.progress(for: self)
    }
}

extension BinaryFloatingPoint {
    
    // 默认设置
    fileprivate var decimalFormatter: NumberFormatter {
        NumberFormatter.shared.setup { make in
            /// 数字格式: 小数
            make.numberStyle = .decimal
            /// 最大小数位: 2
            make.maximumFractionDigits = 2
        }
    }
    
    /// 四舍五入的Formatter
    fileprivate var roundDecimalFormatter: NumberFormatter {
        decimalFormatter.setup { make in
            make.roundingMode = .halfUp
        }
    }
    
    // 带正负号的Formatter
    fileprivate var signedDecimalFormatter: NumberFormatter {
        decimalFormatter.setup { make in
            make.positivePrefix = "+"
            make.negativePrefix = "-"
            make.zeroSymbol = "0" /// 格式化成带有正负号的数字时,0不带符号
        }
    }
    
    /// 原样输出,有小数位则显示,无小数位则显示整数,最多保留4位小数,进位规则.down
    var str4f: String {
        rounded(roundingIncrement: 10_000, rule: .down).nsNumber.description
    }
    
    /// 带符号 | 四舍五入
    var signedR2: String {
        signedDecimalFormatter.transform { formatter in
            formatter.roundingMode = .halfUp
            return formatter.string(from: nsNumber) ?? ""
        }
    }
    
    /// 带符号 | 原样输出
    var signedF: String {
        signedDecimalFormatter.transform { fmt -> String in
            fmt.string(from: nsNumber) ?? ""
        }
    }
    
    /// 带符号 | 保留两位小数
    var signedF2: String {
        signedDecimalFormatter.transform { formatter in
            formatter.minimumFractionDigits = 2
            return formatter.string(from: nsNumber) ?? ""
        }
    }
    
    /// 四舍五入 | 原样输出
    var r2: String {
        roundDecimalFormatter.transform { fmt -> String in
            fmt.string(from: nsNumber) ?? ""
        }
    }
    
    /// 保留两位小数的字符串
    var f2: String {
        f(2)
    }
    
    var f4: String {
        f(4)
    }
    
    /// 0...1.0的小数转换成百分比
    var percentString: String {
        percentString(fractions: 0) ?? ""
    }
    
    /// 格式化0...1.0到百分比
    private func percentString(fractions: Int = 0) -> String? {
        NumberFormatter.shared.transform { formatter in
            formatter.numberStyle = .percent
            /// 因为shared属性内对复用的Formatter所有属性都作了重置(numberStyle被重置为了.none)
            /// 可能还在同一个runloop中,设置了numberStyle = .percent之后相关属性还未生效
            /// 这里改了numberStyle之后要重新设置相关属性(大概.numberStyle对数字格式化并不重要,因为设置了.numberStyle之后本质是设置了相关的一组属性)
            /// 就算把上面设置.numberStyle一行注释掉, 只保留下面的一组属性设置, 也可以达到想要的格式化效果
            /// 可能这就是苹果为什么推行format新API的原因吧
            formatter.positiveSuffix = "%"
            /// 数字 -> 字符串转换因子 | 0...1.0的小数乘以这个数, shared属性重置后此值为空
            /// 所以之前格式化时输出的字符串总是0或1, 就是因为这个值
            /// 还可以设置它为360, 这样就可以直接格式化色相了666 | 2024年09月25日18:17:30
            formatter.multiplier = 100.nsNumber
            /// 这里还同时设置了进位规则, 避免出现.9999999的情况
            formatter.roundingMode = .halfEven
            formatter.minimumFractionDigits = fractions
            formatter.maximumFractionDigits = fractions
            return formatter.string(for: self)
        }
    }
    
    func signedF(_ fractionDigits: Int) -> String {
        signedDecimalFormatter.transform { formatter in
            formatter.minimumFractionDigits = fractionDigits
            formatter.maximumFractionDigits = fractionDigits
            return formatter.string(from: nsNumber) ?? ""
        }
    }
    
    func f(_ fractions: Int, roundingMode: NumberFormatter.RoundingMode = .down, roundingIncrement: NSNumber? = nil) -> String {
        f(fractions...fractions, roundingMode: roundingMode, roundingIncrement: roundingIncrement)
    }
    
    /// 格式化浮点数
    /// - Parameters:
    ///   - fractionsRange: 小数部分长度范围
    ///   - roundingMode: 进位模式
    ///   - roundingIncrement: 进位精度
    /// - Returns: 格式化后的字符串
    func f(_ fractionsRange: ClosedIntRange, roundingMode: NumberFormatter.RoundingMode = .down, roundingIncrement: NSNumber? = nil) -> String {
        decimalFormatter.transform { formatter in
            formatter.minimumFractionDigits = fractionsRange.lowerBound
            formatter.maximumFractionDigits = fractionsRange.upperBound
            formatter.roundingMode = roundingMode
            if let roundingIncrement {
                formatter.roundingIncrement = roundingIncrement
            }
            return formatter.string(for: self).orEmpty
        }
    }
}
