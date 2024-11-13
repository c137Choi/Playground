//
//  FixedWidthIntegerPlus.swift
//  KnowLED
//
//  Created by Choi on 2023/8/12.
//

import Foundation

extension FixedWidthInteger {
    
    /// 生成随机数
    static var random: Self {
        random(in: range)
    }
    
    /// 支持的Int范围
    static var intRange: ClosedRange<Int> {
        range.intRange
    }
    
    /// 支持的范围
    static var range: ClosedRange<Self> {
        min...max
    }
    
    /// 二进制 | 小字节序读取二进制
    var data: Data {
        data(byteOrder: .littleEndian)
    }
    
    
    /// 整数转换为二进制
    /// - Parameters:
    ///   - byteCount: 按照字节序读取的字节数
    ///   - byteOrder: 字节序
    /// - Returns: 读取的二进制
    /// - 示例：UInt64(0xFF_FE_FD_FC_FB_FA_F9_F8) 小字节序-> [F8, F9, FA, FB, FC, FD, FE, FF]
    /// - 示例: UInt64(0xFF_FE_FD_FC_FB_FA_F9_F8) 大字节序-> [FF, FE, FD, FC, FB, FA, F9, F8]
    /// - 示例: UInt64(0xFD_FE_FF) 小字节序-> [FF, FE, FD, 0, 0, 0, 0, 0]
    /// - 示例: UInt64(0xFD_FE_FF) 大字节序-> [0, 0, 0, 0, 0, FD, FE, FF]
    /// - 示例: UInt32(0x00_FD_FE_FF) preferredByteCount==3, 小字节序 -> [FF, FE, FD]
    /// - 示例: UInt32(0x00_FD_FE_FF) preferredByteCount==3, 大字节序 -> [00, FD, FE]
    /// - 所以要注意使用的整数类型(UInt32/UInt16等)
    /// - 并小心配合使用preferredByteCount和byteOrder, 因为方法本质是从低位或高位读取指定个字节的数据存到Data中
    /// - 传入参数不当可能导致读取到错误的字节
    func data(readingBytes byteCount: Int? = nil, byteOrder: Data.ByteOrder) -> Data {
        var pointer = byteOrder == .bigEndian ? bigEndian : littleEndian
        return Data(bytes: &pointer, count: byteCount ?? bitWidth / 8)
    }
}
