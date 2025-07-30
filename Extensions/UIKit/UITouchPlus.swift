//
//  UITouchPlus.swift
//  KnowLED
//
//  Created by Choi on 2023/12/7.
//

import UIKit

extension UITouch {
    
    /// 当前对象在自身view中的位置
    var location: CGPoint {
        location(in: view)
    }
    
    /// 计算和上次Touch的偏移
    /// - Parameter view: 点击的视图
    /// - Returns: 拖动偏移
    func offset(in view: UIView?) -> CGPoint {
        let location = location(in: view)
        let previousLocation = previousLocation(in: view)
        let offsetX = location.x - previousLocation.x
        let offsetY = location.y - previousLocation.y
        return CGPoint(x: offsetX, y: offsetY)
    }
}

extension UITouch.Phase {
    
    var isBegan: Bool {
        self == .began
    }
    
    var isMoved: Bool {
        self == .moved
    }
    
    var isEnded: Bool {
        self == .ended
    }
}
