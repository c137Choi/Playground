//
//  CGFloatPlus.swift
//  ExtensionDemo
//
//  Created by Choi on 2021/2/26.
//  Copyright © 2021 Choi. All rights reserved.
//

import CoreGraphics

nonisolated extension CGFloat {
    /// 这里储存一份静态属性,避免重复创建Range
    static let percentRange = CGFloat.hotPercentRange
}
