//
//  NumberFormatterPlus.swift
//  ExtensionDemo
//
//  Created by Choi on 2021/6/15.
//  Copyright © 2021 Choi. All rights reserved.
//

import Foundation

extension NumberFormatter {
	
    /// 用于重置sharedFormatter
    fileprivate static let frozenFormatter = NumberFormatter()
    
    /// 复用的Formatter | 每次使用前需要先进行重置
    fileprivate static var instance = NumberFormatter()
	
	public static var shared: NumberFormatter {
        instance.reset
	}
	
	public static var spellout: NumberFormatter {
		shared.setup {
			$0.numberStyle = .spellOut
			$0.zeroSymbol = "零"
			$0.locale = .chineseSimplified
		}
	}
	
	/// 重置NumberFormatter
    fileprivate var reset: NumberFormatter {
        /// 格式化样式
        numberStyle                       = NumberFormatter.frozenFormatter.numberStyle
        /// 本地化
        locale                            = NumberFormatter.frozenFormatter.locale
        /// 字符串转成Number的时候是否生成NSDecimalNumber对象 | 默认为: false
        generatesDecimalNumbers           = NumberFormatter.frozenFormatter.generatesDecimalNumbers
        formatterBehavior                 = NumberFormatter.frozenFormatter.formatterBehavior
        negativeFormat                    = NumberFormatter.frozenFormatter.negativeFormat
        textAttributesForNegativeValues   = NumberFormatter.frozenFormatter.textAttributesForNegativeValues
        positiveFormat                    = NumberFormatter.frozenFormatter.positiveFormat
        textAttributesForPositiveValues   = NumberFormatter.frozenFormatter.textAttributesForPositiveValues
        allowsFloats                      = NumberFormatter.frozenFormatter.allowsFloats
        /// 小数分隔符 | .
        decimalSeparator                  = NumberFormatter.frozenFormatter.decimalSeparator
        alwaysShowsDecimalSeparator       = NumberFormatter.frozenFormatter.alwaysShowsDecimalSeparator
        /// 货币小数分隔符 | .
        currencyDecimalSeparator          = NumberFormatter.frozenFormatter.currencyDecimalSeparator
        /// 是否使用分组符号
        usesGroupingSeparator             = NumberFormatter.frozenFormatter.usesGroupingSeparator
        /// 分组分隔符 | ,
        groupingSeparator                 = NumberFormatter.frozenFormatter.groupingSeparator
        zeroSymbol                        = NumberFormatter.frozenFormatter.zeroSymbol
        textAttributesForZero             = NumberFormatter.frozenFormatter.textAttributesForZero
        nilSymbol                         = NumberFormatter.frozenFormatter.nilSymbol
        textAttributesForNil              = NumberFormatter.frozenFormatter.textAttributesForNil
        /// 非数字符号 | NaN
        notANumberSymbol                  = NumberFormatter.frozenFormatter.notANumberSymbol
        textAttributesForNotANumber       = NumberFormatter.frozenFormatter.textAttributesForNotANumber
        /// 正无穷符号 | +∞
        positiveInfinitySymbol            = NumberFormatter.frozenFormatter.positiveInfinitySymbol
        textAttributesForPositiveInfinity = NumberFormatter.frozenFormatter.textAttributesForPositiveInfinity
        /// 负无穷符号 | -∞
        negativeInfinitySymbol            = NumberFormatter.frozenFormatter.negativeInfinitySymbol
        textAttributesForNegativeInfinity = NumberFormatter.frozenFormatter.textAttributesForNegativeInfinity
        /// 正数前缀
        positivePrefix                    = NumberFormatter.frozenFormatter.positivePrefix
        /// 正数后缀
        positiveSuffix                    = NumberFormatter.frozenFormatter.positiveSuffix
        /// 负数前缀
        negativePrefix                    = NumberFormatter.frozenFormatter.negativePrefix
        /// 负数后缀
        negativeSuffix                    = NumberFormatter.frozenFormatter.negativeSuffix
        currencyCode                      = NumberFormatter.frozenFormatter.currencyCode
        currencySymbol                    = NumberFormatter.frozenFormatter.currencySymbol
        internationalCurrencySymbol       = NumberFormatter.frozenFormatter.internationalCurrencySymbol
        /// 百分符号 | %
        percentSymbol                     = NumberFormatter.frozenFormatter.percentSymbol
        /// 千分符号 | ‰
        perMillSymbol                     = NumberFormatter.frozenFormatter.perMillSymbol
        /// 减号
        minusSign                         = NumberFormatter.frozenFormatter.minusSign
        /// 加号
        plusSign                          = NumberFormatter.frozenFormatter.plusSign
        /// 指数符号 | E
        exponentSymbol                    = NumberFormatter.frozenFormatter.exponentSymbol
        groupingSize                      = NumberFormatter.frozenFormatter.groupingSize
        /// 第二分组大小: Some locales allow the specification of another grouping size for larger numbers.
        /// For example, some locales may represent a number such as 61, 242, 378.46 (as in the United States) as 6,12,42,378.46.
        /// In this case, the secondary grouping size (covering the groups of digits furthest from the decimal point) is 2.
        secondaryGroupingSize             = NumberFormatter.frozenFormatter.secondaryGroupingSize
        /// 数字<->字符转换因数: 字符串->数字时, 这个值用作除数. 数字->字符串时, 这个值用作乘数
        /// These operations allow the formatted values to be different from the values that a program manipulates internally.
        multiplier                        = NumberFormatter.frozenFormatter.multiplier
        formatWidth                       = NumberFormatter.frozenFormatter.formatWidth
        paddingCharacter                  = NumberFormatter.frozenFormatter.paddingCharacter
        paddingPosition                   = NumberFormatter.frozenFormatter.paddingPosition
        /// 进位规则
        roundingMode                      = NumberFormatter.frozenFormatter.roundingMode
        /// 精度 | 如圆周率: 3.1415926535897932
        /// 在roundingIncrement == 0.0001, roundingMode为.halfUp, maximumFractionDigits == 4的情况下, 转换成字符串将会是3.1416
        /// 在roundingIncrement == 0.000001, roundingMode为.down, maximumFractionDigits == 6的情况下, 转换成字符串将会是3.141592
        /// 原理: (原数字 / 精度)后, 按照roundingMode进位, 最后再乘以精度 -> 得出最终输出.
        /// 即先放大/缩小 -> 进位 -> 缩小/放大. 这里可能为放大/缩小因为精度可能为正数.
        /// 如精度100, roundingMode为.halfUp. 1149 -> "1100"; 1150 -> "1200"
        roundingIncrement                 = NumberFormatter.frozenFormatter.roundingIncrement
        /// 最小整数位
        minimumIntegerDigits              = NumberFormatter.frozenFormatter.minimumIntegerDigits
        /// 最大整数位
        maximumIntegerDigits              = NumberFormatter.frozenFormatter.maximumIntegerDigits
        /// 最小小数位
        minimumFractionDigits             = NumberFormatter.frozenFormatter.minimumFractionDigits
        /// 最大小数位
        maximumFractionDigits             = NumberFormatter.frozenFormatter.maximumFractionDigits
        /// 允许输入的最小值
        minimum                           = NumberFormatter.frozenFormatter.minimum
        /// 允许的最大值
        maximum                           = NumberFormatter.frozenFormatter.maximum
        /// 货币分组符号
        currencyGroupingSeparator         = NumberFormatter.frozenFormatter.currencyGroupingSeparator
        isLenient                         = NumberFormatter.frozenFormatter.isLenient
        /// 是否使用有效数字
        usesSignificantDigits             = NumberFormatter.frozenFormatter.usesSignificantDigits
        /// 最小有效数字
        minimumSignificantDigits          = NumberFormatter.frozenFormatter.minimumSignificantDigits
        /// 最大有效数字
        maximumSignificantDigits          = NumberFormatter.frozenFormatter.maximumSignificantDigits
        isPartialStringValidationEnabled  = NumberFormatter.frozenFormatter.isPartialStringValidationEnabled
		return self
	}
}
