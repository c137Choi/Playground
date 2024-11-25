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
    /// - 示例1：UInt64(0xFF_FE_FD_FC_FB_FA_F9_F8) 小字节序-> [F8, F9, FA, FB, FC, FD, FE, FF]
    /// - 示例2: UInt64(0xFF_FE_FD_FC_FB_FA_F9_F8) 大字节序-> [FF, FE, FD, FC, FB, FA, F9, F8]
    /// - 示例3: UInt64(0xFD_FE_FF) 小字节序-> [FF, FE, FD, 0, 0, 0, 0, 0]
    /// - 示例4: UInt64(0xFD_FE_FF) 大字节序-> [0, 0, 0, 0, 0, FD, FE, FF]
    /// - 示例5: UInt32(0x00_FD_FE_FF) preferredByteCount==3, 小字节序 -> [FF, FE, FD]
    /// - 示例6: UInt32(0x00_FD_FE_FF) preferredByteCount==3, 大字节序 -> [00, FD, FE]
    /// - 所以要注意使用的整数类型(UInt32/UInt16等) 并小心配合使用byteCount和byteOrder
    /// - 因为方法本质是从<低位>读取指定个字节的数据存到Data中(从左至右排列字节)
    /// - 经测试bigEndian为字节倒转过来的数字, littleEndian为原始二进制顺序(字节顺序不变)
    /// - 例如: UInt32(0x00_FD_FE_FF) 大字节序 -> [FF, FE, FD, 00], 上面示例6, 从低位读取3个字节结果就为: [00, FD, FE]
    /// - 所以: 大字节序可以视为源二进制从高位到低位读取字节, 小字节序可以视为源二进制从低位到高位读取字节
    /// - 传入参数不当可能导致读取到错误的字节
    func data(readingBytes byteCount: Int? = nil, byteOrder: Data.ByteOrder) -> Data {
        /// 指针开始位置
        var pointer = byteOrder == .bigEndian ? bigEndian : littleEndian
        /// 读取字节数
        let count = byteCount.or(bitWidth / 8)
        /// 返回字节数组
        return Data(bytes: &pointer, count: count)
    }
}
