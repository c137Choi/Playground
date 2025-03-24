//
//  UIGestureRecognizerPlus.swift
//  KnowLED
//
//  Created by Choi on 2024/5/14.
//

import UIKit

extension UIGestureRecognizer {
    /// 将任意类型的手势转换成普通的UIGestureRecognizer
    /// 用于响应式编程中合并两种不同的手势事件
    /// e.g. Observable.merge(pan.rx.event.map(\.mediocreGestureRecognizer), tap.rx.event.map(\.mediocreGestureRecognizer))
    var mediocreGestureRecognizer: UIGestureRecognizer {
        self
    }
}

extension UIGestureRecognizer.State {
    
    var phase: UITouch.Phase {
        switch self {
        case .began:
            return .began
        case .changed:
            return .moved
        case .ended:
            return .ended
        case .cancelled:
            return .cancelled
        default:
            return .ended
        }
    }
    
    /// 正在交互的状态
    var isInteracting: Bool {
        switch self {
        case .began, .changed:
            true
        default:
            false
        }
    }
    
    var isBegan: Bool {
        self == .began
    }
    
    var isEnded: Bool {
        self == .ended
    }
}
