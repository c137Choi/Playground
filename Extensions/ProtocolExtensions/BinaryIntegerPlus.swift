//
//  BinaryIntegerPlus.swift
//  KnowLED
//
//  Created by Choi on 2023/8/12.
//

import Foundation

extension Optional where Wrapped: BinaryInteger {
    
    var orZero: Wrapped { self ?? 0 }
}

extension BinaryInteger {
    
    /// 带正负号的字符串
    var signedString: String {
        if self > 0 {
            "+" + string
        } else if self < 0 {
            string
        } else {
            "0"
        }
//        /// 注: 不使用下面的方式, 因为遇到播放视频时格式化会偶尔格式化成(14.0000)这样的格式
//        NumberFormatter.shared.configure { make in
//            make.positivePrefix = "+"
//            make.negativePrefix = "-"
//            make.zeroSymbol = "0"
//        }.transform { formatter in
//            formatter.string(for: self).orEmpty
//        }
    }
    
    var string: String {
        String(self)
    }
    
    /// 去掉argb的alpha通道
    var rgb: Int {
        Int((uInt32 << 8) >> 8)
    }
    
    var cgFloat: CGFloat {
        CGFloat(self)
    }
    
    var float: Float {
        Float(self)
    }
    
    var double: Double {
        Double(self)
    }
    
    var int: Int {
        Int(truncatingIfNeeded: self)
    }
    
    var int64: Int64 {
        Int64(truncatingIfNeeded: self)
    }
    
    var int32: Int32 {
        Int32(truncatingIfNeeded: self)
    }
    
    var int16: Int16 {
        Int16(truncatingIfNeeded: self)
    }
    
    var int8: Int8 {
        Int8(truncatingIfNeeded: self)
    }
    
    var uInt: UInt {
        UInt(truncatingIfNeeded: self)
    }
    
    var uInt64: UInt64 {
        UInt64(truncatingIfNeeded: self)
    }
    
    var uInt32: UInt32 {
        UInt32(truncatingIfNeeded: self)
    }
    
    var uInt16: UInt16 {
        UInt16(truncatingIfNeeded: self)
    }
    
    var uInt8: UInt8 {
        UInt8(truncatingIfNeeded: self)
    }
    
    /// 占用的字节数
    var byteCount: Int {
        MemoryLayout.size(ofValue: self)
    }
    
    var hexString: String {
        stringOfRadix(16, uppercase: true)
    }
    
    /// 数字转换为指定进制字符串
    /// - Parameters:
    ///   - radix: 进制: 取值范围: 2...36
    ///   - uppercase: 字母是否大写
    /// - Returns: 转换成功后的字符串
    func stringOfRadix(_ radix: Int, uppercase: Bool = true) -> String {
        guard (2...36) ~= radix else {
            assertionFailure("NO SUCH RADIX 🤯")
            return ""
        }
        return String(self, radix: radix, uppercase: uppercase)
    }
    
    /// 非零为真
    var isTrue: Bool { self != 0 }
    
    var isFalse: Bool { !isTrue }
}

extension BinaryInteger {
    
    @discardableResult static postfix func ++(input: inout Self) -> Self {
        defer {
            input += 1
        }
        return input
    }
    
    @discardableResult static prefix func ++(input: inout Self) -> Self {
        input += 1
        return input
    }
    
    @discardableResult static postfix func --(input: inout Self) -> Self {
        defer {
            input -= 1
        }
        return input
    }
    
    @discardableResult static prefix func --(input: inout Self) -> Self {
        input -= 1
        return input
    }
}
