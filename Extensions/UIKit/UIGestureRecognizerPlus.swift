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
    
    /// 用于过滤手指停止事件
    var isBegan: Bool {
        self == .began
    }
    var isEnded: Bool {
        self == .ended
    }
}
