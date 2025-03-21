//
//  DecimalPlus.swift
//
//  Created by Choi on 2023/5/11.
//

import Foundation

extension Decimal {
    
    static let percentRange: ClosedRange<Decimal> = 0...1
    
    /// 获取小数位数, 即小数精确位数
    /// 0.0001 -> 4; 0.03500 -> 3
    /// 经过测试, 最多可取38位小数位
    var significantFractionalDecimalDigits: Int {
        max(-exponent, 0)
    }
    
    var intValue: Int {
        nsDecimalNumber.intValue
    }
    
    var doubleValue: Double {
        nsDecimalNumber.doubleValue
    }
    
    var nsDecimalNumber: NSDecimalNumber {
        NSDecimalNumber(decimal: self)
    }
}

extension Decimal: @retroactive ExpressibleByStringLiteral {
    
    public init(stringLiteral value: StringLiteralType) {
        if value.containsCharacter(in: .realNumber.inverted) {
            self.init(0)
        } else {
            self.init(string: value)!
        }
    }
}
