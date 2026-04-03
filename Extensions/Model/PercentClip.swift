//
//  PercentClip.swift
//  KnowLED
//
//  Created by Choi on 2023/12/20.
//

import Foundation

/// 将0...1.0的百分比从中间0.5切分成左右两半百分比
/// 通常用于滑块百分比分割
/// 往左, 左侧百分比增大, 右侧百分比为空
/// 往右, 右侧百分比增大, 左侧百分比为空
/// 居中时(0.5), 两侧百分比都为空
struct PercentClip {
    /// 偏左百分比: 越往左越大, 范围0-1
    let lower: Double?
    /// 偏右百分比: 越往右越大, 范围0-1
    let upper: Double?
    /// 覆写初始化方法: 内部约束参数值
    fileprivate init(lower: Double?, upper: Double?) {
        self.lower = lower
        self.upper = upper
    }
}

extension PercentClip {
    
    /// 初始化
    /// - Parameter percent: 百分比(范围: 0-1)
    init(percent: Double) {
        /// 约束到0-1范围
        let percent = Double.percentRange << percent
        /// 偏左
        if percent < 0.5 {
            self.init(lower: 1.0 - percent * 2.0, upper: nil)
        }
        /// 居中
        else if percent == 0.5 {
            self.init(lower: nil, upper: nil)
        }
        /// 偏右
        else {
            self.init(lower: nil, upper: percent * 2.0 - 1.0)
        }
    }
    
    /// 解包并回调相应的半边百分比
    /// - Parameters:
    ///   - lower: 较低的一半百分比
    ///   - middle: 0.5
    ///   - upper: 较高的一半百分比
    func unwrap(lower: (_ lower: Double) -> Void, middle: SimpleCallback = {},  upper: (_ upper: Double) -> Void) {
        if let unwrapLower = self.lower {
            lower(unwrapLower)
        } else if let unwrapUpper = self.upper {
            upper(unwrapUpper)
        } else {
           middle()
        }
    }
    
    /// 偏移(范围: -1...1) | 偏左则范围为(-1...0), 偏右则范围为(0...1), 居中则为0
    var shift: Double {
        signedLower ?? upper ?? 0
    }
    
    /// 翻转左侧百分比
    /// 0.6 -> 0.4 | 0.3 -> 0.7
    var reverseLower: Double? {
        lower.flatMap { left in
            1.0 - left
        }
    }
    
    /// 分割百分比(带符号): 左侧百分比为负数
    var signedLower: Double? {
        lower.map(\.negative)
    }
}
