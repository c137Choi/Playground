//
//  UnitFormatStyle.swift
//  KnowLED
//
//  Created by Choi on 2026/2/4.
//
//  基础FormatStyle格式化完成后, 在尾部拼接上指定单位

import Foundation

struct UnitFormatStyle<Base: FormatStyle>: FormatStyle where Base.FormatOutput == String {
    /// 基础FormatStyle
    let base: Base
    /// 尾部追加的单位字符串
    let unit: String
    
    func format(_ value: Base.FormatInput) -> Base.FormatOutput {
        base.format(value) + unit
    }
}
